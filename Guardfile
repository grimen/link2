guard 'bundler' do
  watch('Gemfile')
  watch(/^.+\.gemspec/)
end

guard 'test' do
  watch(%r|^lib/(.*)\.rb|)                { |m| "test/lib/#{m[1]}_test.rb" }
  watch(%r|^test/(.*)_test.rb|)
  watch(%r|^test/integration/(.*)\.rb|)   { "test" }
  watch(%r|^test/test_helper.rb|)         { "test" }
end
