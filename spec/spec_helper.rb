require "ostruct"
require "simplecov"
require "active_hash"

SimpleCov.start do
  add_filter "/spec/"
end

SimpleCov.minimum_coverage 95

require_relative '../lib/elastic_mapper'

# A helper to delete, and recreate the
# ElasticSearch index used for specs.
# This code is borrowed from the stretcher specs.
def reset_index
  ElasticMapper.index_name = "elastic_mapper_tests"
  index = ElasticMapper.index
  server = ElasticMapper.server

  index.delete rescue nil # ignore exceptions.

  server.refresh

  index.create({
    :settings => {
      :number_of_shards => 1,
      :number_of_replicas => 0
    }
  })

  # Why do both? Doesn't hurt, and it fixes some races
  server.refresh
  index.refresh
    
  # Sometimes the index isn't instantly available
  (0..40).each do
    idx_metadata = server.cluster.request(:get, :state)[:metadata][:indices][index.name]
    i_state =  idx_metadata[:state]
    
    break if i_state == 'open'
    
    if attempts_left < 1
        raise "Bad index state! #{i_state}. Metadata: #{idx_metadata}" 
    end

    sleep 0.1
  end

end

# Index the model provided,
# and refresh the index so that the
# document can be searched.
def index(model)
  model.index
  ElasticMapper.index.refresh
end
