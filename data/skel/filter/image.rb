#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "rubygems"
require "net/http"
require "uri"
require "cgi"
require "httpclient"
require "pp"
require "json"
require "open-uri"


module Backbitr
  class ImageSrc

    TARGET = "http://78.46.106.73:8300/api/upload"

    include FUtils

    attr_reader :url, :post

    def initialize(url, post)
      @url = url
      @post = post
    end

    def filename
      File.basename(url)
    end

    def path_to_original(prefix = nil)
      if prefix
        File.join(post.dir, "#{prefix}_#{filename}")
      else
        File.join(post.dir, filename)
      end
    end

    def fetch_and_safe
      fc = open(url).read
      mkdir_p(post.dir)
      write(path_to_original){|fp| fp.write(fc)}

      pdir = FUtils::repository(:posts, post.identifier[2..-1])
      mkdir_p(pdir)
      write(File.join(pdir, filename)){|fp| fp.write(fc)}
    end

    def exist?
      org_exist? and sizes_exist?
    end

    def org_exist?
      File.exist?(path_to_original)
    end

    def sizes_exist?
      [:medium, :thumbnail].map{|s| send(s)}.all?{|a| File.exist?(a)}
    end

    def make_sizes
      ret = JSON.parse(HTTPClient.
                       post(TARGET, { :name => filename, :file => File.new(path_to_original)}).body.content)
      ret.each_pair{|what, image|
        imagefc = HTTPClient.get("http://78.46.106.73:8300#{image}").body.content
        new_file = File.join(post.dir, "#{what}_#{filename}")
        write(new_file){|fp| fp.write(imagefc)}
      }
    end

    def fetch!
      if exist?
        LOG << "Image: #{filename} exist, skipping"
      else
        LOG << "Image: #{filename} not exist, fetching and modifying..."
        fetch_and_safe
        make_sizes
        sizes_exist?
      end
    end

    def thumbnail
      path_to_original(:thumbnail)
    end

    def path
      path_to_original
    end

    def medium
      path_to_original(:medium)
    end

    def http_path(which = nil)
      which = nil if which == :large
      str = which ? "#{which}_" : ''
      File.join(post.identifier[2..-1], str+filename)
    end

    def width(what = nil)
      case what.to_sym
      when :medium then 320
      when :thumbnail then 48
      else
        nil
      end
    end

    def height(what)
      width(what)
    end

    def to_html(which = nil, opts = {})
      ostr = opts.map{|o| '%s="%s"' % o}.join(" ")
      %Q'<a class="bbr-imglink" href="#{http_path(:orginal)}">' + 
        %Q'<img #{ostr} src="#{http_path(which)}" width="#{width(which)}" height="#{height(which)}" /></a>'
    end
  end
end


module Backbitr
  class Image < Filter
    rule />>> img\((.*)\)/

    def apply(body, rule)
      if body =~ rule
        body.gsub!(rule) do |match|
          img, *args = $1.split(",")
          args = Filter.parse_opts(args)
          image = ImageSrc.new(img, post)
          image.fetch!
          image.to_html(args.delete(:size) || :thumbnail, args)
        end
      end
      body
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
