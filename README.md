ElasticMapper
=============

A dead simple mixin for integrating ActiveModel with ElasticSearch.

ElasticMapper is built on top of the [Stretcher](https://github.com/PoseBiz/stretcher) library.

Background
----------

I'm a big fan of the Stretcher gem, for interacting with ElasticSearch. It exposes an API that's: straightforward, elegant, and well documented. Given this, I tend to choose stretcher when pulling search into Rails projects.

A few projects in, I noticed that I was rewriting a lot of the same code for:

* describing the mappings on documents.
* indexing documents.
* and searching for documents.

This motivated ElasticMapper. Include ElasticMapper as a mixin in your ActiveModels, it will in turn provide helpers for: generating mappings, indexing documents, and performing search.

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

Indexing A Document
-------------------

When you create or update a document using the ElasticMapper mixin, simply call `index`.

```ruby
article = Article.create(title: "Hello World", doi: "doi://12354.com")
article.index
```

Or, even easier, use the ActiveRecord `:after_save` hook:

```ruby
class Article < ActiveRecord::Base

  include ElasticMapper

  validates_uniqueness_of :doi
  validates_presence_of :doi, :title

  after_save :index

  mapping :title, :doi, :index => :not_analyzed
  mapping :title, :abstract
  mapping :publication_date, :type => :date
end
```

Searching
---------

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
