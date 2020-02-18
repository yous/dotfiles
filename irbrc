# frozen_string_literal: true

# https://github.com/bundler/bundler/issues/183#issuecomment-1149953
if defined?(::Bundler)
  global_gemset = ENV['GEM_PATH'].split(':').grep(/ruby.*@global/).first
  if global_gemset
    all_global_gem_paths = Dir.glob("#{global_gemset}/gems/*")
    all_global_gem_paths.each do |p|
      gem_path = "#{p}/lib"
      $LOAD_PATH << gem_path
    end
  end
end

IRB.conf[:AUTO_INDENT] = true
IRB.conf[:PROMPT_MODE] = :SIMPLE
IRB.conf[:SAVE_HISTORY] = 10_000

require 'rubygems'
require 'irb/completion'

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.7.0')
  begin
    require 'wirble'

    Wirble.init
    Wirble.colorize
  rescue LoadError # rubocop:disable Lint/SuppressedException
  end
end
