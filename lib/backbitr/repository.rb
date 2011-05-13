#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbitr
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

      def inspect
        %Q'<#{self.class.to_s.split("::").last}: "#{title}" "#{path}">'
      end
    end

    class Post < Entry

      MetaData = ["Date", "Foo", "Bar", "Tags"]

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
        @html ||= RedCloth.new(file_contents.join.strip).to_html
      end

      def with_filter
        Filter.filter!(self)
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
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
