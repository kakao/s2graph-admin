// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function getExperiment(id){
  var jqxhr = $.get( "/experiments/"+id+"/detail", function(data) {
    $('#experimet-contents-inner').html(data);


    var jsonArray = $('.json-body');
    _.each(jsonArray, function(elem) {
      var json = elem.innerText;
      jsonPrettyfy(json)
      elem.innerHTML = syntaxHighlight(json);
    });

    Highcharts.createElement('link', {
      href: '//fonts.googleapis.com/css?family=Unica+One',
      rel: 'stylesheet',
      type: 'text/css'
    }, null, document.getElementsByTagName('head')[0]);

    $('#ctr-chart').highcharts(vm.chartData);

    // Add validatio
    $('.action_types').on('submit', function validateDate() {
      var datepickers = $('.datepicker');
      _.each(datepickers, function(elem) {
        var date = datepickers.val();
        var dtRegex = new RegExp(/\b\d{4}[\/-]\d{1,2}[\/-]\d{1,2}\b/);
        if (!dtRegex.test(date)){
          alert('Invalid data format');
          return false;
        }

        return true;
      });
    });

    $('.datepicker').datepicker({
      format: "yyyy-mm-dd",
      autoclose: true,
      todayHighlight: true
    });
  }).fail(function() {
    alert( "error" );
  });
}

function validateExperimentForm() {

  var required_names = ["experiment[service_id]", "experiment[name]", "experiment[description]", "experiment[total_modular]"];
  for (var index in required_names) {
    var name = required_names[index];
    var x = document.forms["experiment-form"][name].value;
    var msg = "";
    if (x == null || x == "") {
      msg = name.replace('experiment[', '').replace(']', '') + " must be filled out";
      document.forms["experiment-form"][name].className += " input-alert";
      alert(msg);
      return false;
    }
  }
};



$(document).ready(function() {
  $( "#btn-create-test" ).click(function() {
    window.location.href = "/experiments/new";
  });

  $( "#experiment-modify" ).click(function() {
    var expId = $( "#experiment-id" ).html();
    window.location.href = "/experiments/"+expId+"/edit";
  });

  $( "#experiment-delete" ).click(function() {
    var expId = $( "#experiment-id" ).html();
    if (confirm('Are you sure you want delete test?')) {
      $.ajax({
        url: '/experiments/'+expId,
        type: 'DELETE',
        success: function(result) {
          window.location.href = "/experiments/";
        }
      });
    } else {
        // Do nothing!
    }
  });

  var jsonArray = $('.json-body');
  _.each(jsonArray, function(elem) {
    var json = elem.innerText;
    jsonPrettyfy(json)
    elem.innerHTML = syntaxHighlight(json) ;
  });
});
