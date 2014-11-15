# coding: utf-8
version = File.read(File.expand_path("../VERSION", __FILE__)).strip


Gem::Specification.new do |spec|
  spec.name          = "hydra-derivatives"
  spec.version       = version 
  spec.authors       = ["Justin Coyne"]
  spec.email         = ["justin@curationexperts.com"]
  spec.description   = %q{Derivative generation plugin for hydra}
  spec.summary       = %q{Derivative generation plugin for hydra}
  spec.license       = "APACHE2"
  spec.homepage      = "https://github.com/projecthydra/hydra-derivatives"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "jettywrapper"
  spec.add_development_dependency "rspec"

  spec.add_dependency 'active-fedora', '~> 9.0.0.beta1'
  spec.add_dependency 'hydra-file_characterization'
  spec.add_dependency 'mini_magick'
  spec.add_dependency 'activesupport', '>= 3.2.13', '< 5.0'
  spec.add_dependency 'mime-types'
  spec.add_dependency 'deprecation'
end

