#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "pp"
require "fileutils"

require "rubygems"
require "nokogiri"
require "RedCloth"

module Backbitr

  Source  = File.dirname(File.dirname(File.expand_path(__FILE__)))

  $: << File.join(Source, 'lib')

  require "backbitr/exceptions"
  require "backbitr/log"
  require "backbitr/futils"
  require "backbitr/repository"

  Version = [0, 0, 1, 'pre']

  LOG_DEF = 0
  LOG_DEB = 5

  DefaultRepository = "~/.bbr"

  class Config < Hash
    def initialize
      super{|h,k| h[k] = Config.new}
    end
  end

  class << self
    attr_reader :repository

    def repository=(repos)
      @repository = File.expand_path(repos)
    end

    def repository
      self.repository = DefaultRepository
      Repository.new(@repository)
    end

    def config
      @config ||= Config.new
    end

    def [](obj)
      config[obj]
    end

    def []=(obj, k)
      config[obj] = k
    end
  end

end

Backbitr.repository.entries.each do |post|
  puts
  p post.title
  p post.date
  p post.metadata

  puts post.body
end

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
