#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbitr

  class LOG
    class << self
      def <<(os)
        os = [LOG_DEF, os] unless os.kind_of?(Array)
        puts "|> #{os.first}  #{os.last}"
      end
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
