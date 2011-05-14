#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbitr

  class Exporter
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
      make_page(repository.entries.first(10), 'index.html')
      nil
    end

    def to_file(file)
      write(file) {|fp| fp.puts}
    end

    def from_file(file)
      File.join(directory, file)
    end

    def layout
      Nokogiri::HTML.parse(File.readlines(File.join(directory, "layout.html")).join)
    end

    def make_page(entries, page)
      skel = layout
      LOG << "Exporting #{entries.size} entries to #{page}..."
      entries.each do |post|
        doc = post.to_nokogiri
        if target = post.metadata.target
          if node = skel.at_css("#bbr-content #bbr-content-%s" % target)
            node.add_child(doc)
          elsif node = skel.at_css("#bbr-content > .default" % target)
            node.add_child(doc)
          else
            raise Ex::TargetNotFound, "'#{target}' in metadata declared but not found in document"
          end
        else
          skel.at_css("#bbr-content div:last").add_child(doc)
        end
        LOG << [LOG_DEB, "  added '#{post.title}' (#{post.date}) to #{target || 'default'} node"]
      end
      write(File.join(directory, page)){|fp|
        fp.puts skel.to_html
      }
      true
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
