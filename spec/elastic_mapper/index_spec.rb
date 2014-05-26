#encoding: UTF-8

require 'spec_helper'

describe ElasticMapper::Index do

  class IndexModel < ActiveHash::Base
    include ElasticMapper
    attr_accessor :foo, :bar

    mapping :foo, :bar
    mapping :foo, { :type => :string, :index => :not_analyzed }
    mapping_name :index_models
  end
  let(:instance) { IndexModel.create( foo: 'Benjamin', bar: 'Coe' )}

  describe "index_hash" do
    let(:expected_hash) do
      { :id=>1, :foo=>"Benjamin", :bar=>"Coe", :foo_2=>"Benjamin" }
    end

    it "creates an index hash that corresponds to the mapping" do
      instance.index_hash.should == expected_hash
    end
  end

  describe "index" do

    before(:each) do
      reset_index
      IndexModel.put_mapping
      ElasticMapper.index.refresh
    end

    it "indexes a document for search" do
      instance.index
      ElasticMapper.index.refresh

      results = ElasticMapper.index.type(:index_models)
        .search({ size: 12, query: { "query_string" => {"query" => '*'} } })
        .results

      results.count.should == 1
      results.first.foo.should == 'Benjamin'
      results.first.bar.should == 'Coe'
    end
  end

  describe "delete_from_index" do
    before(:each) do
      reset_index
      IndexModel.put_mapping
      ElasticMapper.index.refresh
    end
    
    it "removes the document from the search index" do
      instance.index
      ElasticMapper.index.refresh
      instance.delete_from_index

      results = ElasticMapper.index.type(:index_models)
        .search({ size: 12, query: { "query_string" => {"query" => '*'} } })
        .results

      results.count.should == 1
    end
  end
end
