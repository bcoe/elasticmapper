require "active_support/core_ext"
require "elastic_mapper/version"
require "elastic_mapper/mapping"

module ElasticMapper
  def self.included(base)
    base.send(:include, ElasticMapper::Mapping)
  end
end
