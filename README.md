ElasticMapper
=============

A damn simple mixin for integrating ActiveModel with ElasticSearch.

ElasticMapper is built on top of the [Stretcher](https://github.com/PoseBiz/stretcher) client.

Background
----------

I'm a big fan of the [Stretcher](https://github.com/PoseBiz/stretcher) ElasticSearch client. It exposes an API that's: straightforward, elegant, and well documented. I tend to choose stretcher when pulling search into Rails projects.

A few projects in, I noticed that I was rewriting a lot of the same code for:

* describing the mappings on documents.
* indexing documents.
* and searching for documents.

From this grew ElasticMapper; Simply include the ElasticMapper mixin in your ActiveModels, it provides helpers for: generating mappings, indexing documents, and performing search.

Creating Mappings
-----------------

Mappings indicate to ElasticSearch how the fields of a document should be indexed:

http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/mapping.html

ElasticMapper provides a `mapping` method, for describing these mappings.

```ruby
def Article < ActiveHash::Base
	include ElasticMapper

	# Note we might sometimes want to index the same field in a few
	# different ways, ElasticMapper creates a unique name automatically
	# if fields collide :title, :title_1, ...
	mapping :title, :doi, { type => :string, index => :not_analyzed }
	mapping :title, :abstract, type => :string
	mapping :publication_date, type => :date
end
```

When you create or modify mappings on an ElasticMapper model, you should run:

```ruby
Article.put_mapping
```

Indexing a Document
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

Deleting a Document
-------------------

To remove a document from ElasticSearch, use the `delete_from_index` method.

```ruby
class Article < ActiveRecord::Base

	include ElasticMapper

	after_destroy :delete_from_index
end
```

Searching
---------

ElasticMapper adds the `search` method to your ActiveModel classes. Results will be returned as instances of your ActiveModel class.

*String Queries*

You can provide a string query to your model, and it will be parsed using the ElasticSearch query DSL:

```ruby
articles = Article.search('hello AND world')
```

*Hash Queries*

You can also provide a hash object, for advanced searches.

```ruby
articles = Article.search({ "query_string" => { "query" => 'alpha' } })
```

*Pagination*

* `:size` how many search results should be returned?
* `:from` what offset should we start returning results from?

```ruby
results = SearchModel.search('* OR alpha', size: 10, from: 10)
```

Searching Across Multiple Models
--------------------------------

Suppose you have two mappings in ElasticSearch, for instance an `article` and
a `user`. There are times when you might want to search across both models
at the same time.

This can be facilitated with ElasticMapper's `MultiSearch` class:

```ruby
multi = ElasticMapper::MultiSearch.new({
	index_models: SearchModel,
	index_models_two: SearchModelTwo
})

results = multi.search('* OR alpha', size: 1)
```

* a multi-search instance accepts a hash into the constructor, which maps ElasticSearch mappings to model classes.
* once you have a `MultiSearch` instance, search works the same as it does when using the ActiveModel mixin.

That's It
---------

Let me know what you think!

## Installation

Add this line to your application's Gemfile:

    gem 'elastic_mapper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install elastic_mapper

## Contributing

1. Fork it ( http://github.com/bcoe/elasticmapper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
