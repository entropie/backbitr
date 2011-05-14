# -*- coding: utf-8 -*-
#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbitr

  class Filter
    class << self

      def filter!(post)
        LOG << "Invoking filters for: #{post.title}"
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

    def apply_rules
      post.filtered = post.body.to_s
      self.class.rules.inject(post.filtered) do |m, r|
        LOG << "  Filter: #{r}"
        apply(m, r)
      end
    end

    def apply_all
      apply_rules
    end

    class NP < Filter

      rule /$/m

      def apply(body, rule)
        body.gsub(rule, 'NP(vlc): Götz Widmann - Zoellner vom Vollzug abhalten auf der A4 - Drogen')
      end
    end

    class NPA < Filter

      rule /^/m

      def apply(body, rule)
        body.gsub(rule, 'start')
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
