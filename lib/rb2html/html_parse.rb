# -*- coding:utf-8 -*-

# HTML raw parser
# XMLにも対応してるっぽい感じで攻める。

if !$__RB2HTML_HTML_RAW_PARSER__
$__RB2HTML_HTML_RAW_PARSER__ = true

require 'rb2html/pattern_lexer'

module Rb2HTML
  class HTMLRawParser < PatternLexer

    NCName = /[A-Za-z_][A-Za-z0-9._-]*/
    QName = /#{NCName}(:#{NCName})?/
    
    # partial
    #     真のとき、ルート要素の終わりですぐに戻る
    def parse source, partial = false, &block
      super(source)
      @s = @scanner # TODO:
      @node_stack = []
      @state = :TEXT

      while !@s.eos?
        case @state
        when :TEXT
          state_text
          break if partial && @to_exit
        when :COMMENT
          state_comment
        when :decl
          state_decl
        when :STAG
          state_stag
        when :ETAG
          state_etag
        else
          raise
        end
      end
      flush_token
      return !partial ? @parsed : [@parsed, @s.rest]
    end
    
    # 地の文
    def state_text
      case
      when @s.scan(/<!--/)
        flush_token Token.new(:comment_start, @s.matched)
        @state = :COMMENT
      when @s.scan(/<\?.*?\?>/)
        flush_token Token.new(:pi, @s.matched)
      when @s.scan(/(<%=?\s*)((.|\n)*?)%>/)
        flush_token Token.new(:eruby, @s[1])
        require 'rb2html/ruby_lexer.rb'
        ary = RubyLexer.new.parse(@s[2])
        ary.each {|e|
          flush_token e
        }
        flush_token Token.new(:eruby, '%>')
      when @s.scan(/<!\[CDATA\[.*?\]\]>/)
        flush_token Token.new(:cdata, @s.matched)
      when @s.scan(/<!DOCTYPE\s+/i)   # HTMLでは小文字も可
        flush_token Token.new(:doctype_start, @s.matched)
        @state = :decl
      when @s.scan(/<(#{QName})/)
        flush_token Token.new(:stago, '<')
        flush_token Token.new(:tag_name, @s[1])
        @node_stack << @s[1]
        @state = :STAG
      when @s.scan(/<\/(#{QName})(\s*)>/)
        flush_token Token.new(:etago, '</')
        flush_token Token.new(:tag_name, @s[1])
        flush_token Token.new(:space, @s[3]) if @s[3] && @s[3] != ''
        flush_token Token.new(:etagc, '>')
        begin
          x = @node_stack.pop
        end while x && x != @s[1]
        @to_exit = true if @node_stack.empty?
      else
        @cur.symbol = :other
        @cur.text << @s.getch
      end
    end
    
    def state_comment
      case
      when @s.scan(/.*?--/m)
        flush_token Token.new(:comment, @s.matched)
        @state = :decl
      else
        raise
      end
    end
    
    def state_decl
      case
      when @s.scan(/--/)
        flush_token Token.new(:comment_start, @s.matched)
        @state = :COMMENT
      when @s.scan(/>/)
        flush_token Token.new(:decl_end, '>')
        @state = :TEXT
      else
        @cur.symbol = :decl
        @cur.text << @s.getch
      end
    end

    # タグ名の後ろの空白
    def state_stag
      case
      when @s.scan(/(#{QName})(\s*)=/m)
        flush_token Token.new(:att_name, @s[1])
        flush_token Token.new(:space, @s[3]) if @s[3] && @s[3] != ''
        flush_token Token.new(:eq, '=')
      when @s.scan(/(['"]).*?\1/m)
        flush_token Token.new(:att_value, @s.matched)
      when @s.scan(/\w+/)
        flush_token Token.new(:att_value, @s.matched)
      when @s.scan(/>/)
        flush_token Token.new(:stagc, '>')
        if @node_stack.last.downcase == 'script' && @s.scan(/((.|\n)*)<\//)
          require 'rb2html/javascript_lexer'
          ary = JavaScriptLexer.new.parse(@s[1])
          ary.each {|e|
            flush_token e
          }
          @s.pos = @s.pos - 2
        end
        @state = :TEXT
      when @s.scan(/\/>/)
        flush_token Token.new(:empty, '/>')
        @state = :TEXT

        @node_stack.pop
        @to_exit = true if @node_stack.empty?
      when @s.scan(/\s+/)
        flush_token Token.new(:space, @s.matched)
      else
        @cur.symbol = :other
        @cur.text << @s.getch
      end
    end
  end
end

end  # $__RB2HTML_HTML_RAW_PARSER__

