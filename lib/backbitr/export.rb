#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbitr

  class Exporter

    class Page

      include FUtils

      attr_reader :entries, :file

      def initialize(entries, file)
        @entries = entries
        @entries = [@entries] unless @entries.kind_of?(Array)
        @file = file
      end

      def directory
        @directory ||= File.join(Backbitr.repository.path, "htdocs")
      end

      def layout
        Nokogiri::HTML.parse(File.readlines(File.join(directory, "layout.html")).join)
      end

      def make(lyout = nil, default = nil)
        skel = lyout || layout
        LOG << "Exporting #{entries.size} entries to #{@file}..."
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
            raise "dont know where to add post, no default given"
          end
          LOG << [LOG_DEB, "  added '#{post.title}' (#{post.date}) to #{default or target || 'default'} node"]
        end

        op_file = File.join(directory, file)
        write(op_file){|fp|
          fp.puts skel.to_html
        }
        true
      end

    end

    include FUtils

    attr_reader :repository

    def initialize(repos = nil)
      @repository = repos || Backbitr.repository
    end

    def directory
      @directory ||= File.join(@repository.path, "htdocs")
    end

    def export
      LOG << "Starting to export to #{directory}"
      make_layout

      index_entries = repository.newest(10)
      Page.new(index_entries, "index.html").make

      # pages for permalink
      LOG << "Making pages..."
      repository.entries.each do |e|
        Page.new(e, "#{e.identifier}.html").make(nil, "#bbr-perma")
      end
      nil
    end

    def make_layout(file = "layout/layout.haml")
      layout_src = File.join(@repository.path, file)
      layout_target = "#{directory}/layout.html"
      layout_cnt = File.readlines(layout_src).join
      body = Haml::Engine.new(layout_cnt).render
      write(layout_target){|fp| fp.puts body }
      LOG << "  Creating HTML from #{layout_src} (-> #{layout_target})"
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
