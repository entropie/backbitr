# -*- coding: undecided -*-
#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbitr

  class Exporter

    class Page

      include FUtils

      attr_reader :entries, :file
      attr_accessor :layout_file

      def initialize(entries, file)
        @entries = entries
        @entries = [@entries] unless @entries.kind_of?(Array)
        @file = file
      end

      def layout_file
        @layout_file or "layout.html"
      end

      def directory
        @directory ||= File.join(Backbitr.repository.path, "htdocs")
      end

      def layout
        Nokogiri::HTML.parse(File.readlines(File.join(directory, layout_file)).join)
      end

      def modify_base_path!(skel)
        fs = file.split("/").size
        if fs != 1
          href = "../"*(fs-1)
          LOG << "Modifying <base> to #{href} for #{file}"
          skel.at_css("head base")["href"] = href
        end
      end

      def make(lyout = nil, default = nil)
        skel = lyout || layout
        modify_base_path!(skel)
        LOG << "    Exporting #{entries.size} entries to #{@file}..."
        wa = written_at
        entries.each do |post|
          doc = post.to_nokogiri
          if default.nil? and target = post.metadata.target
            if node = skel.at_css("#bbr-content #bbr-content-%s" % target)
              node.add_child(doc)
            else
              raise Ex::TargetNotFound, "'#{target}' in metadata declared but not found in document"
            end
          elsif node = skel.at_css(default || "#bbr-content > .default")
            node.add_child(doc)
          else
            raise "dont know where to add post, no default given (#{post.path})"
          end
          LOG << [LOG_DEB, "added '#{post.title}' (#{post.date}) to #{default or target || 'default'} node"]
        end

        entries.each do |e|
          FileUtils.touch(e.path)
        end if entries.size == 1

        write_written_at!
        mkdir_p(File.dirname(op_file))
        write(op_file){|fp|
          fp.puts skel.to_html
        }
        true
      end

      def make_maybe(*opts)
        if need_update?
          LOG << [LOG_DEB, "update #{file} forced"]
          make(*opts)
          yield self if block_given?
        else
          LOG << [LOG_DEB, "skipping page #{file}"]
        end
        self
      end

      def normalize_file(nfile)
        nfile.gsub(/\//, "_")
      end

      def written_file(nfile = nil)
        nf = nfile || file
        nf = normalize_file(nf)
        File.join(Backbitr.repository.path, "tmp", "#{nf}.written")
      end

      def write_written_at!
        ts = Time.now
        File.open(written_file, 'w+'){|fp| fp.puts(ts.to_i)}
      end

      def need_update?
        if written_at != mtime
          true
        elsif entries.any?{|e| e.need_update?(e.written_file) }
          true
        else
          false
        end
      end

      def op_file
        File.join(directory, file)
      end

      def exist?
        File.exist?(op_file)
      end

      def created_at
        exist? and File.ctime(op_file)
      end

      def modified_at
        exist? and written_at
      end

      def written_at
        Time.at(File.readlines(written_file).to_s.strip.to_i) if exist?
      rescue
        nil
      end

      def mtime
        File.mtime(File.join(directory, file)) rescue Time.now
      end

    end

    include FUtils

    attr_reader :repository

    def initialize(repos = nil)
      @repository = repos || Backbitr.repository
    end

    def directory(*args)
      @directory ||= File.join(@repository.path, "htdocs", *args.map{|a| a.to_s})
    end

    def export
      LOG << "Starting to export to #{directory}"
      make_layout

      LOG << "Making index..."
      index_entries = repository.newest(10)
      index_entries.to_page("index").make_maybe

      LOG << "Making individual pages..."
      tags = []
      repository.entries.each do |e|
        page = e.to_page
        page.make_maybe(nil, "#bbr-perma") do |pg|
          tags.push(*pg.entries[0].metadata.tags)
        end
      end

      unless tags.empty?
        mkdir_p(File.join(directory, "t"))
        LOG << "Making Tags (#{tags.join(",")})..."
        tags.uniq.each do |tag|
          repository.by_tag(tag).newest.to_page("t/#{tag}.html").make
        end
      end
      nil
    end

    def archive_export
      LOG << "Starting to export the archive to #{directory(:archive)}"
      repository.entries.archive!
    end

    def make_layout(file = "layout/layout.haml")
      layout_src = File.join(@repository.path, file)
      layout_target = "#{directory}/layout.html"
      layout_cnt = File.readlines(layout_src).join
      LOG << "  Layout: #{layout_src} => #{layout_target} (#{layout_cnt.size}Bytes)"
      body = Haml::Engine.new(layout_cnt).render
      write(layout_target){|fp| fp.puts body }
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
