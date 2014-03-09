# Indexes the ActiveRecord for search
# based on the mapping provided.
module ElasticMapper::Index

  # Using the mapping as a basis,
  # indexes the model.
  def index
    mapping_name = self.class.instance_variable_get(:@_mapping_name)

    ElasticMapper.index.type(mapping_name).put(self.id, index_hash)
  end

  # Generates a hash representation of the model
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
