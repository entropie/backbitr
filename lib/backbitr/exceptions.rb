#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbitr

  module Ex
    class BBRError < Exception; end

    class ExportError < BBRError; end
    class TargetNotFound < ExportError; end
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
