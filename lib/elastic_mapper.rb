require "stretcher"
require "active_support/core_ext"
require "elastic_mapper/version"
require "elastic_mapper/mapping"
require "elastic_mapper/index"
require "elastic_mapper/search"
require "elastic_mapper/multi_search"

module ElasticMapper

  # The index name to use for ElasticMapper.
  # the models themselves are namespaced
  # by a mapping names.
  #
  # @param index_name [String] name of index.
  def self.index_name=(index_name)
    @@index_name = index_name
  end

  # Return the index name.
  #
  # @return [String] name of index.
  def self.index_name
    @@index_name
  end

  # Return the index associated with the
  # default index name.
  #
  # @return [Stretcher::Index] index object.
  def self.index
    ElasticMapper.server.index(index_name)
  end

  # Allow the ES server to be overriden by an
  # instance with custom initialization.
  #
  # @param server [Stretcher::Server] ES server.
  def self.server=(server)
    @@server = server
  end

  # Return the server object associated with
  # ElasticMapper.
  #
  # @return [Stretcher::Server]
  def self.server
    @@server ||= Stretcher::Server.new
  end

  # Include all of the submodules, so that
  # we can optinally use elasticmapper by
  # simply including the root module.
  def self.included(base)
    base.send(:include, ElasticMapper::Mapping)
    base.send(:include, ElasticMapper::Index)
    base.send(:include, ElasticMapper::Search)
  end
end
