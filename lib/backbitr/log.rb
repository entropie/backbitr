module Backbitr

  class LOG
    class << self
      def <<(os)
        os = [LOG_DEF, os] unless os.kind_of?(Array)
        puts "|> ".red + os.first.to_s.red.bold + " #{os.last}".white
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
