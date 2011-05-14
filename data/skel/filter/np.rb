#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


module Backbitr
  class Metadata < Filter

    rule /^/

    def apply(body, rule)
      kws = {
        :date => post.date,
        :tags => post.metadata.tags.map{|t| t}.join(", ")
      }
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
