require "date"
[ :MONTHNAMES, :DAYNAMES, :ABBR_MONTHNAMES, :ABBR_DAYNAMES ].each do |const|
  Date.send(:remove_const, const)
  Time.send(:remove_const, const) rescue nil
end

Date::MONTHNAMES = [nil] + %w(Januar Februar März April Mai Juni Juli August September Oktober November Dezember)
Date::DAYNAMES = %w(Sonntag Montag Dienstag Mittwoch Donnerstag Freitag Samstag)
Date::ABBR_MONTHNAMES = [nil] + %w(Jan Feb März Apr Mai Jun Jul Aug Sep Okt Nov Dez)
Date::ABBR_DAYNAMES = %w(So Mo Di Mi Do Fr Sa)
Time::MONTHNAMES = Date::MONTHNAMES
Time::DAYNAMES = Date::DAYNAMES
Time::ABBR_MONTHNAMES = Date::ABBR_MONTHNAMES
Time::ABBR_DAYNAMES = Date::ABBR_DAYNAMES


class Time
  def to_s(what = :def)
    fmtstr =
      case what
      when :def
        "%Y-%m-%d"
      end
    strftime(fmtstr)
  end

  alias_method :strftime_old, :strftime
  def strftime(format)
    format = format.dup
    format.gsub!(/%a/, Date::ABBR_DAYNAMES[self.wday])
    format.gsub!(/%A/, Date::DAYNAMES[self.wday])
    format.gsub!(/%b/, Date::ABBR_MONTHNAMES[self.mon])
    format.gsub!(/%B/, Date::MONTHNAMES[self.mon])
    self.strftime_old(format)
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
