class TerminalController < ApplicationController

  before_filter :parse_id, :except => [:create]

  # show terminal
  def show
  end

  # initialize terminal
  def create
    agent = request.headers['HTTP_USER_AGENT']
logger.error agent
    @width = case agent.downcase
             when /linux/, /version\/5.*safari/, /chrome/
               "497px"
             else
               "500px"
             end
    @id = Time.now.strftime("%y%m%d%H%M%S#{'%03d' % rand(999)}")
    @version = params['version']
    logger.info "[create] #{@version} - #{@id}"
  end

  # update file list before loading file
  def listfiles
    @files = session['files'].split(',')
  rescue Exception => e
    logger.warn "[session][files] => #{session['files']}"
    render :status => 403, :nothing => true
  end

  # load code
  def load 
    code = '' 
    File.open(File.join(JAILS, params['filename'])) {|f| code = f.read}
  rescue Exception => e
    #TODO deal with error
    logger.error "[save][error] => #{e.class}: #{e.message}\n" + e.backtrace.join("\n")
  ensure
    render :text => code
  end

  def share
    basename = params['basename'].to_s.chomp!
    basename = 'sample.rb' if basename.blank?
    fullname = basename + Time.now.strftime(".%y%m%d%H%M%S.#{'%03d' % rand(999)}")
    code = params['code']
    raise "code is too long" if code.size > 100.kilobyte
    File.open(File.join(JAILP, fullname), 'w') {|f| f.puts code}
    @pub_url = url_for(:controller => 'pub', :action => 'show', :only_path => true, :id => Base64.encode64(fullname).chomp)
logger.error @pub_url
    render :text => @pub_url
  rescue Exception => e
    #TODO deal with error
    logger.error "[save][error] => #{e.class}: #{e.message}\n" + e.backtrace.join("\n")
    @fullname = nil
    render :status => 500, :text => e.message
  end

  # save code
  def save
    @fullname = params['fullname'].to_s
    if @fullname.size == 0
      basename = params['basename'].to_s
      basename = 'sample.rb' if basename.size == 0
      basename += '.rb' unless File.extname(basename) == '.rb'
      @fullname = basename + Time.now.strftime(".%y%m%d%H%M%S.#{'%03d' % rand(999)}")
    end
    
    code = params['code']
    raise "code is too long" if code.size > 100.kilobyte
    File.open(File.join(JAILS, @fullname), 'w') {|f| f.puts code}
    if session.has_key?('files')
      session['files'] += ',' + @fullname unless session['files'].split(',').include?(@fullname)
    else
      session['files'] = @fullname
    end
  rescue Exception => e
    #TODO deal with error
    logger.error "[save][error] => #{e.class}: #{e.message}\n" + e.backtrace.join("\n")
    @fullname = nil
    render :status => 500, :text => e.message
  end

  # do update terminal
  def update
  end

  # do close terminal
  def destory
  end

  def interpret
    #TODO check length
    code =  params['code']
    version =  params['version'] || '1.9'
    @result = exec(code, version)
    logger.info @result
    if session.has_key?('test')
      session['test'] += 1
    else
      session['test'] = 1
    end
    logger.info session.inspect
  end

  private

  def parse_id
    @id = params['id']
    logger.info @id
  end
end
