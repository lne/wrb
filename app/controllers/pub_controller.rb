class PubController < ApplicationController
  def show
    raise "invalid id" if (params[:id].to_s.blank?)
    name = params[:id].to_s
    name.gsub!(/%(25)*3D/, '=')
    name = Base64.decode64(name)
    path = File.join(JAILP, name)
    if File.exist?(path)
      render :text => FORMATTER.output_file(File.open(path), params[:id], 1)
    else
      raise "file not found => #{path}"
    end
  rescue => e
    logger.error "[pub][error] => #{e.class}: #{e.message}\n" + e.backtrace.join("\n")
    render :status => 404, :nothing => true
  end

  def result
    name = params[:id].to_s
    name.gsub('%3D', '=')
    name = Base64.decode64(name)
    path = File.join(JAILP, name)
    if File.exist?(path)
      code = ""
      File.open(path) {|f| code = f.read}
<<<<<<< HEAD
      res193 = exec(code, '1.9.3') rescue nil
      res192 = exec(code, '1.9.2') rescue nil
      res187 = exec(code, '1.8.7') rescue nil
=======
      res19 = exec(code, '1.9') rescue nil
      res18 = exec(code, '1.8') rescue nil
>>>>>>> 7ed92960be6667c2d27fbc03efa9ba921b2ac5df
      t =<<TEM
<html><head></head>
<body style="border:0;margin:0;">
</body>
<<<<<<< HEAD
<div style="margin:2px;;color:gray;font-family:Verdana,Arial,sans-serif;font-size: 10pt;">result: (by ruby 1.9.3)</div>
<div style="padding-left:5px;background-color:#F4F4F4;">
<pre style="margin:0;">#{res193}</pre>
</div>

<div style="margin:2px;;color:gray;font-family:Verdana,Arial,sans-serif;font-size: 10pt;">result: (by ruby 1.9.2)</div>
<div style="padding-left:5px;background-color:#F4F4F4;">
<pre style="margin:0;">#{res192}</pre>
=======
<div style="margin:2px;;color:gray;font-family:Verdana,Arial,sans-serif;font-size: 10pt;">result: (by ruby 1.9.2)</div>
<div style="padding-left:5px;background-color:#F4F4F4;">
<pre style="margin:0;">#{res19}</pre>
>>>>>>> 7ed92960be6667c2d27fbc03efa9ba921b2ac5df
</div>

<div style="margin:2px;margin-top:10px;color:gray;font-family:Verdana,Arial,sans-serif;font-size: 10pt;">result: (by ruby 1.8.7)</div>
<div style="padding-left:5px;background-color:#F4F4F4;">
<<<<<<< HEAD
<pre style="margin:0;">#{res187}</pre>
=======
<pre style="margin:0;">#{res18}</pre>
>>>>>>> 7ed92960be6667c2d27fbc03efa9ba921b2ac5df
</div>
</html>
</html>
TEM
      render :text => t
    else
      render :nothing => true
    end
  end
end
