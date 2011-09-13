# -*- coding:utf-8 -*-

require 'strscan'

class StringScanner
  def gets(bytes)
    raise TypeError if !bytes.is_a?(Integer)
    r = peek(bytes)
    self.pos += bytes
    return r
  end
end

module Rb2HTML
  class Token
    attr_accessor :symbol, :text
    def initialize(sym, str)
      @symbol = sym
      @text = str
    end
    
    def ==(t)
      return @symbol == t.symbol && @text == t.text
    end
    
    def inspect
      return "t(:#{@symbol.to_s}, #{@text.inspect})"
    end
  end

  class PatternLexer
    def parse source
      @scanner = StringScanner.new source
      @parsed = []
      @cur = Token.new(nil, '')
    end

    private

    # マッチしたらブロックを呼び出す
    def match(patterns)
      patterns.each {|pat, sym, opt|
        if opt && opt[:only_after]
          if opt[:only_after].is_a?(Symbol)
            next if @last_kind != opt[:only_after]
          elsif opt[:only_after].is_a?(Array)
            next if !opt[:only_after].include?(@last_kind)
          else
            raise "internal error"
          end
        end

        r = @scanner.scan(pat)
        if r
          yield sym, r
          return true
        end
      }
      return false
    end

    # 必要に応じてサブクラスで上書きする
    def add_token token
      @parsed << token
      if token.symbol != :space && token.symbol != :comment
        @last_kind = token.symbol
      end
    end

    def flush_token token = nil
      if @cur.text != ''
        add_token(Token.new(@cur.symbol, @cur.text))
        @cur.text = ''
      end
      add_token(token) if token
    end
  end
end # of module Rb2HTML

