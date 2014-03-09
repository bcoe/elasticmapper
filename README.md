ElasticMapper
=============

A dead simple DSL for integrating ActiveRecord with ElasticSearch.

ElasticMapper is built on top of the Stretcher library.

Background
----------

Describing Mappings
----------------

Mappings indicate to ElasticSearch how the fields of a document should be indexed:

http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/mapping.html

ElasticMapper provides a `mapper` mixin, for describing these mappings:

* the mappings descriptions can be used to automatically generate a mapping for ElasticSearch:
	* Note: the mapping only needs to be updated in ElasticSearch when it's updated or created.
* the mapping descriptions are used by ElasticMapper to deem information about a model for indexing and search tasks. 


```ruby
def Article
	include ElasticMapper

	mapping :title, :doi, { type => :string, index => :not_analyzed }
	mapping :title, :abstract, type => :string
	mapping :publication_date, type => :date
end
```

When you first create a set of mappings, or modify your mappings, run:

```ruby
Article.save_mapping
```

ToDo
----

* Put more tests around search.
* Test the library out.

## Installation

Add this line to your application's Gemfile:

    gem 'elasticmapper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install elasticmapper

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( http://github.com/<my-github-username>/elasticmapper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
