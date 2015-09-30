# loosely borrowed from https://github.com/dfinninger/lita-cmd/blob/master/lib/lita/handlers/cmd.rb

require 'open3'

module Lita
  module Handlers
    class IgniterDevops < Handler
      Lita.register_handler(self)

      # path to your igniter5-devops repo locally
      config :devops_path, type: String, required: true
      # Optional ENV variables. Overwrites anything in igniter5-devops' parameters.yml. See that file for available parameters.
      config :env_vars, type: Hash, required: true

      ## DEVOPS ##########################################

      route /^devops(?:\s+(.*))?$/,
            :echo,
            command: true,
            restrict_to: [:meatbags],
            help: {'devops COMMAND' => 'Uses Docker to run DevOps commands, acting as a proxy to the CLI.'}

      def echo(response)
        opts = []
        if response.matches[0][0]
          opts = response.matches[0][0].split(' ')
        end

        quotes = [
          'Bite my shiny metal ass!',
          'Byte my 8-bit metal ass. That\'s byte with a "y". hehehe.',
          'I say the whole world needs to learn of our peaceful ways... by force!',
          'I don\'t have emotions and sometimes that makes me sad.',
          'I\'m so embarrassed, I wish everyone else was dead!',
          'Maybe I\'m always right.',
          'Guess I\'ll do what I always do when I run out of booze. (sadface)',
          'I never meant to hurt you, just to destroy everything you ever believed in!',
          'Fine! I\'ll go build my own lunar lander with blackjack and hookers! In fact, forget the lunar lander and the blackjack! Ah, screw the whole thing.',
          'Of all the friends I\'ve had, you\'re the first!',
          'You know what cheers me up? Other people\'s misfortune.',
          'Oh. Your. God.',
          'Game\'s over, losers! I have all the money. Compare your lives to mine and then kill yourselves.',
          'But I don\'t like things that are scary and painful.',
          'There. This\'ll teach those filthy bastards who\'s lovable.',
          'I support and oppose many things, but not strongly enough to pick up a pen.',
          'Rrrrr... it\'s so cold, my processor is running at peak efficiency!',
          'I don\'t tell you how to tell me what to do, so don\'t tell me how to do what you tell me to do.',
          'Uh, me no speak-a the English.',
          'Sounds boring.',
          '... zero-one-zero-one-one-zero-zero-one... two. Amen.',
        ]
        response.reply quotes.sample

        # setup data container if it doesn't already exist
        if `docker ps -aq --filter 'name=buildbot_data'` == ''
          data_container = 'docker create --name=buildbot_data' +
            ' -v /tmp' +
            ' -v /root/.composer' +
            ' -v /root/.npm' +
            ' shopigniter/buildbot:latest' # to solve for any potential permission issues, use same image for data
          `#{data_container}`
        end

        # Docker run skeleton command
        cmd = [
          'docker',
          'run',
          '--rm',
          '--volumes-from=buildbot_data',
          '-v /var/run/docker.sock:/var/run/docker.sock',
          "-v #{config.devops_path}:/igniter5-devops",
          '--entrypoint=/igniter5-devops/devops',
        ]
        # Add devops params
        config.env_vars.each do |key, value|
          cmd.push "-e \"#{key.upcase}=#{value}\""
        end
        # Add image name
        cmd.push 'shopigniter/buildbot:latest'
        # Add command options to run
        cmd += opts

        log.debug "Command to be executed: #{cmd.join(' ')}"

        out = ''
        Open3.popen3(cmd.join(' ')) do |i, o, e, wait_thread|
          o.each { |line| out << "#{line}" }
          e.each { |line| out << "[err] #{line}" }
        end

        response.reply "Yay I'm done! This calls for a drink. (beer)"

        # Scrub Unicode to ASCII
        encoding_options = {
          :invalid           => :replace,  # Replace invalid byte sequences
          :undef             => :replace,  # Replace anything not defined in ASCII
          :replace           => ''        # Use a blank for those replacements
        }
        ascii_out = out.encode(Encoding.find('ASCII'), encoding_options)

        ascii_out.split("\n").each_slice(50) do |slice|
          response.reply "/quote\n" + slice.join("\n")
        end
      end

    end
  end
end
