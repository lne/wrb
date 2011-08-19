class WelcomeController < ApplicationController
  def index
  end

  def notfound
    redirect_to '/'
  end

  def help
  end
  def helpimp
    render :partial => 'helpimp'
  end

  def wri
    agent = request.headers['HTTP_USER_AGENT']
    @width = case agent.downcase
             when /linux/, /version\/5.*safari/, /chrome/
               "572px"
             else
               "575px"
             end
    @wri_usage =<<USAGE
= Wri usage

Wri is the same as ri command. Input the keyword and click 'Go'! 

The keyword can be:

  Class | Class::method | Class#method | Class.method | method

All class names may be abbreviated to their minimum unambiguous form.
If a name is ambiguous, all valid options will be listed.

A '.' matches either class or instance methods, while #method
matches only instance and ::method matches only class methods.

Keyword examples:

    Array
    Array#&
    Array#+
    Array#<<
    Array.[]
    Array.compact!

    String.=~
    String.tableize
USAGE
  end

  def ri
    t = params['target'].dup
    if t.empty?
      render :nothing=> true 
      return
    end
    t.gsub!(/[\*\>\<\&\(\)\{\}\"\'\@\`\.\;\:\\\/]/) { |m| p m; '\\'+m }
logger.error t
    @result = `/usr/local/bin/ri -f rdoc -T #{t}`
    @result = "Error: Nothing known about #{params['target']} " if @result.blank?
logger.info @result
  end
end
