#encoding: UTF-8

require 'spec_helper'

describe ElasticMapper::Mapping do

  class Model
    def self.table_name
      "model"
    end

    include ElasticMapper::Mapping

    mapping :foo, :bar
    mapping :foo, { :type => :integer, :index => :not_analyzed }
  end

  class ModelMappingNameOverridden
    def self.table_name
      "model"
    end

    include ElasticMapper::Mapping
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
        :type => :integer
      }
    end

  end

  describe "mapping_name" do
    it "defaults to the table_name of the model" do
      Model.instance_variable_get(:@_mapping_name).should == 'model'
    end
  end

=begin
  describe "mapping_json" do
    it "generates the appropriate json for the mapping" do

    end
  end
=end
end
