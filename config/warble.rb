Warbler::Config.new do |config|
  config.features = %w(executable)
  config.dirs = %w(config lib)
  config.bundle_without = %w(development)
  config.gem_dependencies = true
  config.gem_excludes = [/^(test|spec)\//]
  config.webserver = 'jetty'
  config.webxml.jruby.compat.version = "1.9"
end
