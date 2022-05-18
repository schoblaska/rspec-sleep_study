Gem::Specification.new do |s|
  s.name = "rspec-sleep_study"
  s.version = "1.1.1"
  s.summary =
    "An RSpec profiler that shows you how long specs are spending in `sleep`"
  s.author = "Joey Schoblaska / Kenna Security"
  s.homepage = "https://github.com/joeyschoblaska/rspec-sleep_study"
  s.license = "MIT"

  s.files = `git ls-files lib`.split("\n")

  s.add_runtime_dependency "rspec-core"
end
