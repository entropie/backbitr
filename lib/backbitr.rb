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

    class Entry

      attr_reader :path
      attr_reader :metadata

      def initialize(path)
        @path = path
      end

      def self.select_for(file)
        case File.extname(file)[1..-1]
        when "textile"
          Post.new(file)
        else
          raise "ops"
        end
      end

      def basename
        File.basename(path)
      end
    end

    class Post < Entry

      MetaData = ["Date", "Foo", "Bar"]

      def parse_basename
        @time ||= Time.local(*basename[0...8].split("-").map{|s| s.to_i})
        @title ||= basename[9..-1]
      end

      def time
        parse_basename
        @time
      end
      alias :date :time

      def title
        parse_basename
        @title
      end

      def file_contents
        @file_contents ||= File.readlines(path)
      end

      def metadata
        unless @metadata
          @metadata = {}
          file_contents.each do |line|
            if line =~ /^# (#{MetaData.join('|')}): (.+)/
              @metadata[$1.downcase.to_sym] = $2.strip
              @file_contents.delete(line)
            end
          end
        end
        @metadata
      end

      def body
        file_contents.join.strip
      end
    end

    class Entries < Array

      attr_reader :repository
      def initialize(repos)
        @repository = repos
        super()
      end

      def read!(path = "posts")
        dir_pattern = "#{repository.path}/#{path}/**/*"
        Dir[dir_pattern].each{|entry|
          push Entry.select_for(entry)
        }
        self
      end
    end

    attr_reader :path

    include FUtils

    def entries
      create unless exist?
      unless @entries
        @entries = Entries.new(self)
        @entries.read!
      end
      @entries
    end

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

Backbitr.repository.entries.each do |post|
  puts
  # p post.title
  # p post.date
  p post.metadata

  p post.body
end

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
