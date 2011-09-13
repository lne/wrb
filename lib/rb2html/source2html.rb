# -*- coding:utf-8 -*-

# rb2html
# Copyright (c) 2001, 2004, 2006 HORIKAWA Hisashi. All rights reserved.
#     http://www.nslabs.jp/
#     mailto:vzw00011@nifty.ne.jp

require 'rb2html/rb2html-sub'
require 'rb2html/rb2html-conf.rb'

module Rb2HTML
  
  # 各プログラミング言語を整形するベースクラス
  class Source2Html
    def initialize layout, lexer, lang_name
      @filename = ''
      @fo = layout
      @lexer = lexer
      @html_rules = RB2HTML_CONFIG[lang_name] || raise
    end
    
    # <head>要素なども出力する。
    def output_file(io_or_str, id = "", start_lineno = 1)
      io, @filename = get_io_fn(io_or_str)
      @fileid = id
      @result = @fo.file_start(@filename)
      @result << @fo.start_formatted(start_lineno)
      format_body(io, start_lineno)
      @result << @fo.end_formatted() << @fo.file_end(@fileid)
      return @result
    end

    # <pre>とその中身だけ出力する。
    # start_lineno  開始行番号。-1だと行番号を出力しない。
    def format_code(io_or_str, start_lineno = -1)
      io, @filename = get_io_fn(io_or_str)

      @result = @fo.start_formatted(start_lineno)
      format_body(io, start_lineno)
      @result << @fo.end_formatted()
      return @result
    end

    private
    def get_io_fn(io_or_str)
      if defined?(io_or_str.read)
        io = io_or_str
      else
        require 'stringio'
        io = StringIO.new(io_or_str.chomp)
      end
      return [io, defined?(io.path) ? io.path : nil]
    end

    #  行頭文字を出力
    def out_lno(first = false)
      @result << " </li>" if !first
      @lno += 1 if @lno >= 0
      @result << "<li>"
    end
    
    def find_rule(sym)
      opt = @html_rules
      begin
        opt[:rules].each {|rule|
          if (rule[0].is_a?(Symbol) && sym == rule[0]) ||
              (rule[1].is_a?(Array) && rule[0].include?(sym))
            return rule[1]
          end
        }
      end while opt[:base] && opt = RB2HTML_CONFIG[opt[:base]]
      return nil
    end

    # join() の逆関数
    # "hoge\n" => ["hoge", ""]
    def split_str(s, sep)
      if (i = s.index(sep))
        return [s[0, i]] + split_str(s[(i + sep.length)..-1], sep)
      else
        return [s]
      end
    end

    # ソースコード部分を整形
    def format_body(io, start_lineno)
      raise "no lexer" if !@lexer

      @lno = (start_lineno || 0) - 1
      ary = @lexer.parse(io.read)
      out_lno true
      ary.each {|token|
        attrs = find_rule(token.symbol)
        # tokenは複数行にまたがることがある
        ts = split_str(token.text, "\n")
        ts.each_with_index {|line, i|
          out_lno if i != 0
          if line != ""
            if attrs
              tag = '<span'
              attrs.each {|k, v|
                tag << " #{k}=\"#{v}\""
              }
              tag << '>'
              @result << tag << Rb2HTML.html_escape(line) << '</span>'
            else
              @result << Rb2HTML.html_escape(line)
            end
          end
        }
      }
    end
  end # of class Source2Html
end # of module Rb2HTML
