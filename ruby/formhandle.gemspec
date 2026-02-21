Gem::Specification.new do |s|
  s.name        = "formhandle"
  s.version     = "0.1.0"
  s.summary     = "CLI for FormHandle — form submissions as email"
  s.description = "Turn any HTML form into an email endpoint. No backend, no dashboard, no API keys."
  s.authors     = ["FormHandle"]
  s.email       = "hello@formhandle.dev"
  s.homepage    = "https://formhandle.dev"
  s.license     = "MIT"

  s.required_ruby_version = ">= 3.0"
  s.files       = Dir["lib/**/*.rb", "bin/*", "README.md"]
  s.bindir      = "bin"
  s.executables = ["formhandle"]

  s.metadata = {
    "homepage_uri"    => "https://formhandle.dev",
    "source_code_uri" => "https://github.com/ParapluOU/formhandle-examples",
  }
end
