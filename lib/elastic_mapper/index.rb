# Indexes the ActiveModel instance for search, based on
# the mapping outlined using ElasticMapper::Mapping.
module ElasticMapper::Index

  # Index the ActiveModel in ElasticSearch.
  def index
    mapping_name = self.class.instance_variable_get(:@_mapping_name)

    ElasticMapper.index.type(mapping_name).put(self.id, index_hash)
  end

  # Remove the document from the ElasticSearch index.
  def delete_from_index
    mapping_name = self.class.instance_variable_get(:@_mapping_name)

    ElasticMapper.index.type(mapping_name).delete(self.id)
  end

  # Generate a hash representation of the model.
  #
  # @return [Hash] hash representation of model.
  def index_hash
    mapping = self.class.instance_variable_get(:@_mapping)
    mapping.inject({}) do |h, (k, v)|
      h[k] = self.send(v[:field])
      h
    end
  end

end
