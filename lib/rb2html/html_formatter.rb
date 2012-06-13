# -*- encoding: UTF-8 -*-
# rb2html
# Copyright (c) 2001, 2004, 2006 HORIKAWA Hisashi. All rights reserved.
#     http://www.nslabs.jp/
#     mailto:vzw00011@nifty.ne.jp

module Rb2HTML
=begin
body {
  width: 500px;
  margin: 0 auto;
  border-left: solid 1px #000;
  border-right: solid 1px #000;
  border-left: solid 3px #4DB56A;
}
=end

  # HTMLに整形するためのフォーマッタ
  # Source2Htmlおよびそのサブクラスから呼び出される
  class HtmlLayout
    def file_start(filename)
      filebasename = File.basename(filename)[0..-18] rescue 'unknown.rb'
      return <<"EOF"
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
            "http://www.w3.org/TR/html4/loose.dtd">
<html lang="ja">
<head>
  <title>source of #{filebasename}</title>
  <link rel="shortcut icon" href="favicon.ico" />
  <style type="text/css">
body {
}
.cf {
  font-family: Verdana,Arial,sans-serif;
  font-size: 10pt;
}
div {
/*  background-color:#e8e8e8;
  width: 100%;*/
}
div.source ol {
  margin-top: 0;
  background-color:#e8e8e8;
  list-style-position: outside;
  line-height:1.0;
  font-family:monospace;
  font-size:10pt;
}
div.source ol.nolineno {
  list-style-type:none;
}
div.source li {
  margin-left: 10px;
  padding-left: 8px;
  background-color:#f4f4f4;
  border-left: solid 3px #8CBEFE;
  white-space:pre;
}

.source .literal { color:#660066; }
.source .com     { color:#B37800; font-style:oblique;}
.source .kw      { color:#FF35F5; }
.source .num     { color:#590000; }
.source .str     { color:#C84B00; }
.source .op      { color:#002832; }
.source .sym     { color:#0086B3; }
.source .ivar    { color:blue; }
.source .cnm     { color:green; }
.source .con     { color:green; }
.source .reg     { color:red; }
.source .cvar    { color:red; }
.source .gvar    { color:red; }
.source .preprocessor { color:purple; }

img{ border:0; }

body { min-width:500px; }
#bf_share span{
  margin-top:-5px;
}
</style>
</head>
<body>
<div> 
  <a href="/" style="height:55px;">
    <img alt='wrb' src='/images/wrb64.png' height='50' width='50' title='wrb' />
    <img alt='wrb' src='/images/description.png' height='30' title='wrb' style="margin-left:20px;margin-bottom:5px;" />
  </a>
</div>
<div style="border-top:solid 1px #C8D5FF;border-bottom:solid 1px #C8D5FF;margin-top:3px;padding:3px;">
  <div style="height:17px;width:75px;position:absolute;">
    <span class="cf" style="margin:0px;color:#F9A269;font-weight:bold;">Share to:</span>
  </div>
  <div style="height:25px;margin-left:80px;margin-top:1px;">
    <script type="text/javascript" charset="utf-8">
      (function(){
        var _w = 55, _h = 24;
        var param = {
          url:location.href,
          type:'2',
          count:'0',
          appkey:'4241452851',
          title:'I write a #ruby code by #wrb: ',
          pic:'', 
          ralateUid:'1883584437',
          rnd:new Date().valueOf()
        }
        var temp = [];
        for( var p in param ){
          temp.push(p + '=' + encodeURIComponent( param[p] || '' ) )
        }
        document.write('<iframe allowTransparency="true" frameborder="0" scrolling="no" src="http://hits.sinajs.cn/A1/weiboshare.html?' + temp.join('&') + '" width="'+ _w+'" height="'+_h+'"></iframe>')
      })()
    </script>
    
    <a href="javascript:void(0)" onclick="postToWb();return false;" style="height:32px;font-size:18px;line-height:32px;float:left;width:55px;">
      <img src="http://v.t.qq.com/share/images/s/weiboicon24.png" align="absmiddle" border="0" alt="share to QQ" title="转播到腾讯微博"/>
    </a>
    <script type="text/javascript">
      function postToWb(){
      var _t ='I write a ruby code by wrb:';
      var _url = encodeURIComponent(document.location);
      var _assname = encodeURI("24771790");
      var _appkey = encodeURI("42d1a993fab2475490c8cf99709b2870");
      var _pic = encodeURI('');
      var _site = 'http://wrb.rubychina.info';
      var _u = 'http://v.t.qq.com/share/share.php?url='+_url+'&appkey='+_appkey+'&site='+_site+'&pic='+_pic+'&title='+_t+'&assname='+_assname;
      window.open( _u,'', 'width=700, height=680, top=0, left=0, toolbar=no, menubar=no, scrollbars=no, location=yes, resizable=no, status=no' );
      }
    </script>

    <script src="http://platform.twitter.com/widgets.js" type="text/javascript"></script>
    <span style="vertical-align:top">
      <a href="http://twitter.com/share" class="twitter-share-button"
        data-related="weidongfeng:The author of wrb"
        data-text="I write a #ruby code by #wrb: "
        data-count="none"
        data-counturl="wrb.rubychina.info">Tweet
      </a>
    </span>
  </div>
</div>
<p style="margin-left:2px;margin-top:4px;margin-bottom:2px;color:gray;text-align:left;" class="cf">
  <span style="margin-right:10px;">ruby code:</span>
  <a href="/show?target=#{Base64.encode64(filename).chomp}" style="height:55px;color:red;font-weight:bold;">click here to edit this code
  </a>
</p>
EOF
  end

  def file_end(id)
    res =<<RESULT
<div>
  <iframe src="http://wrb.rubychina.info/p/i?id=#{id}" style="border:0;width:100%;height:500px;">
  </iframe>
</div>
RESULT
    return res + "</body></html>\n"
  end

  # 
  def start_formatted(start_lno)
    return <<EOF
<div class="source"><ol #{start_lno && start_lno >= 1 ?
          'start="' + start_lno.to_s + '"' : 'class="nolineno"' }>
EOF
  end

  def end_formatted()
    '</ol></div>'
  end

  def begin_literal; '<span class="literal">' end
  def end_literal; '</span>' end

  def begin_comment; '<span class="comment">' end
  def end_comment; '</span>' end

  def begin_keyword; '<span class="keyword">' end
  def end_keyword; '</span>' end
      
  # for C/C++
  def begin_preprocessor
    '<span class="preprocessor">'
  end
  def end_preprocessor
    '</span>'
  end
end

end # of Rb2HTML
