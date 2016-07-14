// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
function validateServiceForm() {
	var required_names = ["service[service_name]", "service[access_token]", "service[cluster]", "service[hbase_table_name]"];
	for (var index in required_names) {
		var name = required_names[index];
	    var x = document.forms["service-form"][name].value;
	    var msg = ""
	    if (x == null || x == "") {
	        msg = name.replace('service[', '').replace(']', '') + " must be filled out";
	        document.forms["service-form"][name].className += " input-alert";
	        alert(msg)
	        return false;
	    }
	}
}
