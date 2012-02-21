
# -*- encoding:utf-8 -*-
# rb2html
# Copyright (c) 2001, 2004, 2006 HORIKAWA Hisashi. All rights reserved.
#     http://www.nslabs.jp/
#     mailto:vzw00011@nifty.ne.jp

class String
  def shift
    r = self[0, 1]
    self[0, 1] = ''
    return r
  end
end

module Rb2HTML
  # エスケープする
  def html_escape(s)
    if s
      r = s.dup
      r.gsub! '&', '&amp;'
      r.gsub! '<', '&lt;'
      r.gsub! '>', '&gt;'
      r.gsub! '"', '&quot;'
      r.gsub! "'", '&#39;'
      r
    else
      nil
    end
  end
  module_function :html_escape
end

