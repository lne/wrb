var topIndex = 500;
var currenttmid = null;

function closeTerminal(id) {
  $(id).style.display = "none";
  return false;
}

function mousedownActionOfTerm() {
  this.style.zIndex = topIndex++;
/*
function toTopLayer() {
  numid = this.id.split('_').pop();
  if (numid.match(/^\d+$/)) {
    currenttmid = "term_".concat(numid);
    $(currenttmid).style.zIndex = topIndex++;
  }
*/
}
function setFocus(eid) {
  currenttmid = eid.gsub('editor','term');
  $(currenttmid).style.zIndex = topIndex++;
}

function run(eid) {
  $(eid).update(editAreaLoader.getValue(eid));
}

function execCode(eid) {
  formid = eid.gsub('editor','main');
  $(eid).update(editAreaLoader.getValue(eid));
  $(formid).request({
    parameters: { 'code': editAreaLoader.getValue(eid) },
  });
}

function loadCode(eid) {
  listfilesid = eid.gsub('editor','listfiles');
  ldid = eid.gsub('editor','load');
  $(listfilesid).request({
    method: 'get',
    onSuccess: function(req) {
      $(ldid).show();
    }
  });
}

function codeLoadCancel(eid) {
  ldid = eid.gsub('editor','load');
  $(ldid).hide();
  return false;
}

function codeLoadOK(eid) {
  slid = eid.gsub('editor','select');
  i = $(slid).selectedIndex;
  if($(slid).options[i].value == "") {
    return false;
  } 
  formid = eid.gsub('editor','filelist');
  ldid = eid.gsub('editor','load');
  $(formid).request({
   // parameters: { 'code': editAreaLoader.getValue(eid) },
    method: 'get',
    onComplete: function(req) {
      editAreaLoader.setValue(eid, req.responseText);
      $(ldid).hide();
    }
  });
}

function saveCode(eid, code) {
  bnid = eid.gsub('editor','basename');
  fnid = eid.gsub('editor','fullname');
  svid = eid.gsub('editor','save');
  if(($(bnid).value == "") && ($(fnid).value == "")) {
    $(svid).show();
    return false;
  } 
  $(svid).hide();
  formid = eid.gsub('editor','info');
  $(formid).request({
    parameters: { 'code': code }
  });
}

function codeSaveCancel(eid) {
  bnid = eid.gsub('editor','basename');
  svid = eid.gsub('editor','save');
  $(bnid).value = "";
  $(svid).hide();
  return false;
}

function codeSaveOK(eid) {
  bnid = eid.gsub('editor','basename');
  svid = eid.gsub('editor','save');
  if($(bnid).value == "") {
    return false;
  }
  formid = eid.gsub('editor','info');
  code = editAreaLoader.getValue(eid);
  $(formid).request({
    parameters: { 'code': editAreaLoader.getValue(eid) },
    onComplete: function() {
      $(svid).hide();
    }
  });
}

function checkFilename(field) {
  v = field.value.gsub(/^\.+/, '');
  v = v.gsub(/[^\w\.\_]/, '');
  field.value = v;
}

/********************************
         shortcut keys
*********************************/
