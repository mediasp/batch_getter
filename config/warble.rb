Warbler::Config.new do |config|
  config.features = %w()
  config.dirs = %w(lib)
  # We need config.ru, and the Gemfiles to generate the war, but they don't
  # actually need to be included inside it.
  config.excludes = %w(Gemfile Gemfile.lock config.ru)
  config.bundle_without = %w(development)
  config.gem_dependencies = true
  config.gem_excludes = [/^(test|spec)\//]
  config.webxml.jruby.compat.version = '2.0'
end
