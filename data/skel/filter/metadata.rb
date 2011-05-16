#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


module Backbitr
  class Metadata < Filter

    rule /^/

    def apply(body, rule)
      tags = post.metadata.tags
      kws = {
        :date => post.date,
        :tags => "Filed In: <ul>" + tags.map{|t|
          "<li><a href='/tag/#{t}' class='awesome orange small'>#{t}</a></li>"
        }.join + "</ul>"
      }
      kws.delete(:tags) if tags.empty?

      mds = kws.map{|k, v| "<div class='#{k}'>#{v}</div>\n"}.join
      md = "<div class='bbr-metadata'>%s</div>" % mds
      body = md << "\n\n" << body
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
