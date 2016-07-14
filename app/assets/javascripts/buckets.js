// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var isValidationChecked = false;
var isImpressionIdChecked = false;
var variables = {};



function validateBucketForm(bucketId) {

  if (isValidationChecked == false){
    alert('Please, validate request body.');
    return false;
  }

  if (typeof(bucketId) == "undefined" && isImpressionIdChecked == false){
    alert('Please, validate impression ID.');
    return false;
  }

  var required_names = ["bucket[modular]", "bucket[http_verb]", "bucket[api_path]", "bucket[request_body]", "bucket[timeout]", "bucket[impression_id]"];
  for (var index in required_names) {
    var name = required_names[index];
      var x = document.forms["bucket-form"][name].value;
      var msg = "";
      if (x == null || x == "") {
          msg = name.replace('bucket[', '').replace(']', '') + " must be filled out";
          document.forms["bucket-form"][name].className += " input-alert";
          alert(msg)
          return false;
      }
  }
}

function allIndexOf(str) {
  var regexp = [
        "(\\[\\[.*?\\]\\])",
        "#uuid"
    ];
    var regexps = new RegExp(regexp.join("|"), "g");
    // console.log(regexps);
  var match, matches = [];

  result = str.match(regexps);


  // The matches are in elements 0 through n.
  if (result != null){
    for (var index = 0; index < result.length; index++)
    {
        matches.push(result[index]);
    }
  }

  return matches;
}

function allUniqueIndexOf(str) {
  var regexp = [
        "(\\[\\[.*?\\]\\])",
        "#uuid"
    ];
    var regexps = new RegExp(regexp.join("|"), "g");
    // console.log(regexps);
  var matches = [];

  result = str.match(regexps);


  // The matches are in elements 0 through n.
  if (result != null){
    for (var index = 0; index < result.length; index++)
    {
        matches.push(result[index]);
    }
  }

  var uniqueMatches = [];
  $.each(matches, function(i, el){
      if($.inArray(el, uniqueMatches) === -1) uniqueMatches.push(el);
  });
  return uniqueMatches;
}



function jq( myid ) {
    return "#" + myid.replace( /(#|:|\.|\[|\]|,)/g, "\\$1" );
}

$(document).ready(function() {
  $("form[name='bucket-form']").submit(function(){ //listen for submit event
    if (!isEmpty(variables)){
      $('<input />').attr('type', 'hidden')
            .attr('name', "bucket[variables]")
            .attr('value', JSON.stringify(variables))
            .appendTo("form[name='bucket-form']");
    }
    return true;
  });

  if (typeof(isEditMode) != "undefined"){
    isValidationChecked = true;
    $("#btn-reqbody-check").removeClass("btn-primary");
    $("#btn-reqbody-check").attr("disabled", "disabled");
    $("#btn-reqbody-check").text('VALID REQUEST');
  }

  function resetValidationCheck() {
    if (isValidationChecked == false) { return ; }

    isValidationChecked = false;
    $('#validate-data').empty();
    $("#btn-reqbody-check").addClass("btn-primary");
    $("#btn-reqbody-check").removeAttr("disabled");
    $("#btn-reqbody-check").text('VALIDATION CHECK');

    var requestBody = $('#bucket_request_body').val();
    rb = requestBody.replace(/(\[\[\")(.*)(\"\]\])/g, "\"\"");

    var matches = allIndexOf(rb);
    var uniqueMatches = allUniqueIndexOf(rb);

    for(var index = 0 ; index < uniqueMatches.length; index ++){
      var child = "<div id='"+uniqueMatches[index]+"'><label>"+uniqueMatches[index]+"</label><input type='text'/></div>";
      $('#validate-data').append(child);
    }
  }

  $('#bucket_request_body').on('request:changed', function() {
    resetValidationCheck();
  });

  $('#btn-reqbody-check').click(function() {
    var params = {};
    var vd = $("#validate-data > div");
    var length = vd.length;

    for (var index = 0 ; index < length ; index ++ ){
      // console.log(index);
      // console.log(vd[index].children);

      var key = vd[index].children[0].innerText;
      var value = vd[index].children[1].value;

      // console.log(key);
      // console.log(value);
      params[key] = value;
    }

    // console.log(params);

    event.preventDefault();
    if ($("#is_empty_bucket_1").is(":checked") == true){
      isValidationChecked = true;

      $("#btn-reqbody-check").removeClass("btn-primary");
      $("#btn-reqbody-check").attr("disabled", "disabled");
      $("#btn-reqbody-check").text('VALID REQUEST');
      $('#result-modal-title').text("success");
      $('#result-modal').modal();
      return;
    }

    if ($("#is_graph_query_1").is(":checked") == true){
      var requestBody = $('#bucket_request_body').val();
      var api_path = $('#bucket_api_path').val();
      rb = requestBody.replace(/(\[\[\")(.*)(\"\]\])/g, "\"\"");
      var matches = allIndexOf(rb);
      if (matches != null){
        for (var index = 0 ; index < matches.length; index ++){
          var value = $(jq(matches[index] + ' > input' )).val();
          requestBody = requestBody.replace(matches[index], value);
          variables[matches[index]] = value;
        }
        if (requestBody.trim() == "" || isValidJson(requestBody)){
          var url = "/buckets/validate/request_body";
          var params = {"body" : requestBody, "api_path" : api_path};
          $.ajax({
            type: "POST",
            url: url,
            data: params,
            dataType: 'json',
            success:function(data){
              var status = data["status"];
              var results = data["results"];

              $('#result-modal-title').text(status);

              if (isValidJson(results)){
                results = JSON.stringify(JSON.parse(results), undefined, 2);

                $('#result-modal-contents').html(syntaxHighlight(results));
              }else{
                $('#result-modal-contents').text(results);
              }

              if (status == "success"){
                isValidationChecked = true;
                $("#btn-reqbody-check").removeClass("btn-primary");
                $("#btn-reqbody-check").attr("disabled", "disabled");
                $("#btn-reqbody-check").text('VALID REQUEST');
                $('#result-modal').modal();



              }else{
                $('#result-modal').modal();
              }
            },
            error:function(e){
              alert(e.responseText);
            }
          });
        }else{
          alert('Invalid json.')
        }
      }
    }else{
      isValidationChecked = true;

      $("#btn-reqbody-check").removeClass("btn-primary");
      $("#btn-reqbody-check").attr("disabled", "disabled");
      $("#btn-reqbody-check").text('VALID REQUEST');
      $('#result-modal-title').text("success");
      $('#result-modal').modal();
    }


  });

  $( "#btn-bucket-check-duplicate").click(function(event) {
    event.preventDefault();
    var impressionId = document.forms["bucket-form"]["bucket[impression_id]"].value

      var msg = "Input impression ID";
      var clazz = "alert alert-danger";
    if (impressionId == ""){
      $("#notice-bucket-check").html(msg).addClass(clazz);
      return;
    }

    var url = "/buckets/check/"+impressionId;
      $.ajax({
        type: "GET",
        url: url,
        success:function(response){
          var result = response["isAlreadyExist"];
          if (result == "false"){
            msg = "It is good to use.";
            clazz = "alert alert-success";

            isImpressionIdChecked = true;
          }else{
            msg = "Use another impression ID.";
            clazz = "alert alert-danger";
          }
          $("#notice-bucket-check").html(msg).removeClass("alert alert-danger alert-success").addClass(clazz);
        },
        error:function(e){
            alert(e.responseText);
        }
      })

  });
});

var editor;

$(function() {
  if (!document.getElementById('btn-reqbody-check')) { return ;}

  var prettyJson = function (_jsonText) {
    /**
     // for debug
     query = '{ "select" : [[ "from", "to" ]], "id": "[[region_value]]", "from": "[[from]]", "to": [[to]], "trafic": "#uuid", "name:": #uuid, "where": "_to not in [[FILTER]]" }';
     _jsonText = query;
    */
    try {
      // escape variable in quote(".*")
      var jsonText = _jsonText.replace(/(".+?")/g, function(g0, g1) {
        return g0
          .replace(/\[\[(.+?)\]\]/g, "_[_[$1]_]_")
          .replace(/#uuid/g, '_$uuid_');
      });

      // else
      jsonText = jsonText
        .replace(/#uuid/g, '"=$uuid="')
        .replace(/\[\[([^"]+?)\]\]/g, '"=[=[$1]=]="');

      var objJson = JSON.parse(jsonText);
      var prettyJson = JSON.stringify(objJson, null, 4);

      return prettyJson
        .replace(/_\$uuid_/g, "#uuid")
        .replace(/"=\$uuid="/g, "#uuid")
        .replace(/_\[_\[(.+?)\]_\]_/g, "[[$1]]")
        .replace(/"=\[=\[(.+?)\]=\]="/g, '[[$1]]');

    } catch (e) {
      console.error("Json Prettify failed: ", e);
      console.log(jsonText);
      return _jsonText;
    }
  };

  ace.config.set("workerPath", ".");
  var elHiddenText = $('#bucket_request_body');

  editor = ace.edit("ace_code");
  editor.container.style.opacity = "";
  editor.session.setUseWorker(false);

  editor.session.setMode("ace/mode/json");
  // editor.setTheme("ace/theme/monokai");
  editor.setAutoScrollEditorIntoView(true);
  editor.session.setTabSize(4);
  editor.setShowPrintMargin(false);

  // set value from server
  var query = elHiddenText.val();

  editor.setValue(prettyJson(query));
  editor.clearSelection();

  // sync editor with hidden Text
  editor.session.on('change', function () {
    elHiddenText.val(editor.getSession().getValue());
    $('#bucket_request_body').trigger("request:changed");
  });

  ace.config.loadModule("ace/ext/emmet", function() {
    ace.require("ace/lib/net").loadScript("http://cloud9ide.github.io/emmet-core/emmet.js", function() {
      editor.setOption("enableEmmet", true);
    });
  });

  ace.config.loadModule("ace/ext/language_tools", function() {
    editor.setOptions({
      enableSnippets: true,
      enableBasicAutocompletion: true
    });
  });

});
