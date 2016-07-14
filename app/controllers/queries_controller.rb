class QueriesController < ApplicationController
	before_action :set_active

  def visualize
  	@graph_query = params[:graph_query]
  	@api_path = params[:api_path]
  	@graph_url = APP_CONFIG['s2graph_query_url']+'/graphs/getEdges'
  	@graph_result = nil
  	if !@graph_query.nil?
  		# logger.error(@graph_query)
  		callGraphInner(@api_path, @graph_query)
  		@graph_result = @result.to_json
  	end

  	source_columns = Label.select("src_service_id as id, src_column_name as column_name").group("src_service_id, src_column_name")

  	@grouped ={}
  	source_columns.each { |column| 
  		logger.error(column.id.to_s + "\t" + column.column_name)
  		temp = @grouped[column.id].presence || []
  		@grouped[column.id] =  temp.push(column.column_name)
  	}

  end

  def partialGraph
  	# {"service"=>"1", "column_name"=>"account_id", "id"=>"123", "node_length"=>"1", "edge_length"=>"0"}
  	serviceId = params[:service]
  	columnName = params[:column_name]

  	id = params[:id]
  	id_str = id.to_s
  	splitId = id_str.split("||")
  	origin_id = id.to_s
  	if splitId.size > 1
  		id_str = splitId[1]
  		id = id_str
  	end

  	nodeLength = params[:node_length]
  	edgeLength = params[:edge_length]

  	labels = Label.where(src_service_id: serviceId, src_column_name: columnName)
  	if labels.size > 0
	  	serviceName = Service.find(serviceId).service_name
	  
	  	edgesArray = []
	  	nodes = {}
	  	nodeProperties = {}
	  	step = labels.map do |label|
	  		if label.src_column_type == 'long' || label.src_column_type == 'integer'
				id = id.to_i
			end
	  		{ "label" => label.label, "offset" => 0, "limit" => 5, "direction" => "out"}
	  	end
	  	srcVertices = [{"serviceName" => serviceName, "columnName" => columnName, "id" => id}]
	  	query = {"srcVertices" => srcVertices, "steps" => ["step" => step]}.to_json
		api_path = APP_CONFIG['s2graph_query_url']+'/graphs/getEdges'
		logger.error(api_path)
		logger.error(query)

		res = RestClient.post api_path, query, :content_type => :json, :accept => :json
	    parsed = JSON.parse(res) rescue {}
		results = parsed["results"]

		results.map do | data |
			to = data["to"]
			labelName = data["label"]
			score = data["score"]
			toKey = labelName + "||" + to.to_s
			
			label = labels.where(label: labelName).first
			
			nodes[toKey] = to
			code=0
			labelName.each_byte{|b| code += b}
			nodeProperties[toKey] = { 'group' => code % 100, 'service' => label.tgt_service_id, 'columnName' => label.tgt_column_name}
			edgesArray.push({"edge" => {origin_id => toKey}})
		end

	  	dataSet = nodes.map do | id, label |
	  		group = nodeProperties[id]['group']
	  		service = nodeProperties[id]['service']
	  		columnName = nodeProperties[id]['columnName']
			{'id' => id, 'label' => label, 'group' => group, 'service' => service, 'columnName' => columnName}
		end

		edges = edgesArray.each_with_index.map do | edgeMap, index |
			from = edgeMap['edge'].keys[0]
			to = edgeMap['edge'][from]
			{'id' => (edgeLength.to_i + index).to_s, 'from' => from, 'to' => to} #@edgeProperties[key]['value']}
		end
		@result = Hash["nodes" => dataSet, "edges" => edges]
		
	  	render json: @result.to_json
	else
		@result = Hash["nodes" => nil, "edges" => nil]
		render json: @result.to_json
	end
  end

  def parentsParse(dataset, isParent, depth)
  	if dataset.nil?
  		return
  	end
  	dataset.map do |data|
  		from = data["from"]
  		to = data["to"]
  		label = data["label"]
  		score = data["score"]
  		props = data['props']
  		direction = data["direction"]
  		fromKey = depth.to_s + from.to_s
  		toKey = (depth-1).to_s + to.to_s
  		@nodes[fromKey] = from
		@nodes[toKey] = to
		key = fromKey + toKey + direction
		if @dupEdge[key].nil?
			titleJson = {'label' => label, 'props' => props}.to_json
	  		@edgeProperties[key] = @edgeProperties[key]== nil ? {'title' => titleJson} : @edgeProperties[key].merge({'title' => titleJson})
			@edgeProperties[key] = @edgeProperties[key].merge({'value' => score})
			@edgeProperties[key] = @edgeProperties[key].merge({'details' => props})
			@nodeProperties[fromKey] = {'depth' => depth}
			@nodeProperties[toKey] = {'depth' => depth -1 }
			@edgesArray.push({"edge" => {fromKey => toKey}, "direction" => direction})
			@dupEdge[key] = key
			
			valueKey = direction == "out" ? toKey : fromKey

			if @values[valueKey].nil?
				@values[valueKey] = score
			else
				value = @values[valueKey] + score
				@values[valueKey] = value

				if @maxValue < value
					@maxValue = value
				end
			end
		end
		
		if @firstNode.size == 0 
			@firstNode[fromKey] = depth
		else
			if @firstNode[@firstNode.keys[0]] < depth
				@firstNode.clear
				@firstNode[fromKey] = depth
			end
		end

		parents = data["parents"]
  		if !parents.nil?
  			parents.map do | parent |
  				parentsParse(parent["parents"], true, depth + 2)
	  			pFrom = parent["from"]
	  			pTo = parent["to"]
	  			label = parent["label"]
  				score = parent["score"]
  				props = parent["props"]
  				direction = parent["direction"]
	  			fromKey = (depth+1).to_s + pFrom.to_s
  				toKey = depth.to_s + pTo.to_s
	  			@nodes[fromKey] = pFrom
	  			@nodes[toKey] = pTo
	  			key = fromKey + toKey + direction
	  			if @dupEdge[key].nil?
	  				titleJson = {'label' => label, 'props' => props}.to_json
	  				@edgeProperties[key] = @edgeProperties[key]== nil ? {'title' => titleJson} : @edgeProperties[key].merge({'title' => titleJson})
	  				@edgeProperties[key] = @edgeProperties[key].merge({'value' => score})
	  				@edgeProperties[key] = @edgeProperties[key].merge({'details' => props})
	  				@nodeProperties[fromKey] = {'depth' => depth + 1}
					@nodeProperties[toKey] = {'depth' => depth }
		  			@edgesArray.push({"edge" => {fromKey => toKey}, "direction" => direction})
		  			@dupEdge[key] = key
		  			# logger.error(pFrom.to_s + ' -> '+ pTo.to_s)
		  			
		  			valueKey = direction == "out" ? toKey : fromKey

					if @values[valueKey].nil?
						@values[valueKey] = score
					else
						value = @values[valueKey] + score
						@values[valueKey] = value

						if @maxValue < value
							@maxValue = value
						end
					end
		  		end

		  		if @firstNode.size == 0 
					@firstNode[fromKey] = depth
				else
					if @firstNode[@firstNode.keys[0]] < depth +1
						@firstNode.clear
						@firstNode[fromKey] = depth
					end
				end
	  		end
  		end  
  	end

  end

  def callGraphInner(api_path, request_body)
  	
  	reqBodyJson = JSON.parse(request_body) rescue {}
  	reqBodyJson = reqBodyJson.merge({"returnTree" => true})
  	reqBodyJson.delete("select")
  	reqBodyJson.delete("groupBy")
  	
  	res = RestClient.post api_path, reqBodyJson.to_json, :content_type => :json, :accept => :json
    parsed = JSON.parse(res) rescue {}
    @nodes = {}
    @nodeProperties = {}
  	@edgesArray = []
  	@edgeProperties = {}
  	@firstNode = {}
  	@dupEdge = {}
  	@values = {}
  	@maxValue = 0
  	@edgeDetails = {}	
	results = parsed["results"]
	parentsParse(results, false, 10)

	dataSet = @nodes.map do | id, label |
		group = @nodeProperties[id]['depth']
		value = @values[id].presence || 1
		if @firstNode[id].nil?
			{'id' => id, 'label' => label, 'group' => group, 'value' => value }
		else
			{'id' => id, 'label' => label, 'group' => 'start', 'first' => true, 'value' => @maxValue }
		end
	end

	edges = @edgesArray.each_with_index.map do | edgeMap, index |
		from = edgeMap['edge'].keys[0]
		to = edgeMap['edge'][from]
		key = from.to_s + to.to_s + edgeMap['direction']
		arrow = edgeMap['direction'] == "out" ? "to" : "from"
		@edgeDetails[index] = @edgeProperties[key]['details']
		{'id' => index, 'from' => from, 'to' => to, 'title' => @edgeProperties[key]['title'], 'arrows' => arrow} #@edgeProperties[key]['value']}
	end

	@result = Hash["nodes" => dataSet.to_json, "edges" => edges.to_json, "details" => @edgeDetails.to_json]
  end
  # POST /queries/call_graph
  def callGraph
  	api_path = params[:api_path]
  	request_body = params[:request_body]
  	
  	callGraphInner(api_path, request_body)

  	render json: @result.to_json
  end

  private
  	def set_active
      @active = "query"
    end
end
