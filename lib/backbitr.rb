# -*- coding: utf-8 -*-
#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "pp"
require "fileutils"

require "rubygems"
require "nokogiri"
require "RedCloth"
require "term/ansicolor"
require "haml"

module Backbitr

  Source  = File.dirname(File.dirname(File.expand_path(__FILE__)))

  def Source.join(*args)
    File.join(Source, *args)
  end

  Dir["#{Source.join("lib/backbitr/builtins")}/*.rb"].each{ |builtin| require builtin}

  $: << File.join(Source, 'lib')

  require "backbitr/exceptions"
  require "backbitr/log"
  require "backbitr/futils"
  require "backbitr/filter"
  require "backbitr/repository"
  require "backbitr/export"

  Version = [0, 0, 1, 'pre']

  LOG_DEF = 0
  LOG_DEB = 5

  DefaultRepository = "~/.bbr"

  class Config < Hash
    def initialize
      super{|h,k| h[k] = Config.new}
    end
  end

  class << self
    attr_reader :repository

    def sync(file = nil)
      file ||= File.join(repository.path, 'rsync.txt')
      if File.exist?(file)
        `sh #{file}`
      else
        warn "#{file} does not exist"
      end
    end

    def version
      suffx = if Version.size > 3 then Version.last end
      "backbitr-#{Version[0...3].join(".")}#{suffx and "-#{suffx}"}"
    end

    def repository=(repos)
      @repository = File.expand_path(repos)
    end

    def repository
      self.repository = DefaultRepository unless @repository
      Repository.new(@repository)
    end

    def config
      @config ||= Config.new
    end

    def [](obj)
      config[obj]
    end

    def []=(obj, k)
      config[obj] = k
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
