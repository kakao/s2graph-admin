// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


function validateAuthorityForm() {
	var required_names = ["authority[user_id]", "authority[service_id]"];
	for (var index in required_names) {
		var name = required_names[index]; 
	    var x = document.forms["authority-form"][name].value;
	    var msg = ""
	    if (x == null || x == "") {
	        msg = name.replace('authority[', '').replace(']', '') + " must be filled out";
	        document.forms["authority-form"][name].className += " input-alert";
	        alert(msg)
	        return false;
	    }
	}
}