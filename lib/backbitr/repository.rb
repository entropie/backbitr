# -*- coding: undecided -*-
#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbitr
  class Repository

    class MetaData < Hash

      Keys = ["Date", "Foo", "Bar", "Tags", "Target"]

      def to_s
        "Metadata: " +
        map{|md|
          "%s:%s" % [md.first.to_s.capitalize, md.last]
        }.join("; ")
      end

      def target
        self[:target].to_sym rescue nil
      end

      def tags
        self[:tags].split(",").map{|t| t.strip.to_sym} rescue []
      end
    end


      # def date_to_filename(date = nil, what = :entry)
      #   date = respond_to?(:date) ? self.date : date
      #   "archive/" +
      #     case what
      #     when :entry
      #       date.strftime("%Y/%m/") + title
      #     when :month
      #       date.strftime("%Y/%B.textile")
      #     else
      #       date.strftime("%Y.textile")
      #     end
      # end
      # module_function :date_to_filename

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
          nil
        end
      end

      def basename
        File.basename(path)
      end

      def inspect
        %Q'<#{self.class.to_s.split("::").last}: #{date.to_s} "#{title}" "#{path}">'
      end

      def to_page(file = nil)
        Exporter::Page.new(self, file || "#{identifier}.html")
      end

      def written_file
        File.join(Backbitr.repository.path, "tmp", "#{identifier}.html.written")
      end

      def dir
        FUtils::repository(:htdocs, identifier[2..-1])
      end

    end

    class Post < Entry

      attr_accessor :filtered

      def parse_basename
        @time ||= Time.local(*basename[0...8].split("-").map{|s| s.to_i})
        @title ||= basename[9..-1]
        [@time, @title]
      end

      def ctime
        File.ctime(path)
      end

      def mtime
        File.mtime(path)
      end

      def need_update?(page_time)
        if page_time.kind_of?(Time)
          page_time != mtime
        else
          Time.at(File.readlines(page_time).to_s.strip.to_i) != mtime
        end
      rescue
        true
      end

      def date
        unless @date
          logwhat = nil
          @date =
            if mdate = metadata[:date]
              Time.local(*mdate.split("-").map{|s| s.to_i})
            elsif mdate = parse_basename.first
              mdate
            else
              ctime
            end
        end
        @date
      end
      alias :time :date

      def title
        parse_basename
        @title
      end

      def file_contents
        unless @file_contents
          @file_contents = File.readlines(path)
          metadata
        end
        @file_contents
      end

      # FIXME: why is a newline between metadata entries needed?
      def metadata
        unless @metadata
          @metadata = MetaData.new
          file_contents.each do |line|
            if line =~ /^# (#{MetaData::Keys.join('|')}): (.+)/
              @metadata[$1.downcase.to_sym] = $2.strip
              @file_contents.delete(line)
            end
          end
        end
        @metadata
      end

      def identifier
        (date.to_s + "-" + title).split(".").first
      end

      def body
        raw_body
      end

      def raw_body
        file_contents.join.strip
      end

      def html_body
        data = with_filter
        redcloth = RedCloth.new(data)
        redcloth.hard_breaks = false
        "<div class='bbr-entry' id='#{identifier}'>%s</div>" % redcloth.to_html
      end

      def to_nokogiri
        Nokogiri::HTML::DocumentFragment.parse(html_body)
      end
      alias :nokogiro :to_nokogiri

      def with_filter
        Filter.filter!(self)
      end

      def display_date
        date
      end

      def to_s(full = true)
        ret = ""
        text = full ? raw_body : shortened_body
        ret << title << "\n" << ("-"*title.size) << "\n" << text << "\n\n"
        ret << metadata.to_s
        ret << "\n"
        ret << "Display Date: " << display_date.to_s.green
        ret << "\n"
        ret << path << "\n"
        ret
      end

      def shortened_body
        raw_body[0..70]
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
          entry = Entry.select_for(entry)
          push(entry) if entry
        }
        self
      end

      def hash
        Hash.new{|h,k| h[k] = Entries.new(repository) }
      end

      def by_years(year = nil, &blk)
        ret = hash
        if not year
          map{|e| e.date.year}.uniq.each { |year|
            ret[year] = by_years(year)
          }
        else
          ret = Entries.new(repository).push(*select{|e| e.date.year == year})
        end
        ret
      end

      def by_months(year = nil, month = nil, &blk)
        ret = hash
        if year.nil?
          by_years.each_pair{|h,k|
            ret[h] = by_months(h)
          }
        elsif month.nil?
          by_years[year].each do |entry|
            (ret[entry.date.month] ||= Entries.new(repository)) << entry
          end
        else
          return by_years[year]
        end
        ret
      end

      def by_days(year = nil, month = nil, day = nil, &blk)
        r = hash
        months = by_months
        months.keys.each do |year|
          r[year] = hash
          months[year].each do |m, es|
            m=months[year][m] = hash
            es.each{|e|
              m[e.date.day] ||= Entries.new(repository)
              m[e.date.day] << e
            }
          end
        end
        months
      end

      def archive!
        write = proc{|str, es|
          es = Entries.new(repository).push(*es.values.flatten)
          fn = "archive/#{str}"
          es.newest.to_page(fn).make_maybe
        }

        by_months.each do |y, ye|
          write.call("#{y}.html", ye)
          by_months(y).each do |m, me|
            write.call("#{y}/#{m}.html", {m => me})
            me.map{|d| d.date.day}.uniq.each do |d|
              day_posts = by_days[y][m][d]
              write.call("#{y}/#{m}/#{d}.html", {d => day_posts})
            end
          end
        end
        true
      end

      def by_tag(tag)
        tag = tag.to_sym
        Entries.new(repository).push(*select{|entry| entry.metadata.tags.include?(tag)})
      end

      def newest(n = nil)
        all = self
        sorted = Entries.new(repository).push(*all.sort_by{|e| e.date }.reverse)
        n.kind_of?(Fixnum) ? sorted.first(n) : sorted
      end

      def first(n = 1)
        Entries.new(repository).push(*self[0..n])
      end

      def to_page(file)
        file = "#{file}.html" unless file =~ /\.html$/
        Exporter::Page.new(self, file)
      end

    end

    attr_reader :path

    include FUtils

    def newest(n = nil)
      entries.newest(n)
    end

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

    def by_tag(tag)
      tag = tag.to_sym
      Entries.new(self).push(*entries.select{|entry| entry.metadata.tags.include?(tag)})
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

    def export
      Exporter.new(self).export
    end

    def archive_export
      archive_path = File.join(path, "htdocs", 'archive')
      mkdir_p(archive_path)
      Exporter.new(self).archive_export
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
