// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


var gNodes, gEdges, gNetwork;
var nodeDatas = {};
var edgeDatas = {};
function addNode(id, label, group) {
	console.log(id+"\t"+ label);
    try {
        gNodes.add({
            id: id,
            label: label,
            group: group
        });
    }
    catch (err) {
        alert(err);
    }
}

function removeNode(idToRemove) {
    try {
        gNodes.remove({id: idToRemove});
    }
    catch (err) {
        alert(err);
    }
}

function addEdge(id, from, to) {
    try {
        gEdges.add({
            id: id,
            from: from,
            to: to
        });
    }
    catch (err) {
        alert(err);
    }
}

function removeEdge(idToRemove) {
    try {
        gEdges.remove({id: idToRemove});
    }
    catch (err) {
        alert(err);
    }
}

$(document).ready(function() { 
	$('#query_service').change(function(){
        var serviceId = $('#query_service option:selected').val();
        $("#query_column").find("option").remove();
        for (column in columns[serviceId]){
        	$("#query_column").append("<option value='" + columns[serviceId][column] + "'>" + columns[serviceId][column]+ "</option>");
        }
    });

	$('#btn-traversal').click(function(){
        var serviceId = $('#query_service option:selected').val();
        var columnName =  $('#query_column option:selected').val();
        var id =  $('#query_id').val();
        idStr = id.toString();
        
        if (serviceId == "" || columnName == "" || idStr == ""){
        	alert("Service, Column Name, Id are required.");
        }

        console.log(serviceId + '\t', columnName + '\t' + idStr);
        nodeDatas[idStr] = {"service": serviceId, "columnName" : columnName , "id": idStr};
        addNode(idStr, idStr, 'start');

    });

    $('#btn-clear').click(function(){
    	for (index in gEdges._data){
    		removeEdge(gEdges._data[index]["id"])
    	}

    	for (index in gNodes._data){
    		removeNode(index);
    	}
    	nodeDatas = {};
    	edgeDatas = {};
    });

	var data = $('#graph-result').html();
	if (typeof(data) != "undefined"){
		data = data.trim();
		if (data != null && data != ""){
			data = JSON.parse(data);
			var nodeData = stringToJsonObj(data["nodes"]);
			var edgeData = stringToJsonObj(data["edges"]);
			var details = stringToJsonObj(data["details"]);
			var nodes = new vis.DataSet(nodeData);

			// create an array with edges
			var edges = new vis.DataSet(edgeData);

			// create a network
			var container = document.getElementById('graph');
			var data = {
				nodes: nodes,
				edges: edges
			};

			var options = {
				nodes: {
				  shape: 'dot',
				},
				groups: {
					'start': {
						shape: 'star',
						color: '#8A2BE2' // orange
				  }
				},
				interaction: {
					hover: true
				}
			};
			var network = new vis.Network(container, data, options);

	    	network.on("hoverEdge", function (params) {
	        	document.getElementById('hover-properties').innerHTML = JSON.stringify(details[params.edge], '', 4);
	        	var jsonArray = $('#hover-properties');
				_.each(jsonArray, function(elem) {
			    	var json = elem.innerText;
			    	jsonPrettyfy(json)
			    	elem.innerHTML = syntaxHighlight(json) ;
			  	});
	    	});

	    	network.on("selectEdge", function (params) {
	        	document.getElementById('select-properties').innerHTML = JSON.stringify(details[params.edges[0]], '', 4);
	        	var jsonArray = $('#select-properties');
				_.each(jsonArray, function(elem) {
			    	var json = elem.innerText;
			    	jsonPrettyfy(json)
			    	elem.innerHTML = syntaxHighlight(json) ;
			  		});
			});
		}else{
			// create an array with nodes
	        gNodes = new vis.DataSet();
	        
	        // create an array with edges
	        gEdges = new vis.DataSet();
	        // create a network
	        var container = document.getElementById('graph');
	        var data = {
	            nodes: gNodes,
	            edges: gEdges
	        };

			var options = {
				nodes: {
				  shape: 'dot',
				},
				groups: {
					'start': {
						shape: 'star',
						color: '#8A2BE2' // orange
				  }
				},
				interaction: {
					hover: true
				}
			};
			gNetwork = new vis.Network(container, data, options);

			gNetwork.on("selectNode", function (params) {
				console.log(params);
	        	var reqParam = nodeDatas[params.nodes[0]];
	        	var nodeLength = gNodes.length;
	        	var edgeLength = gEdges.length;

				var url = "/queries/partial_graph";
				var reqParams = {"service" : reqParam["service"], "column_name" : reqParam["columnName"], "id" : reqParam["id"], "node_length" : nodeLength, "edge_length" : edgeLength};
			    $.ajax({
			      type: "POST",
			      url: url,
			      data: reqParams,
			      dataType: 'json',
			      success:function(data){
					console.log(data);
					nodesToAdd = data["nodes"];
					edgesToAdd = data["edges"];

					if (nodesToAdd == null || edgesToAdd == null ){
						alert('There is no data to add.');
					}

					for (node in nodesToAdd){
						if (nodeDatas[nodesToAdd[node]["id"]] == null){
							nodeDatas[nodesToAdd[node]["id"]] = {"service": nodesToAdd[node]["service"], "columnName" : nodesToAdd[node]["columnName"] , "id": nodesToAdd[node]["id"]};
							addNode(nodesToAdd[node]["id"], nodesToAdd[node]["label"], nodesToAdd[node]["group"]);	
						}
						
					}

					console.log(edgesToAdd)
					for (edge in edgesToAdd){
						var from = edgesToAdd[edge]["from"];
						var to = edgesToAdd[edge]["to"];
						var edgeUK = from.toString() + to.toString();
						if (edgeDatas[edgeUK] == null){
							edgeDatas[edgeUK] = {"from" : from, "to" : to};
							addEdge(edgesToAdd[edge]["id"], edgesToAdd[edge]["from"], edgesToAdd[edge]["to"]);
						}
					}

			      },
			      error:function(e){
			          alert(e.responseText);
			      }
			    });

	    	});
		}
	}
	
	

	// initialize your network!
	
	$('#btn-get-graph').click(function() {
	    var apiPath = $( "#query-api-path-input" ).val().trim();
	    var requestBody = $( "#query-request-body-input" ).val();
	    var url = "/queries/call_graph";

	    if (apiPath == "" || requestBody == ""){
	    	alert("Input api path and request body.");
	    	return;
	    }
		var params = {"api_path" : apiPath, "request_body" : requestBody};

	    $.ajax({
	      type: "POST",
	      url: url,
	      data: params,
	      dataType: 'json',
	      success:function(data){
		        var nodeData = stringToJsonObj(data["nodes"]);
		        var edgeData = stringToJsonObj(data["edges"]);
		        var details = stringToJsonObj(data["details"]);
				var nodes = new vis.DataSet(nodeData);

				// create an array with edges
				var edges = new vis.DataSet(edgeData);

				// create a network
				var container = document.getElementById('graph');
				var data = {
				    nodes: nodes,
				    edges: edges
				};
			
	             var options = {
			        nodes: {
			          shape: 'dot',
			        },
			        groups: {
			        	'start': {
							shape: 'star',
							color: '#8A2BE2' // orange
			          }
			        },
					interaction: {
						hover: true
					}
			      };
				// initialize your network!
				var network = new vis.Network(container, data, options);
				network.on("hoverEdge", function (params) {
		        	document.getElementById('hover-properties').innerHTML = JSON.stringify(details[params.edge], '', 4);
		        	var jsonArray = $('#hover-properties');
					_.each(jsonArray, function(elem) {
				    	var json = elem.innerText;
				    	jsonPrettyfy(json)
				    	elem.innerHTML = syntaxHighlight(json) ;
				  	});
		    	});
		    	network.on("selectEdge", function (params) {
		        	document.getElementById('select-properties').innerHTML = JSON.stringify(details[params.edges[0]], '', 4);
		        	var jsonArray = $('#select-properties');
					_.each(jsonArray, function(elem) {
				    	var json = elem.innerText;
				    	jsonPrettyfy(json)
				    	elem.innerHTML = syntaxHighlight(json) ;
				  	});
		    	});
	      },
	      error:function(e){
	          alert(e.responseText);
	      }
	    });
  	});
});
