class HTable
  class HTableNameNotFound < StandardError
    
  end

  class HTableCreateError < StandardError
    
  end
  

	def self.s2_url
    APP_CONFIG['s2graph_url']+'/graphs/createHTable'
  end
	def self.build_query(cluster, hTableName, preSplitSize, hTableTTL, compressionAlgorithm)
    query = {
      cluster: cluster,
      hTableName: hTableName,
      preSplitSize: preSplitSize
    }
    if (!hTableTTL.nil? && hTableTTL != '')
    	query = query.merge(hTableTTL: hTableTTL.to_i)
    end
    if (!compressionAlgorithm.nil? && compressionAlgorithm != '')
    	query = query.merge(compressionAlgorithm: compressionAlgorithm)
    end
    query
  end

  def self.createTable(cluster, hTableName, preSplitSize, hTableTTL, compressionAlgorithm)
    begin
    	query = HTable.build_query(cluster, hTableName, preSplitSize, hTableTTL, compressionAlgorithm)
      logger.info(query.to_json)
      url = HTable.s2_url
    	res = RestClient.post url, query.to_json, :content_type => :json, :accept => :json
      parsed = (JSON.parse(res) rescue {}).with_indifferent_access
      results = parsed[:message]
      if (results == "HTable was created.")
        return true
      else
      	return false
      end
    rescue
      return false
    end
  end

end