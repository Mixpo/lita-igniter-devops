Gem::Specification.new do |spec|
  spec.name          = "lita-igniter-devops"
  spec.version       = "0.1.0"
  spec.authors       = ["Jared Markell"]
  spec.email         = ["jaredm4@gmail.com"]
  spec.description   = "Issue devops commands from your HipChats as if it was the devops script actually. Mediocrity at its best."
  spec.summary       = "Devops wrapper for Lita and HipChat"
  spec.homepage      = "https://github.com/Mixpo/lita-igniter-devops"
  spec.license       = "MIT"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.6"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
end
