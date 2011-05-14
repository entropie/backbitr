#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


module Backbitr::Filter
  class NP < Filter

    rule nil

    def apply(body, rule)
      body << "\n<div class='np'><span class='uimp'>NP(vlc):</span> <em>Stephen King - Die Arena - 38 - Die Arena</em>"
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
