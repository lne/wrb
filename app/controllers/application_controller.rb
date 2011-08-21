class ApplicationController < ActionController::Base
  protect_from_forgery

  def exec(code, version, filename = 'line')
    out_r, out_w = IO.pipe
    err_r, err_w = IO.pipe
    tmpname = process_tempfile(code) do |tmpfilename|
      exec_with_restriction(tmpfilename, version, out_w, err_w)
    end
    out_w.close
    err_w.close
    res = out_r.read
    if res.size > 10.kilobyte
      res = "<wrb system limitation> result is over than 10 KB.\n"
    end
    res += err_r.read
    logger.debug "result: #{res}"
    res.gsub(/\/tmp\/#{tmpname}/, filename)
  ensure
    logger.debug "close io"
    out_w.close unless out_w.closed?
    err_w.close unless err_w.closed?
    out_r.close unless out_r.closed?
    err_r.close unless err_r.closed?
  end

  def exec_with_retry(code, version, filename = 'line')
    10.times do
      res = exec_without_retry(code, version, filename = 'line')
      return res unless res=~/sudo:\sunknown\suid:\s501/
      logger.info "retry"
    end
    ""
  end

  alias_method_chain :exec, :retry

  private

  def process_tempfile(data, name = '')
    tmpfolder = "#{JAILR}/tmp"
    file = Tempfile.new(name.to_s, tmpfolder)
    logger.debug "create tempfile => #{file.path}"
    file.puts data
    file.close
    logger.debug `ls -l #{tmpfolder}`
    yield(File.basename(file.path)) if block_given?
    File.basename(file.path)
  ensure
    file.close! if file # close and delete tempfile
  end

  def exec_with_restriction(name, ver, out, err)
    pid      = nil
    ruby     = '/bin/ruby-' + (ver == '1.8' ? '1.8.7' : '1.9.2')
    filepath = File.join('/tmp', name)
    cmd      = "sudo /usr/sbin/chroot #{JAILR} #{ruby} #{filepath}"
    env      = { "PATH"=>"/usr/bin:/bin" }
    options  = { :chdir => '/', :out => out, :err => err, :unsetenv_others => true }
    options[:rlimit_core]   = [0, 50.megabyte]
    options[:rlimit_cpu]    = 60          # second
    options[:rlimit_nofile] = 100         # count
    options[:rlimit_nproc]  = 100         # count
    options[:rlimit_data]   = 50.megabyte # second
    options[:rlimit_fsize]  = 50.megabyte # second
    options[:rlimit_stack]  = 50.megabyte # second
    options[:rlimit_as]     = 50.megabyte # second
    options[:rlimit_rss]    = 50.megabyte # second
    timeout(TIMEOUT) do
      logger.info "spawn #{cmd.inspect}"
      pid = spawn(env, cmd, options)
      logger.info "new process created  => #{pid}"
      Process.waitpid(pid)
      logger.info "new process finished => #{pid}"
    end
  rescue Timeout::Error
    logger.debug "[excute][warn] timeout."
    err.puts "<wrb system limitation> execution is not finished in #{TIMEOUT}s."
  rescue Exception => e
    msg = "[excute][error] => #{e.class}: #{e.message}\n" + e.backtrace[0..9].join("\n")
    logger.info msg
    err.puts "<wrb system error> #{e.class}: #{e.message}"
    begin
      logger.warn "kill process => #{pid}"
      Process.kill(9, pid) if pid
    rescue Exception => e
      logger.warn "error occurred when kill #{pid} => #{e.class}: #{e.message}"
      logger.warn e.backtrace[0..9].join("\n")
      logger.warn "send kill process => #{pid}"
      `kill -9 #{pid}` if pid.to_i > 0
      res = `ps aux | grep #{pid}`
      logger.warn "ps result => #{res}"
    end
  end
end
