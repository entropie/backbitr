#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "pp"

require "rubygems"
require "nokogiri"


module Backbitr

  module Ex
    class BBRError < Exception; end
  end

  Source  = File.dirname(File.dirname(File.expand_path(__FILE__)))

  Version = [0, 0, 1, 'pre']

  DefaultRepository = "~/.bbr"

  class Repository

    attr_reader :path

    def initialize(path)
      @path = path
    end
    def inspect
      %Q'<BBR: "#{path}">'
    end
  end

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

include Backbitr

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
