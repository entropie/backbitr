#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "pp"
require "fileutils"

require "rubygems"
require "nokogiri"

module Backbitr

  class LOG
    class << self
      def <<(os)
        os = [LOG_DEF, os] unless os.kind_of?(Array)
        puts "|> #{os.first}  #{os.last}"
      end
    end
  end

  module FUtils
    def mkdir_p(arg)
      LOG << "mkdir_p '#{arg.to_s}'"
      FileUtils.mkdir_p(arg)
    end

    def copy_r(src, dest)
      LOG << "cp -r '#{src}' '#{dest}'"
      FileUtils.cp_r(src, dest)
    end
  end
  
  module Ex
    class BBRError < Exception; end
  end

  Source  = File.dirname(File.dirname(File.expand_path(__FILE__)))

  Version = [0, 0, 1, 'pre']

  LOG_DEF = 0
  LOG_DEB = 5

  DefaultRepository = "~/.bbr"

  class Repository

    attr_reader :path

    include FUtils
    
    def initialize(path)
      @path = path
    end

    def inspect
      %Q'<BBR: "#{path}">'
    end

    def exist?
      File.exist?(path)
    end

    def create
      unless exist?
        mkdir_p(path)
        populate
      end
    end

    def read
      create unless exist?
    end

    def populate
      skel = File.join(Source, 'data/skel')
      Dir.glob("#{skel}/*").each do |skel_entry|
        copy_r(skel_entry, path)
      end
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

Backbitr.repository.read

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
