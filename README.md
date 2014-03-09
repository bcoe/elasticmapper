ElasticMapper
=============

A dead simple DSL for integrating ActiveRecord with ElasticSearch.

Describing Mappings
----------------

Mappings indicate to ElasticSearch how the fields of a document should be stored:

http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/mapping.html

The `mapping` method is used to describe mappings with ElasticMapper:

* these mappings are used to generate a mapping for the model in ElasticSearch.
* they are also used to provide information to the search Mixin.


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
