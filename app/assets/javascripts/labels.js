// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var propertyArray = [];

var VALIDATION = new Object();
VALIDATION.isCheckedName = false;
VALIDATION.name = "";

var orderCount = 0;	
var multiselectFunc = {
        onChange: function(option, checked) {
            if (checked) {
                orderCount++;
                $(option).data('order', orderCount);
            }
            else {
                $(option).data('order', Number.MAX_SAFE_INTEGER);
            }
        },
        buttonText: function(options) {
            if (options.length === 0) {
                return 'none selected';
            }
            else if (options.length > 3) {
                return options.length + ' selected';
            }
            else {
                var selected = [];
                options.each(function() {
                    selected.push([$(this).text(), $(this).data('order')]);
                });

                selected.sort(function(a, b) {
                    return a[1] - b[1];
                });

                var text = '';
                for (var i = 0; i < selected.length; i++) {
                    text += selected[i][0] + ', ';
                }
					console.log(text);
                return text.substr(0, text.length -2);
            }
        },
    };
 

function validationLabelName(){
	if (!VALIDATION.isCheckedName) {
		return false;
	} else{
		var labelName = $('#label_label').val();
		
		if (labelName == VALIDATION.name){
			return true;
		}
		return false;
	}
}


function preSubmitForEdit(){
	event.preventDefault();
	var form = $("#editing_label").closest('form');
	var labelId = $("#label-id").html().trim();
	var serviceId = document.forms["label-form"]["label[service_id]"].value;

	// form = form.concat([
	// 		{name: "label[id]", value: labelId}
	// 	]);
	form = form.serializeArray();
	form = form.concat([
	    {name: "label[properties]", value: JSON.stringify($('#properties-table').tableToJSON())},
		{name: "label[indices]", value: JSON.stringify($('#indices-table').tableToJSON())}
	]);
	console.log(form)
	$("#cover").css("display", "block");
	$.post('/labels/'+labelId+'/add_props_and_indices', form, function(data) {
	 		var message = data["message"];
	 		var status = data["status"];
	 	if (status == "success"){
	 		$("#cover").fadeOut( "slow" );
	 		window.location.href = "/services/"+serviceId;
	 	}else{
	 		alert(message);
	 		$("#cover").fadeOut( "slow" );
	 	}

		}).fail(function() {
	    alert( "error" );
	  });
}

function preSubmit(){ //listen for submit event
	event.preventDefault();
	//validation

	var required_names = ["label[label]", "label[src_service_id]", "label[src_column_name]", "label[src_column_type]", "label[tgt_service_id]", "label[tgt_column_name]", "label[tgt_column_type]", "label[service_id]"];
	// for (var index in required_names) {
	// 	var name = required_names[index]; 
	//     var x = document.forms["label-form"][name].value;
	//     var msg = ""
	//     if (x == null || x == "") {
	//         msg = name.replace('label[', '').replace(']', '') + " must be filled out";
	//         document.forms["label-form"][name].className += " input-alert";
	//         alert(msg)
	//         return false;
	//     }
	// }


    var form = $("#new_label").closest('form');
	
	form = form.serializeArray();

	form = form.concat([
	    {name: "label[properties]", value: JSON.stringify($('#properties-table').tableToJSON())},
		{name: "label[indices]", value: JSON.stringify($('#indices-table').tableToJSON())}
	]);
	console.log(form)

	var serviceId = document.forms["label-form"]["label[service_id]"].value;
	
	$("#cover").css("display", "block");

	$.post('/labels', form, function(data) {
	 		var message = data["message"];
	 		var status = data["status"];
	 		if (status == "success"){
	 			$("#cover").fadeOut( "slow" );
	 			window.location.href = "/services/"+serviceId;
		 	}else{
		 		alert(message);
		 		$("#cover").fadeOut( "slow" );
		 	}
		}).fail(function() {
	    	alert( "error" );
	  });
}


function validateLabelForm(){
	
	var isCheckedName = validationLabelName();
	if (!isCheckedName){
		alert("Check label name!");
		return false;
	}
	var required_names = ["experiment[service_id]", "experiment[name]", "experiment[description]", "experiment[total_modular]"];
	for (var index in required_names) {
		var name = required_names[index];
		var x = document.forms["experiment-form"][name].value;
		var msg = "";
		if (x == null || x == "") {
			msg = name.replace('label[', '').replace(']', '') + " must be filled out";
			document.forms["label-form"][name].className += " input-alert";
			alert(msg);
			return false;
		}
	}
}

function initPropertyArray(){
	propertyArray = [];
	 
	var toObj = new Object();
	toObj.name = "to";
	toObj.index = -5;
	propertyArray.push(toObj);

	var timestampObj = new Object();
	timestampObj.name = "timestamp";
	timestampObj.index = 0;
	propertyArray.push(timestampObj);

	
}


function updatePropertyArray(){
	var trArray = $("#properties-table tr");
	var index = 1;

	initPropertyArray();
	for (var i = 0; i < trArray.length; i++){
		if (i == 0){
			continue;
		}
		var propName = $(trArray[i]).children()[0].innerHTML.trim();
		var obj = new Object();
		obj.name = propName;
		obj.index = index;
		console.log(obj.name, obj.index);
		index ++;
		propertyArray.push(obj);
	}
}

function updateIndicesTable(){
	var trArray = $("#indices-table tr");
	var index = 1;
	for (var i = 0; i < trArray.length; i++){
		if (i == 0){
			continue;
		}
		$(trArray[i]).children()[1].innerHTML = index;
		index ++;
	}
}

function updatePropertiesTable(){
	var trArray = $("#properties-table tr");
	var index = 1;
	for (var i = 0; i < trArray.length; i++){
		if (i == 0){
			continue;
		}
		$(trArray[i]).children()[1].innerHTML = index;
		index ++;
	}
}


function getPropertyIndex(propName){
	for (var i = 0; i < propertyArray.length; i++){
		if (propertyArray[i].name == propName){
			return propertyArray[i].index;
		}
	}
}

$(document).ready(function() {
	initPropertyArray();
	
	var indexSelectBox = $('#index-select-box');
	indexSelectBox.append("<option value='to'>to</option>")
	indexSelectBox.append("<option value='timestamp'>timestamp</option>")

	var json = $('#properties-table').tableToJSON();
	if (json.length > 0){
		for(var i = 0; i < json.length; i++) {
			var obj = json[i];
			var initObj = new Object();
			initObj.name = obj["PROPERTY NAME"];
			initObj.index = obj["SEQ"];
			propertyArray.push(initObj);
			console.log(propertyArray);
			updateIndicesTable();
			var optionElem = "<option value='"+initObj.name+ "'>"+initObj.name+"</option>";
			indexSelectBox.append(optionElem);
		}	
		indexSelectBox.multiselect('destroy');
		indexSelectBox.multiselect(multiselectFunc);
		$("#index").removeClass("hidden-element").addClass("inline-block-element");
	}

	
	var mode = false;

	if ($("#label-mode").html() == "edit"){
		mode = true;
	};
	

	


	// $('#label_label').keyup(function() {
	// 	var phase = $( "#phase" ).html().trim();
	// 	var labelName = $('#label_label').val();
	// 	var htableName = labelName + '-' + phase;
	// 	$('#label_hbase_table_name').val(htableName)
	// });


	$( "#btn-label-add-idx" ).click(function() {
		event.preventDefault();
		var indexName = $("#index-name").val();
		var selectedArray = $('#index-select-box option:selected');
		var selected = [];
        $('#index-select-box option:selected').each(function() {
            selected.push([$(this).val(), $(this).data('order')]);
        });

        selected.sort(function(a, b) {
            return a[1] - b[1];
        });

        var text = '';
        var metaSeq = '';
        for (var i = 0; i < selected.length; i++) {
            text += selected[i][0] + ',';
            metaSeq += getPropertyIndex(selected[i][0]) + ',';
        }
        text = text.substring(0, text.length - 1);
        metaSeq = metaSeq.substring(0, metaSeq.length - 1);
        
        var trCnt = $("#indices-table").length;
        if (indexName == "" || metaSeq == ""){
			alert("Input name and seq");
			return;
		}

		var id = indexName;
		var delBtn = $("<button>delete</button>").addClass('btn btn-sm btn-danger').attr('id', id+'-btn')[0];
        var btnHtml = delBtn.outerHTML;
		// %span{id: "experiment-delete", class: "glyphicon glyphicon-trash", "aria-hidden" => "true"}
		var tr = '<tr id='+ id+ ' ><td>'+indexName+'</td>'+'<td></td>'+'<td>'+metaSeq+'</td>'+ '<td>'+btnHtml+'</td></tr>';
		$("#indices-table tr:last").after(tr);
		$("#index-name").val('');
		$("#index-select-box").val('');

		updateIndicesTable();
		var indexSelectBox = $('#index-select-box');
		indexSelectBox.multiselect('destroy');
		indexSelectBox.multiselect(multiselectFunc);

		$("#"+id+"-btn").click(function(event) {
			event.preventDefault();
			
			if (confirm('The index will be removed. Are you sure?')) {
				$("#"+id).remove();
				updateIndicesTable();

			} else {
			}

		});

	});
	

	$( "#btn-label-add-prop" ).click(function() {
	    event.preventDefault();

	    var trCnt = $("#properties-table tr").length;
		var propName = $("#property-name").val();
		var propType = $("#property-type").val();
		var propDefault = $("#property-default-value").val();

		if (propName == "" || propType == ""){
			alert("Input name, type and default value");
			return;
		}

		var id = propName + "-" + propType + "-" + propDefault;
		var delBtn = $("<button>delete</button>").addClass('btn btn-sm btn-danger').attr('id', id+'-btn')[0];

		var btnHtml = delBtn.outerHTML;
		// %span{id: "experiment-delete", class: "glyphicon glyphicon-trash", "aria-hidden" => "true"}
		var tr = '<tr id='+ id+ ' ><td>'+propName+'</td><td></td><td>'+propType+'</td>'+'<td>'+propDefault+'</td>'+ '<td>'+btnHtml+'</td></tr>';
		$("#properties-table tr:last").after(tr);
		$("#property-name").val('');
		$("#property-type").val('');
		$("#property-default-value").val('');

		var indexSelectBox = $('#index-select-box');

		var optionElem = "<option value='"+propName+ "' id='" + id+"-option'>"+propName+"</option>";
		
		indexSelectBox.append(optionElem);
		indexSelectBox.multiselect('destroy');
		indexSelectBox.multiselect(multiselectFunc);
		$("#index").removeClass("hidden-element").addClass("inline-block-element");

		updatePropertyArray();
		updatePropertiesTable();

		$("#"+id+"-btn").click(function(event) {
			event.preventDefault();
			
			if (confirm('The property will be removed. And every index will be initialized. Are you sure?')) {
				if (mode) {
					location.reload();
				}else{
					$("#"+id).remove();
					$("#"+id+"-option").remove();
					var indexSelectBox = $('#index-select-box');
					indexSelectBox.multiselect('destroy');
					indexSelectBox.multiselect(multiselectFunc);
					updatePropertyArray();
					updatePropertiesTable();
					if ($("#properties-table tr").length ==1){
						$("#index").removeClass("inline-block-element").addClass("hidden-element");
					}
					var indicesTable = $("#indices-table tr");
					for (var i = 0 ; i < indicesTable.length ; i++){
						if (i != 0){
							$(indicesTable[i]).remove();	
						}
					}
				}
			} else {

			}
		});

	});


	$( "#btn-label-check-duplicate").click(function(event) {
		event.preventDefault();
		var labelName = document.forms["label-form"]["label[label]"].value
		
	    var msg = "Input label name";
	    var clazz = "alert alert-danger";
		if (labelName == ""){
			$("#notice-label-check").html(msg).addClass(clazz);
			return;
		}

		var url = "/labels/check/"+labelName;
	    $.ajax({
	      type: "GET",
	      url: url,
	      success:function(response){
	      	var result = response["isAlreadyExist"];
	      	if (result == "false"){
	      		msg = "It is good to use.";
	      		clazz = "alert alert-success";
	      		VALIDATION.name = labelName;
	      		VALIDATION.isCheckedName = true;
	      	}else{
	      		msg = "Use another label name.";
	      		clazz = "alert alert-danger";
	      	}
	      	$("#notice-label-check").html(msg).removeClass("alert alert-danger alert-success").addClass(clazz);
	      },
	      error:function(e){
	          alert(e.responseText);
	      }
	    })
		
	});
	setHeight();
});

