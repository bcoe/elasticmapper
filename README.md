ElasticMapper
=============

A dead simple DSL for integrating ActiveRecord with ElasticSearch.

ElasticMapper is built on top of the [Stretcher](https://github.com/PoseBiz/stretcher) library.

Background
----------

Describing Mappings
----------------

Mappings indicate to ElasticSearch how the fields of a document should be indexed:

http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/mapping.html

ElasticMapper provides a `mapping` method, for describing these mappings.

```ruby
def Article
	include ElasticMapper

	mapping :title, :doi, { type => :string, index => :not_analyzed }
	mapping :title, :abstract, type => :string
	mapping :publication_date, type => :date
end
```

When you first create or modify mappings on an ElasticMapper model, you should run:

```ruby
Article.put_mapping
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
