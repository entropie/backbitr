module Backbitr

  module FUtils

    def repository(*a)
      File.join(Backbitr.repository.path, *a.map{|a| a.to_s})
    end
    module_function :repository

    def mkdir_p(arg)
      return if File.exist?(arg)
      LOG << "mkdir_p '#{arg.to_s}'"
      FileUtils.mkdir_p(arg)
    end

    def copy_r(src, dest)
      LOG << "cp -r '#{src}' '#{dest}'"
      FileUtils.cp_r(src, dest)
    end

    def write(file, mode = 'w+')
      LOG << "writing to #{file} (#{mode})"
      File.open(file, mode) { |fp|
        yield fp
      }
      #LOG << [LOG_DEB, "written #{File.size(file)}bytes"]
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
