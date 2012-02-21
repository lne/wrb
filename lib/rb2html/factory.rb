# -*- coding:utf-8 -*-

# rb2html
# Copyright (c) 2001, 2004, 2006 HORIKAWA Hisashi. All rights reserved.
#     http://www.nslabs.jp/
#     mailto:vzw00011@nifty.ne.jp

require 'rb2html/html_formatter'
require 'rb2html/source2html'

module Rb2HTML
  class Factory
    TARGETS = {
      :ruby => {
        :ext => ['.rb'], :conv => ['ruby_lexer.rb', 'RubyLexer']
      }
    }

    # 入力
    #     lang 言語名 or 拡張子
    def Factory.get_formatter lang
      raise TypeError if !lang.is_a?(String)
      TARGETS.each {|lang_name, opt|
        if lang == lang_name.to_s || opt[:ext].include?(lang.downcase)
          require 'rb2html/' + opt[:conv][0]
          return Source2Html.new(HtmlLayout.new, 
                                   module_eval(opt[:conv][1]).new,
                                   lang_name)
        end
      }
      return nil
    end
  end
end # of module Rb2HTML

