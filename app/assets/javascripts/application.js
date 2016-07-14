// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//

//= require syntax-highlighter-rails/shCore
//= require syntax-highlighter-rails/shBrushBash
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require bootstrap-multiselect
//= require ace-rails-ap
//= require_tree .
//= colResizable-1.5.source
//= jquery.tablesorter

window.vm = {};
function replaceAll(str, searchStr, replaceStr) {
    return str.split(searchStr).join(replaceStr);
}

function isEmpty(obj) {
    for(var prop in obj) {
        if(obj.hasOwnProperty(prop))
            return false;
    }
    return true;
}

function setHeight() {
    var body = document.body;
    var html = document.documentElement;

  var height = Math.max( body.scrollHeight, body.offsetHeight,
                       html.clientHeight, html.scrollHeight, html.offsetHeight );

  $('#cover').css('width', '100vw');
  $('#cover').css('height', height);
};

$(window).resize(function() {
  setHeight();
});

function objToJson(obj){
  try {
    return JSON.stringify(obj)
  }catch (e) {
        return obj;
  }

}

function stringToJsonObj(str){
  try {
    return JSON.parse(str);
  }catch (e) {
    return null;
  }
}
function isValidJson(json) {
    try {
        JSON.parse(json);
        return true;
    } catch (e) {
        return false;
    }
}

function jsonPrettyfy(json){
  if (isValidJson(json)){
    json = JSON.stringify(JSON.parse(json), undefined, 2);
  }else{
    json = json.replace(/("#uuid")/g, '"$uuid"');
    json = json.replace(/(#uuid)/g, '"$1"');
    json = json.replace(/(\[\[\")(.*)(\"\]\])/g, '"@$2@"');
    json = json.replace(/(\"\[\[)(.*)(\]\]\")/g, '"&$2&"');
    json = json.replace(/([^=][\s]*)(\[\[.*?\]\])/g, '$1"$2"');
    json = JSON.stringify(json, undefined, 2);
    json = json.replace(/"(#uuid)"/g, '$1').replace(/"(\$uuid)"/g, '"#uuid"').replace(/"(\[\[.*?\]\])"/g, '$1').replace(/"@(.*)@"/g, '[["$1"]]').replace(/"&(.*)&"/g, '[[$1]]');
  }
}


function generateUUID() {
    var d = new Date().getTime();
    var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = (d + Math.random()*16)%16 | 0;
        d = Math.floor(d/16);
        return (c=='x' ? r : (r&0x3|0x8)).toString(16);
    });
    return uuid;
};


$(document).ready(function() {
  $(".tablesorter").tablesorter();
  $(".search").keyup(function () {
    var searchTerm = $(".search").val();
    var listItem = $('.results tbody').children('tr');
    var searchSplit = searchTerm.replace(/ /g, "'):containsi('")

  $.extend($.expr[':'], {'containsi': function(elem, i, match, array){
        return (elem.textContent || elem.innerText || '').toLowerCase().indexOf((match[3] || "").toLowerCase()) >= 0;
    }
  });

  $(".results tbody tr").not(":containsi('" + searchSplit + "')").each(function(e){
    $(this).attr('visible','false');
  });

  $(".results tbody tr:containsi('" + searchSplit + "')").each(function(e){
    $(this).attr('visible','true');
  });

  var jobCount = $('.results tbody tr[visible="true"]').length;
    $('.counter').text(jobCount + ' item');

  if(jobCount == '0') {$('.no-result').show();}
    else {$('.no-result').hide();}
      });
});


function validateForm(names, namePrefix, model) {
  var required_names = names;
  for (var index in required_names) {
    var name = required_names[index];
      var x = document.forms[model+"-form"][name].value;

      var msg = ""
      if (x == null || x == "") {
          msg = name.replace(namePrefix+'[', '').replace(']', '') + " must be filled out";
          document.forms[model+"-form"][name].className += " input-alert";
          alert(msg)
          return false;
      }
  }
}

function syntaxHighlight(json) {
  json = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  return json.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, function (match) {
    var cls = 'number';
    if (/^"/.test(match)) {
      if (/:$/.test(match)) {
        cls = 'key';
      } else {
        cls = 'string';
      }
    } else if (/true|false/.test(match)) {
      cls = 'boolean';
    } else if (/null/.test(match)) {
      cls = 'null';
    }
    return '<span class="' + cls + '">' + match + '</span>';
  });
};
