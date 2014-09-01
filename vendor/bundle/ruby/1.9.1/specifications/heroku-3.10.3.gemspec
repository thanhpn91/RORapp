# -*- encoding: utf-8 -*-
# stub: heroku 3.10.3 ruby lib

Gem::Specification.new do |s|
  s.name = "heroku"
  s.version = "3.10.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Heroku"]
  s.date = "2014-08-22"
  s.description = "Client library and command-line tool to deploy and manage apps on Heroku."
  s.email = "support@heroku.com"
  s.executables = ["heroku"]
  s.files = ["bin/heroku"]
  s.homepage = "http://heroku.com/"
  s.licenses = ["MIT"]
  s.post_install_message = " !    The `heroku` gem has been deprecated and replaced with the Heroku Toolbelt.\n !    Download and install from: https://toolbelt.heroku.com\n !    For API access, see: https://github.com/heroku/heroku.rb\n"
  s.rubygems_version = "2.2.2"
  s.summary = "Client library and CLI to deploy apps on Heroku."

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<heroku-api>, ["~> 0.3.19"])
      s.add_runtime_dependency(%q<launchy>, [">= 0.3.2"])
      s.add_runtime_dependency(%q<netrc>, ["~> 0.7.7"])
      s.add_runtime_dependency(%q<rest-client>, ["= 1.6.7"])
      s.add_runtime_dependency(%q<rubyzip>, ["= 0.9.9"])
    else
      s.add_dependency(%q<heroku-api>, ["~> 0.3.19"])
      s.add_dependency(%q<launchy>, [">= 0.3.2"])
      s.add_dependency(%q<netrc>, ["~> 0.7.7"])
      s.add_dependency(%q<rest-client>, ["= 1.6.7"])
      s.add_dependency(%q<rubyzip>, ["= 0.9.9"])
    end
  else
    s.add_dependency(%q<heroku-api>, ["~> 0.3.19"])
    s.add_dependency(%q<launchy>, [">= 0.3.2"])
    s.add_dependency(%q<netrc>, ["~> 0.7.7"])
    s.add_dependency(%q<rest-client>, ["= 1.6.7"])
    s.add_dependency(%q<rubyzip>, ["= 0.9.9"])
  end
end
