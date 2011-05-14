# -*- coding: utf-8 -*-
#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbitr

  class Filter
    class << self

      def load_filter!
        LOG << [LOG_DEB, "Loading Filter... "]
        Dir[File.join(Backbitr.repository.path, 'filter') + "/*.rb"].each do |filter|
          LOG << [LOG_DEB, "  Filter add: #{filter}"]
          require filter
        end
        @filter_loaded = true
      end

      def filter!(post)
        load_filter! unless @filter_loaded
        LOG << [LOG_DEB, "Invoking filters for: #{post.title}"]
        Filter.all.inject(""){|m, filter|
          filter.new(post).apply_all
        }
      end

      def filter
        @filter ||= []
      end

      def all
        filter
      end

      def inherited(claz)
        filter << claz
      end

      def rules
        @rules ||= []
      end

      def rule(obj)
        self.rules << obj
      end
    end

    attr_reader :post

    def initialize(post)
      @post = post
    end

    def nokogiri(data)
      Nokogiri::HTML::DocumentFragment.parse(data)
    end

    def apply_rules
      post.filtered = post.body.to_s
      self.class.rules.inject(post.filtered) do |m, r|
        LOG << [LOG_DEB, "  Filter: #{self.class.to_s.split("::").last}"]
        apply(m, r)
      end
    end

    def apply_all
      apply_rules
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
