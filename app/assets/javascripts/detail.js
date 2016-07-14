//= require bootstrap-datepicker


function copyBucket(expId, bucketId){
  if (confirm('Are you sure you want to copy bucket?')) {
    var url = "/buckets/"+ bucketId + "/copy_bucket";
    $.ajax({
      url: url,
      type: 'PUT',
      success: function(data) {
        var status = data["status"];
        var results = data["results"];
        if (status == "success") {
          alert(results);
          window.location.href = "/experiments/"+expId+"/detail";
        } else {
          alert(results);
        }
        
      },
      error:function(e){
        alert(e.responseText);
      }
    });
  } else {
    // Do nothing!
  }
}

function showGraph(impressionID, modalID, apiPath) {
  var parameters = variablesObject[impressionID];
  var requestBody = $('#'+modalID+' .hidden').html();

  if ( parameters != null && requestBody != null && apiPath != null) {
    for (key in parameters){
      // requestBody = requestBody.replace(key, parameters[key]);
      requestBody = replaceAll(requestBody, key, parameters[key]);
    }
    var requestBodyString = requestBody.replace(/  /g,'')

    var endcodedReqBody = encodeURIComponent(requestBodyString);
    var encodedApiPath = encodeURIComponent(apiPath.replace(/ /g,'').replace('/\t/g', ''));
    var url = "/queries/visualize?graph_query="+endcodedReqBody+"&api_path="+encodedApiPath;
    var win = window.open(url, '_blank');
    win.focus();
  }
}

$(document).ready(function() {
  
  $('#toggle-series').click(function() {
    var chart = $('#ctr-chart').highcharts();

    var series = chart.series[0];
    if (series.visible) {
      $(chart.series).each(function(){
        //this.hide();
        this.setVisible(false, false);
      });
      chart.redraw();

    } else {
      $(chart.series).each(function(){
        //this.show();
        this.setVisible(true, false);
      });
      chart.redraw();

    }
  });


  $( "#buckets-save" ).click(function() {
    var expId = $( "#experiment-id" ).html().trim();
    var params = $(".modular-value").serializeArray()
    var url = "/experiments/"+ expId + "/modular";
    $.ajax({
      type: "POST",
      url: url,
      data: params,
      dataType: 'json',
      success:function(args){
          window.location.href = "/experiments/"+expId+"/detail";
      },
      error:function(e){
          alert(e.responseText);
      }
    });
  });

  $('#gen-access-token').click(function() {
    var uuid = generateUUID()
    $('#uuid').html(uuid)
  });

  $('#btn-save-access-token').click(function() {
    var uuid = $('#uuid').html().trim()
    var serviceId = $( "#service-id" ).html().trim();
    var expId = $( "#experiment-id" ).html();
    var landingUrl = "/services/" + serviceId;
    if (typeof(expId) != "undefined"){
      landingUrl = "/experiments/"+expId.trim()+"/detail";
    }
    var url = "/services/"+ serviceId + "/access_token";
    var params = "access_token="+uuid;

    $.ajax({
        type:"PUT",
        url:url,
        data:params,
        success:function(args){
            window.location.href = landingUrl;
        },
        error:function(e){
            alert(e.responseText);
        }
    });
  });

  function getExperimentChart(){
    //from_time=2015-09-21&to_time=2015-09-25&time_unit=d&nom=click&denom=impression
    var id = $('#exp_id').text();
    var params = $('#chart-form').serialize();
    var jqxhr = $.get( "/experiments/"+id +"/ctr.json?"+params, function(data) {
      vm.chartData = eval(data);
      $('#ctr-chart').highcharts(vm.chartData);
    });
  }

  // add event handler
  $('#experimet-contents-inner').delegate('#get_chart', 'click', getExperimentChart);

  // check validation
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

  // Load HighChart data
  Highcharts.createElement('link', {
    href: '//fonts.googleapis.com/css?family=Unica+One',
    rel: 'stylesheet',
    type: 'text/css'
  }, null, document.getElementsByTagName('head')[0]);

  Highcharts.theme = {
    colors: ["#7cb5ec", "#f7a35c", "#90ee7e", "#7798BF", "#aaeeee", "#ff0066", "#eeaaee",
      "#55BF3B", "#DF5353", "#7798BF", "#aaeeee"],
    chart: {
      backgroundColor: null,
      style: {
        fontFamily: "'Unica One', sans-serif"
      },
    },
    title: {
      style: {
        fontWeight: 'bold',
        textTransform: 'uppercase',
        fontSize: '20px'
      }
    },
    subtitle: {
      style: {
        textTransform: 'uppercase'
      }
    },
    xAxis: {
      gridLineWidth: 1,
      labels: {
         style: {
            fontSize: '12px'
         }
      }
     },
    yAxis: {
      minorTickInterval: 'auto',
      title: {
         style: {
            textTransform: 'uppercase'
         }
      },
      labels: {
         style: {
            fontSize: '12px'
         }
      }
    },
    tooltip: {},
    plotOptions: {
      candlestick: {
         lineColor: '#404048'
      }
    },
  };

  // Apply the theme
  Highcharts.setOptions(Highcharts.theme);
  $('#ctr-chart').highcharts(vm.chartData);

  var totalModular = $('#total-modular').text().split(/['total modular : ']+/)[1];

  var onSlide = function(e){
    var columns = $(e.currentTarget).find("td");
    var ranges = [], total = 0, i, s ="Ranges: ", w, subTotal = 0;
    for(i = 0; i<columns.length; i++){
      w = columns.eq(i).width()-10 - (i==0?1:0);
      ranges.push(w);

      total+=w;
    }
    for(i=0; i<columns.length; i++){
      ranges[i] = 100*ranges[i]/total;
      carriage = ranges[i]-w;
      range = Math.round(ranges[i]);
      s+=" "+ range + "%,";
      var right = 0;
      var left = 0;
      if (range > 0) {
        right = Math.min((subTotal+range), totalModular);
        left = right == 0? 0:Math.min((subTotal+1), totalModular);
      }

      x = left + "~" + right
      $("#text-"+i).html(x);
      $("#bucket-"+i).val(x);
      subTotal+=range;

    }
    s=s.slice(0,-1);
    $("#text").html(s);
  }

  //colResize the table
  $("#range").colResizable({
    liveDrag:true,
    draggingClass:"rangeDrag",
    gripInnerHtml:"<div class='rangeGrip'></div>",
    onResize:onSlide,
    minWidth:8
  });

  //callback function
  $("#bucket-modify").addClass("modal fade");
});
