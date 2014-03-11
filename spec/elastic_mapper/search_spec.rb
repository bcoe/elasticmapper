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
        results.documents.count.should == 1
        results.documents.first.foo.should == 'alpha century'
      end

      it "supports elasticsearch query DSL" do
        results = SearchModel.search('*')
        results.documents.count.should == 3
      end

      it "handles escaping invalid search string" do
        results = SearchModel.search('AND AND mars')
        results.documents.count.should == 1
        results.documents.first.foo.should == 'alpha century'
      end
    end

    context "search by hash" do
      it "returns documents matching the hash query" do
        results = SearchModel.search({ "query_string" => { "query" => 'alpha' } })
        results.documents.count.should == 1
        results.documents.first.foo.should == 'alpha century'        
      end
    end

    context "sort" do
      it "can sort in descending order" do
        results = SearchModel.search('*', sort: { :foo => :desc })
        results.documents.first.foo.should == 'hello world'
        results.documents.second.foo.should == 'cat lover'
      end

      it "can sort in ascending order" do
        results = SearchModel.search('*', sort: { :foo => :asc })
        results.documents.first.foo.should == 'alpha century'
        results.documents.second.foo.should == 'cat lover'
      end
    end

    context "pagination" do
      it "allows result size to be set with size" do
        results = SearchModel.search('* OR alpha', size: 1)
        results.documents.count.should == 1
        results.documents.first.foo.should == 'alpha century'
      end

      it "allows documents to be skipped with from" do
        results = SearchModel.search({ "query_string" => { "query" => '* OR alpha' } }, size: 1, from: 1)
        results.total.should == 3
        results.from.should == 1
        results.documents.count.should == 1
        results.documents.first.foo.should == 'hello world'
      end
    end

  end

end
