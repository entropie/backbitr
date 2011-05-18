#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "open-uri"

module Backbitr
  class Youtube < Filter

    rule /^youtube: (.*)$/i

    def to_html(embed = nil)
      if not embed
        "<p class='bbr-youtube'><a href='#{url}'><img alt='Youtube.com Video: ' src='http://i.ytimg.com/vi/#{@ytid}/0.jpg'/></a></p>"
      else
        %Q'<p class="bbr-youtube-i"><iframe title="YouTube video player" width="480" height="390" src="http://www.youtube.com/embed/#{@ytid}" frameborder="0" allowfullscreen></iframe>'
      end
    end

    def url
      @url ||= "http://youtube.com/watch?v=#{@ytid}"
    end

    def get_title
      @title ||= ::Nokogiri::HTML.parse(open(url)).at_css("#eow-title").text.strip
    rescue
      p $!
      '<no title>'
    end

    def apply(body, rule)
      if body =~ rule
        body.gsub!(rule) do |match|
          @ytid = if match =~ /https?:\/\// then match[/v=(\w+)/, 1] else match end
          LOG << [LOG_DEB, "   applying #{match} -> #{@ytid}"]
          to_html(true)
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
