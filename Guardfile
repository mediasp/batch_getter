# A sample Guardfile
# More info at https://github.com/guard/guard#readme
# vim: ft=ruby

guard :minitest do
  # with Minitest::Unit
  watch(%r{^test/(.*)\/?(.*)_test\.rb$})
  watch(%r{^lib/(.*/)?([^/]+)\.rb$})     { |m| "test/#{m[1]}#{m[2]}_test.rb" }
  watch(/^test\/test_helper\.rb$/)      { 'test' }
end

guard :rubocop, all_on_start: false do
  watch(/lib\/.+\.rb$/)
  watch(/(?:.+\/)?\.rubocop\.yml$/) { |m| File.dirname(m[0]) }
end

guard :reek do
  watch(/^lib\/.+\.rb$/)
end

guard :flay do
  watch(/^lib\/(.+)\.rb/)
end
