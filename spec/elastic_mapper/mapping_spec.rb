#encoding: UTF-8

require 'spec_helper'

describe ElasticMapper::Mapping do

  class Model
    def self.table_name
      :models
    end

    include ElasticMapper::Mapping

    mapping :foo, :bar
    mapping :foo, { :type => :string, :index => :not_analyzed }
  end

  class ModelMappingNameOverridden
    def self.table_name
      :models
    end

    include ElasticMapper::Mapping

    mapping_name :overridden_name
  end

  describe "mapping" do

    let(:mapping) { Model.instance_variable_get(:@_mapping) }

    it "creates a mapping entry for each symbol" do
      mapping.has_key?(:foo).should == true
      mapping.has_key?(:bar).should == true
    end

    it "creates unique name for field in mapping, if a collision occurs" do
      mapping.has_key?(:foo_2).should == true      
    end

    it "populates mapping entry with default options, if none given" do
      mapping[:foo][:options].should == {
        :index => :analyzed,
        :type => :string
      }
    end

    it "allows options to be overridden" do
      mapping[:foo_2][:options].should == {
        :index => :not_analyzed,
        :type => :string
      }
    end

  end

  describe "mapping_name" do
    it "defaults to the table_name of the model" do
      Model.instance_variable_get(:@_mapping_name).should == :models
    end

    it "allows the mapping name to be overridden" do
      ModelMappingNameOverridden
        .instance_variable_get(:@_mapping_name).should == :overridden_name
    end
  end

  describe "mapping_json" do
    it "generates the appropriate json for the mapping" do
      mapping = Model.mapping_json
      mapping.should == { models: {
          properties: {
            id: { :type => :integer, :index => :no},
            foo: { :type => :string, :index => :analyzed },
            bar: { :type => :string, :index => :analyzed },
            foo_2: { :type => :string, :index => :not_analyzed }
          }
        }
      }
    end
  end

  describe "put_mapping" do

    let(:expected_properties) do 
      {
        "foo" => { "type" => "string" },
        "foo_2" => { "type" => "string", "index" => "not_analyzed",
            "norms" => { "enabled" => false}, "index_options" => "docs"
        },
        "bar" => { "type" => "string" },
        "id" => { "type" => "integer", "index" => "no" }
      }.stringify_keys
    end
    before(:each) { reset_index }

    it "creates the mapping in ElasticSearch" do
      Model.put_mapping
      ElasticMapper.index.refresh

      properties = ElasticMapper.index
        .get_mapping
        .elastic_mapper_tests
        .models
        .properties
        .to_hash

      properties.should == expected_properties
    end
  end

end
