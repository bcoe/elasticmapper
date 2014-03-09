#encoding: UTF-8

require 'spec_helper'

describe ElasticMapper::Search do

  class SearchModel < ActiveHash::Base
    include ElasticMapper
    attr_accessor :foo, :bar

    mapping :foo, :bar
    mapping_name :index_models
  end

  describe "search" do
    before(:each) do
      reset_index
      IndexModel.put_mapping
    end
    let(:d1) { SearchModel.create(foo: 'hello world', bar: 'goodnight moon') }
    let(:d2) { SearchModel.create(foo: 'alpha century', bar: 'mars') }
    let(:d3) { SearchModel.create(foo: 'cat lover') }
    before(:each) do
      index(d1)
      index(d2)
      index(d3)
    end

    context "search by query string" do

      it "returns documents matching a query string" do
        results = SearchModel.search('alpha')
        results.count.should == 1
        results.first.foo.should == 'alpha century'
      end

      it "supports elasticsearch query DSL" do
        results = SearchModel.search('*')
        results.count.should == 3
      end

      it "handles escaping invalid search string" do
        results = SearchModel.search('AND AND mars')
        results.count.should == 1
        results.first.foo.should == 'alpha century'
      end
    end
  end

  context "sort" do
    it "can sort in descending order" do
      results = SearchModel.search('*', sort: { :foo => :desc })
      results.first.foo.should == 'hello world'
      results.second.foo.should == 'cat lover'
    end

    it "can sort in ascending order" do
      results = SearchModel.search('*', sort: { :foo => :asc })
      results.first.foo.should == 'alpha century'
      results.second.foo.should == 'cat lover'
    end
  end

end
