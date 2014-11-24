#encoding: UTF-8

require 'spec_helper'

describe ElasticMapper::MultiSearch do

  class SearchModel < ActiveHash::Base
    include ElasticMapper
    attr_accessor :foo, :bar

    mapping :foo, :bar
    mapping_name :index_models
  end

  class SearchModelTwo < ActiveHash::Base
    include ElasticMapper
    attr_accessor :foo, :bar

    mapping :foo, :bar
    mapping_name :index_models_two
  end

  describe "search" do
    before(:each) do
      reset_index
      SearchModel.put_mapping
      SearchModelTwo.put_mapping
    end
    let(:d1) { SearchModel.create(foo: 'hello world', bar: 'goodnight moon') }
    let(:d2) { SearchModelTwo.create(foo: 'alpha century', bar: 'mars') }
    let(:d3) { SearchModel.create(foo: 'cat lover') }
    before(:each) do
      index(d1)
      index(d2)
      index(d3)
    end

    context "search by query string" do
      it "returns documents matching a query string" do
        multi = ElasticMapper::MultiSearch.new({
          index_models: SearchModel,
          index_models_two: SearchModelTwo
        })

        results = multi.search('alpha')
        results.documents.count.should == 1
        results.documents.first.foo.should == 'alpha century'
        results.documents.first.should be_a(SearchModelTwo)
      end

      it "supports elasticsearch query DSL" do
        multi = ElasticMapper::MultiSearch.new({
          index_models: SearchModel,
          index_models_two: SearchModelTwo
        })

        results = multi.search('*')
        results.documents.count.should == 3
      end
    end

    context "sort" do
      it "can sort in descending order" do
        multi = ElasticMapper::MultiSearch.new({
          index_models: SearchModel,
          index_models_two: SearchModelTwo
        })

        results = multi.search('*', sort: { :foo => :desc })
        results.documents.first.foo.should == 'hello world'
        results.documents.first.should be_a(SearchModel)

        results.documents.second.foo.should == 'cat lover'
        results.documents.second.should be_a(SearchModel)

        results.documents.third.foo.should == 'alpha century'
        results.documents.third.should be_a(SearchModelTwo)
      end

      it "can sort in ascending order" do
        multi = ElasticMapper::MultiSearch.new({
          index_models: SearchModel,
          index_models_two: SearchModelTwo
        })

        results = multi.search('*', sort: { :foo => :asc })
        results.documents.first.foo.should == 'alpha century'
        results.documents.first.should be_a(SearchModelTwo)

        results.documents.second.foo.should == 'cat lover'
        results.documents.second.should be_a(SearchModel)
      end
    end

    context "pagination" do
      it "allows result size to be set with size" do
        multi = ElasticMapper::MultiSearch.new({
          index_models: SearchModel,
          index_models_two: SearchModelTwo
        })

        results = multi.search('* OR alpha', size: 1)
        results.documents.count.should == 1
        results.documents.first.foo.should == 'alpha century'
        results.documents.first.should be_a(SearchModelTwo)
      end

      it "allows documents to be skipped with from" do
        multi = ElasticMapper::MultiSearch.new({
          index_models: SearchModel,
          index_models_two: SearchModelTwo
        })

        results = multi.search({ "query_string" => { "query" => '* OR alpha' } }, size: 1, from: 1)
        results.total.should == 3
        results.from.should == 1
        results.documents.count.should == 1
        results.documents.first.foo.should == 'hello world'
        results.documents.first.should be_a(SearchModel)
      end
    end

  end
end
