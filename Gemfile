# coding: utf-8

source 'https://rubygems.org'

# we need to install this with a version of bundler that doesn't know what this
# means
# ruby '1.9.3'

gem 'rack'
gem 'rest-client', '~> 1.6.8'

# These aren't things we require, but we need to lock the versions due to the
# nested gem dependencies.
gem 'mime-types', '~> 1.25.1'
gem 'rubyzip', '0.9.9'

platforms :mri do
  gem 'thin'
end

group :development do
  gem 'foreman'
  gem 'shotgun'
  gem 'pkgr'
  gem 'bump'
end
