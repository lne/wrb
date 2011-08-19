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
               "597px"
             else
               "600px"
             end
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
