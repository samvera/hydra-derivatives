version = File.read(File.expand_path("../VERSION", __FILE__)).strip

Gem::Specification.new do |spec|
  spec.name          = "hydra-derivatives"
  spec.version       = version
  spec.authors       = ["Justin Coyne"]
  spec.email         = ["jenlindner@gmail.com", "jcoyne85@stanford.edu"]
  spec.description   = "Derivative generation plugin for hydra"
  spec.summary       = "Derivative generation plugin for hydra"
  spec.license       = "APACHE2"
  spec.homepage      = "https://github.com/projecthydra/hydra-derivatives"

  spec.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR).select { |f| File.dirname(f) !~ %r{\A"?spec|test|features\/?} }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'fcrepo_wrapper', '~> 0.2'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rails', '> 5.1', '< 7.0'
  spec.add_development_dependency 'rake', '~> 10.1'
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency "solr_wrapper", "~> 2.0"

  spec.add_dependency 'active-fedora', '>= 11.5.6',
                      '!= 12.0.0', '!= 12.0.1', '!= 12.0.2', '!= 12.0.3', '!= 12.1.0', '!= 12.1.1', '!= 12.2.0', '!= 12.2.1',
                      '!= 13.0.0', '!= 13.1.0', '!= 13.1.1', '!= 13.1.2', '!= 13.1.3', '!= 13.2.0', '!= 13.2.1'
  spec.add_dependency 'active_encode', '~>0.1'
  spec.add_dependency 'activesupport', '>= 4.0', '< 7'
  spec.add_dependency 'addressable', '~> 2.5'
  spec.add_dependency 'deprecation'
  spec.add_dependency 'mime-types', '> 2.0', '< 4.0'
  spec.add_dependency 'mini_magick', '>= 3.2', '< 5'
end
