
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "benchmark_driver-output-charty"
  spec.version       = "0.2.0"
  spec.authors       = ["284km"]
  spec.email         = ["k.furuhashi10@gmail.com"]

  spec.summary       = %q{Show graph on benchmark_driver using charty.gem}
  spec.description   = %q{Show graph on benchmark_driver using charty.gem}
  spec.homepage      = "https://github.com/benchmark-driver/benchmark_driver-output-charty"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/benchmark-driver/benchmark_driver-output-charty"
  spec.metadata["changelog_uri"] = "https://github.com/benchmark-driver/benchmark_driver-output-charty/CHANGES.md"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "benchmark_driver", ">= 0.15.1"
  spec.add_dependency "charty", ">= 0.2.0"
  spec.add_dependency "matplotlib"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "unicode_plot"
end
