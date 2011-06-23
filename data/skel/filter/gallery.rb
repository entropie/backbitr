#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


require "open-uri"
require "timeout"

module Backbitr
  # http://coffeescripter.com/code/ad-gallery/
  class Gallery < Filter

    rule /^textile_gallery: (.*)$/i

    GALLERY_BASE_URL = "http://78.46.106.73/~entropy/dogs/"
    HEIGHT = 92
    WIDTH  = 92

    def url(url = "")
      GALLERY_BASE_URL + url.to_s
    end

    def html_body
      %Q'<div class="bbr-textile-gallery">'+
        %Q'<div class="ad-gallery"><div class="ad-image-wrapper"></div><div class="ad-controls"></div>' +
        %Q'<div class="ad-nav"><div class="ad-thumbs"><ul class="ad-thumb-list">%s</ul></div>' +
        %Q'</div></div>'
    end

    def apply(body, rule)
      if body =~ rule
        body.gsub!(rule) do |match|
          textile = "%s.textile" % match.gsub("textile_gallery: ", '')
          begin
            Timeout.timeout(5) do
              list = open(url(textile))
            end
          rescue Timeout::Error
            str = "!!! no connected to endpoint (server down)"
            LOG << str
            return str
          end

          html = list.readlines.select{|e| not e.strip.empty?}.map{|l|
            url = url(l[3..-1].strip[0..-2])
            "<li><a href='%s'><img src='%s' height='#{HEIGHT}' width='#{WIDTH}' /></a></li>" % [url, url]
          }
          LOG << [LOG_DEB, "   gallery (#{textile}) contains #{html.size} image(s)"]
          gallery_html = "%s</div>" % html.join
          html_body % gallery_html
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
