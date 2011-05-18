#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


require "open-uri"

module Backbitr
  class Gallery < Filter

    rule /^textile_gallery: (.*)$/i

    GALLERY_BASE_URL = "http://78.46.106.73/~entropy/dogs/"
    HEIGHT = 92
    WIDTH  = 92

    def url(url = "")
      GALLERY_BASE_URL + url.to_s
    end

    def apply(body, rule)
      if body =~ rule
        body.gsub!(rule) do |match|
          textile = "%s.textile" % match.gsub("textile_gallery: ", '')
          list = open(url(textile))
          html = list.readlines.select{|e| not e.strip.empty?}.map{|l|
            "<img src='%s' height='#{HEIGHT}' width='#{WIDTH}' />" % url(l[3..-1].strip[0..-2])
          }
          LOG << [LOG_DEB, "   gallery (#{textile}) contains #{html.size} image(s)"]
          ("<div class='bbr-textile-gallery'>%s</div>" % html[0..6].join).to_s
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
