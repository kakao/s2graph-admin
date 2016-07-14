// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


$(document).ready(function() {
  var elems = $( '.counter-boolean-contents-div' );

  for (var i = 0 ; i < elems.length ; i++) {
  	if (elems[i].innerHTML == "true"){
  		$(elems[i]).addClass('label label-primary')
  	}else if (elems[i].innerHTML == "false"){
  		$(elems[i]).addClass('label label-warning')
  	}else{
  		$(elems[i]).addClass('label')
  	}
  }

  $( "#counter-modify" ).click(function() {
    var counterId = $( "#counter-id" ).html();
    window.location.href = "/counters/"+counterId+"/edit";
  });
 });
