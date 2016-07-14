// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
function validateUserForm() {
	var required_names = ["user[email]"];
	for (var index in required_names) {
		var name = required_names[index];
	    var x = document.forms["user-form"][name].value;
	    var msg = ""
	    if (x == null || x == "") {
	        msg = name.replace('user[', '').replace(']', '') + " must be filled out";
	        document.forms["user-form"][name].className += " input-alert";
	        alert(msg)
	        return false;
	    }
	}
}
