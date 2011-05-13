#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbitr

  module FUtils
    def mkdir_p(arg)
      LOG << "mkdir_p '#{arg.to_s}'"
      FileUtils.mkdir_p(arg)
    end

    def copy_r(src, dest)
      LOG << "cp -r '#{src}' '#{dest}'"
      FileUtils.cp_r(src, dest)
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
