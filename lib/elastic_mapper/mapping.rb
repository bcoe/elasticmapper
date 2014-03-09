# This mixin adds functionality to ActiveRecord
# models, related to generating mappings for ElasticSearch.
#
# http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/mapping.html
module ElasticMapper::Mapping

  def self.included(base)
    # Default the mapping name, to the table_name variable,
    # which will be set on ActiveRecord models.
    if base.respond_to?(:table_name)
      base.instance_variable_set(:@_mapping_name, base.table_name.to_sym)
    end

    base.extend(ClassMethods)
  end

  module ClassMethods
    # Populates @_mapping with properties describing
    # how the model should be indexed in ElasticSearch.
    # The last parameter is optionally a hash for specifying
    # indexing settings, e.g., analyzed, not_analyzed.
    #
    # @param args [*args] symbols representing fields
    #    on your model.
    def mapping(*args)
      options = {
        :type => :string,
        :index => :analyzed
      }.update(args.extract_options!)

      args.each do |arg|
        _mapping[mapping_key(arg)] = {
          field: arg,
          options: options
        }
      end
    end

    # Return the _mapping instance variable, used to keep
    # track of a model's mapping definition. id is added
    # to the model by default, and is used to map the model
    # back onto an ActivRecord object.
    # 
    # @return [Hash] the mapping description.
    def _mapping
      @_mapping ||= { id: {
        :field => :id,
        :options => { :type => :integer, :index => :no }
      }}
    end
    private :_mapping

    # Create a unique key name for the mapping.
    # there are times where you might want to index
    # same field multiple time, e.g., analyzed, and not_analyzed.
    #
    # @param key [String] the original key name.
    # @return [String] the de-duped key name.
    def mapping_key(key)
      counter = 1
      mapping_key = key

      while @_mapping.has_key?(mapping_key)
        counter += 1
        mapping_key = "#{mapping_key}_#{counter}".to_sym
      end

      return mapping_key
    end
    private :mapping_key

    # Override the default name of the mapping.
    #
    # @param mapping_name [String] name of mapping.
    def mapping_name(mapping_name)
      @_mapping_name = mapping_name.to_sym
    end

    # Generates a json representation of @_mapping,
    # compatible with ElasticSearch.
    #
    # @return [Hash] mapping.
    def mapping_json
      {
        @_mapping_name => {
          properties: @_mapping.inject({}) { |h, (k, v)| h[k] = v[:options]; h }
        }
      }
    end

    # Create the described mapping in ElasticSearch.
    def put_mapping
      ElasticMapper.index
        .type(@_mapping_name)
        .put_mapping(mapping_json)
    end
  end

end
