# -*- coding:utf-8 -*-

# rb2html
# Copyright (c) 2001, 2004, 2006 HORIKAWA Hisashi. All rights reserved.
#     http://www.nslabs.jp/
#     mailto:vzw00011@nifty.ne.jp


if !$__RB2HTML_RUBY_LEXER__
$__RB2HTML_RUBY_LEXER__ = true

require 'rb2html/pattern_lexer'

module Rb2HTML
  class RubyLexer < PatternLexer

    VAR_PAT = /([_a-zA-Z]\w*)/
    OP_PAT = /\*\*|<<|>>|<=>|==|<=|>=|===|=~|[-+*%~&|^<>]/

    # '/', '%'は演算子かリテラルか
    PLACE_LITERAL = [:operator, :delimiter, :bracket_open, :eol]
    PLACE_OP = [:numeric, :constant, :instance_variable, :class_variable, 
                :global_variable, 
                :symbol, :string, :array, :dot, :bracket_close, :regex]

    RUBY_PATTERNS = [
    [/0x[0-9A-Fa-f]+/, :numeric],

    # ok: 1 1.1 1_1e1      error: '.1' '1.' '1.e1' 11_e1 1__1e1 11e
    [/-?[0-9](_?[0-9]+)*(\.[0-9](_?[0-9]+)*)?([eE][-+]?[0-9]+)?/, :numeric],

    # ok: _? A_!  error: _!? A
    [/defined\?/, :keyword],
    [/#{VAR_PAT}[!?]/, :method],

    # ok: _ __ _0   error: a! _a! a? _a?
    [/[_a-z]\w*/, :ident],  # ローカル変数またはメソッド
  
    # _から始まるのは定数ではない。
    [/[A-Z]\w*(::[A-Z]\w*)*/, :class_name, {:only_after => :class}],
    [/[A-Z]\w*/, :constant],

    # ok: @_ @__ @A    error: @ @1 @A!
    [/@#{VAR_PAT}/, :instance_variable],

    # ok: @@A @@_      error: @@ @@1
    [/@@#{VAR_PAT}/, :class_variable],
  
    # ok: $1 $_          error: $ $1a
    [/\$(#{VAR_PAT}|[0-9]+|[_&~`'+])/, :global_variable],  #`

    # ok: :foo  :__!       error: ':1'
    [/:#{VAR_PAT}[!?]?(?==>)/, :symbol],  # ハッシュで:foo=>1は":foo"だけ
    [/:#{VAR_PAT}[!?=]?/, :symbol],
  
    # ok: :+  :[]         error ':+='  ':!~' :!  :=  :&& :?  :[
    [/:(\/|#{OP_PAT}|\[\]=|\[\]|\+@|-@)/, :symbol],

    # ok: <<1 <<1_    
    [/<</, :operator, {:only_after => :class}],
    [/<<-?\w+/, :here_mark],
    [/<<-?"\w+"/, :here_mark],  #"
    [/<<-?\'\w+'/, :here_mark], #'
    [/<<-?`\w+`/, :here_mark],  #`

    # :percent_noteは内部でstringなどに変換
    # ok: %r_foo_    error: %rzfooz
    [/%[Qqrwsx]?[^a-zA-Z0-9\s]/, :percent_note],

    # '/' は、内部で正規表現か演算子かを判定する
    [/=>/, :delimiter],
    [/[=!]|#{OP_PAT}|\+=|-=|\*=|\/=|&&|\|\||!=|!~|\.\.|\.\.\./, :operator],

    [/\?\\C-./, :numeric],
    [/\?\\./, :numeric],
    [/\?[^\s]/, :numeric],
  
    [/'([^'\\]|\n|\\.)*'/, :string], #'
    [/`[^`]*`/, :string], #` TODO: 
    [/#.*/, :comment],

    [/[,;]/, :delimiter],
    [/[(\[{]/, :bracket_open],
    [/[)\]}]/, :bracket_close],
    [/[ \t]+/, :space],
    [/\.|::/, :dot],
    [/\r?\n|\r/, :eol]
    ]

    # :identのときに検査する => :keyword
    KEYWORDS = %w(end else case ensure module elsif def rescue not then yield for
      self false retry return true if defined? super undef break in do
      nil until unless or next when redo and begin __LINE__ class __FILE__
      END BEGIN while alias)

    def parse source_, partial = false
      super(source_)
      @last_kind = :begin_of_source
      @here_end = []
      @bracket_stack = []
      @state = 1
      while !@scanner.eos?
        case @state
        when 1
          state_1
          break if partial && @to_exit
        when 2
          state_2
        when 4
          state_4
        when 6
          state_6
        when 8
          state_8
        else
          raise "internal error"
        end
      end
      flush_token
      return @parsed
    end
    
    def pos
      return @scanner ? @scanner.pos : nil
    end

    private

    SEP_CHARS = {
      "(" => ")",
      "[" => "]",
      "{" => "}",
      "<" => ">"}

    def get_end_re(ch)
      return Regexp.escape(SEP_CHARS[ch] ? SEP_CHARS[ch] : ch)
    end
    
    def percent_body
      r = @cur.text[-1, 1]
      return @scanner.scan(/([^#{get_end_re(r)}]|\n)*#{get_end_re(r)}/)
    end

    def set_state(sym, new_state, str = nil)
      @cur.symbol = sym
      @cur.text = str if str
      @state = new_state
    end

    # '%' 演算子または%記法
    def do_percent_note(mark)
      flush_token
      @cur.text = mark
      case mark[1, 1]
      when 'Q' # ダブルクォート文字列
        set_state(:string, 2)
        @sep_re = get_end_re(@cur.text[2, 1])
      when 'q', 'x' # シングルクォート文字列
        @cur.symbol = :string
        @cur.text << percent_body
        flush_token
      when 'r' # 正規表現
        @sep_re = get_end_re(@cur.text[2, 1])
        set_state(:regex, 4)
      when 'w' # 文字列の配列 (式展開なし)
        @cur.symbol = :array
        @cur.text << percent_body
        flush_token
      when 's' # シンボル (式展開なし)
        @cur.symbol = :symbol
        @cur.text << percent_body
        flush_token
      else  # 文字列
        @cur.symbol = :string
        @cur.text << percent_body
        flush_token
      end
    end
    
    # 地の文
    def state_1
      if @scanner.beginning_of_line?
        if @here_end.size > 0
          set_state(:string, 6)
          return
        end
        if (r = @scanner.scan(/=begin[ \t\n]/))
          set_state(:comment, 8, r)
          return
        end
      end

      match(RUBY_PATTERNS) {|sym, r|
        case sym
        when :ident
          if @parsed[-1] && @parsed[-1].symbol == :dot
            flush_token Token.new(:method, r)
            return
          else
            if (i = KEYWORDS.index(r))
              if r == "class"
                flush_token Token.new(:class, r)
              else
                flush_token Token.new(:keyword, r)
              end
              return
            end
          end
        when :here_mark
          here_indent = r[2] == ?- ? true : false
          @here_end << [here_indent, r[2..-1].gsub(/["'`-]/, '')]
        when :percent_note
          if PLACE_OP.include?(@last_kind) ||
                 (@parsed[-1] && @parsed[-1].symbol == :ident)
            @scanner.unscan
            flush_token Token.new(:operator, @scanner.getch)
          elsif PLACE_LITERAL.include?(@last_kind)
            do_percent_note(r)
          else
            do_percent_note(r)  # TODO: 精度の向上
          end
          return
        when :bracket_open
          @bracket_stack.push(r) if r == '{'
        when :bracket_close
          if r == '}'
            @to_exit = true if @bracket_stack.empty?
            @bracket_stack.pop
          end
        end
        flush_token Token.new(sym, r)
        return
      }
      
      case @scanner.peek(1)
      when '"' # ダブルクォート文字列
        flush_token
        @sep_re = Regexp.escape('"')
        @scanner.pos += 1
        set_state(:string, 2, '"')
        return
      when '/' # 正規表現？
        flush_token
        if PLACE_OP.include?(@last_kind) ||
            (@parsed[-1] && @parsed[-1].symbol == :ident)
          flush_token Token.new(:operator, @scanner.getch)
        elsif PLACE_LITERAL.include?(@last_kind)
          @sep_re = Regexp.escape('/')
          @scanner.pos += 1
          set_state(:regex, 4, '/')
        else
          if @scanner.peek(2) == '/ '     # heuristic
            flush_token Token.new(:operator, @scanner.getch)
          else
            @sep_re = Regexp.escape('/')
            @scanner.pos += 1
            set_state(:regex, 4, '/')
          end
        end
        return
      end

      # other
      @cur.symbol = :other
      @cur.text << @scanner.getch
    end # of state_1()
    
    # ダブルクォート文字列
    def state_2
      case
      when @scanner.scan(/#\{/)
        # 式展開
        sub = RubyLexer.new
        r = sub.parse(@scanner.string[@scanner.pos..-1], true)
        @cur.text << '#{' << @scanner.gets(sub.pos)
      when (r = @scanner.scan(/\\./))
        @cur.text << r
      when (r = @scanner.scan(/#{@sep_re}/))
        @cur.text << r
        flush_token
        @state = 1
      else
        @cur.text << @scanner.getch
      end
    end
  
    # 正規表現
    def state_4
      case
      when @scanner.scan(/#\{/)
        # 式展開
        sub = RubyLexer.new
        r = sub.parse(@scanner.string[@scanner.pos..-1], true)
        @cur.text << '#{' << @scanner.gets(sub.pos)
      when (r = @scanner.scan(/\\./))
        @cur.text << r
      when (r = @scanner.scan(/#{@sep_re}[ioxmnesu]*/))
        @cur.text << r
        flush_token
        @state = 1
      else
        @cur.text << @scanner.getch
      end
    end
  
    # ヒアドキュメント
    def state_6
      r = @scanner.scan(/.*\n/)
      if (@here_end[0][0] ?
              r.index(@here_end[0][1]) : r.index(@here_end[0][1]) == 0)
        @cur.text << r.chomp
        flush_token Token.new(:eol, "\n")
        @here_end.shift
        @state = 1
      else
        @cur.text << r
      end
    end
  
    # =begin...=endコメント
    def state_8
      r = @scanner.scan(/.*\n/)
      if r.index('=end') == 0
        @cur.text << r
        flush_token
        @state = 1
      else
        @cur.text << r
      end
    end
  end
end # module Rb2HTML

end
