Gem::Specification.new do |spec|
  spec.name          = "backbitr"
  spec.version       = "0.1.0"
  spec.authors       = ["entropie"]
  spec.summary       = "minimalist static site generator in ruby - grandmaster style"
  spec.files         = [Dir["lib/**/*.rb"], Dir["bin/**/*.rb"]].flatten
  spec.require_paths = ["lib"]
  spec.add_dependency "termin/ansicolor", "~> 1.11.2"
  spec.add_dependency "haml", "~> 6.3.0"
  spec.add_dependency "nokogiri", "~> 1.18.9"
end
