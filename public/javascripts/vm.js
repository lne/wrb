var topIndex = 500;
var currenttmid = null;

function closeTerminal(id){
  $(id).style.display = "none";
  return false;
}

function mousedownActionOfTerm(){
  this.style.zIndex = topIndex++;
}

function setFocusToHelp(){
  $('help').style.zIndex = topIndex++;
}

function setFocus(eid){
  currenttmid = eid.gsub('editor','term');
  $(currenttmid).style.zIndex = topIndex++;
}

function run(eid){
  $(eid).update(editAreaLoader.getValue(eid));
}

function shareCode(eid){
  code =  editAreaLoader.getValue(eid);
  bnid = eid.gsub('editor','basename');
  formid = eid.gsub('editor','share');
  res = ""
  $(formid).request({
    parameters: { 'code': editAreaLoader.getValue(eid),
                  'basename': $(bnid).value },
    asynchronous: false,
    onSuccess: function(req){
      res = req.responseText;
    }
  });
  return res;
}

function execCode(eid){
  formid = eid.gsub('editor','main');
  rid   = eid.gsub('editor','result');
  $(eid).update(editAreaLoader.getValue(eid));
  $(rid).update('');
  $(formid).request({
    parameters: { 'code': editAreaLoader.getValue(eid) },
  });
}
function loadCode(eid){
  listfilesid = eid.gsub('editor','listfiles');
  ldid = eid.gsub('editor','load');
  $(listfilesid).request({
    method: 'get',
    onSuccess: function(req){
      $(ldid).show();
    }
  });
}
function codeLoadCancel(eid){
  ldid = eid.gsub('editor','load');
  $(ldid).hide();
  return false;
}
function codeLoadOK(eid){
  slid = eid.gsub('editor','select');
  i = $(slid).selectedIndex;
  fullname = $(slid).options[i].value
  if(fullname == ""){
    return false;
  } 
  formid = eid.gsub('editor','filelist');
  ldid = eid.gsub('editor','load');
  fnid = eid.gsub('editor','fullname');
  bnid = eid.gsub('editor','basename');
  tmtlnmid = eid.gsub('editor','tlname');
  $(formid).request({
   // parameters: { 'code': editAreaLoader.getValue(eid) },
    method: 'get',
    onSuccess: function(req){
      editAreaLoader.setValue(eid, req.responseText);
      $(fnid).value = fullname;
      $(tmtlnmid).update($(slid).options[i].text);
      $(bnid).value = $(slid).options[i].text;
      $(ldid).hide();
    }
  });
}
function saveCode(eid, code){
  bnid = eid.gsub('editor','basename');
  fnid = eid.gsub('editor','fullname');
  svid = eid.gsub('editor','save');
  tmtlnmid = eid.gsub('editor','tmtlname');
  if(($(bnid).value == "") && ($(fnid).value == "")) {
    $(svid).show();
    $(bnid).focus();
    return false;
  } 
  $(svid).hide();
  formid = eid.gsub('editor','info');
  $(formid).request({
    parameters: { 'code': code },
    onSuccess: function(req){
    }
  });
}

function changeVersion(eid, ver){
  mnid = eid.gsub('editor','main');
  versionField = $(mnid).select('[name="version"]')[0];
  versionField.value = ver;
}

function codeSaveCancel(eid){
  bnid = eid.gsub('editor','basename');
  svid = eid.gsub('editor','save');
  $(bnid).value = "";
  $(svid).hide();
  return false;
}

function codeSaveOK(eid){
  bnid = eid.gsub('editor','basename');
  svid = eid.gsub('editor','save');
  if($(bnid).value == ""){
    return false;
  }
  formid = eid.gsub('editor','info');
  code = editAreaLoader.getValue(eid);
  $(formid).request({
    parameters: { 'code': editAreaLoader.getValue(eid) },
    onComplete: function(){
      $(svid).hide();
    }
  });
}

function checkFilename(field){
  v = field.value.gsub(/^\.+/, '');
  v = v.gsub(/[^\w\.\_]/, '');
  field.value = v;
}

/********************************
         shortcut keys
*********************************/
