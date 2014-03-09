# Add search to an ActiveRecord model.
# The id field is used to load the underlying
# models from the DB.
module ElasticMapper::Search

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    # Search on a model's mapping. Either a String, or a hash can
    # be provided for the query. If  a string is provided,
    # a search will be performed using the ElasticSearch
    # query DSL. If a hash is provided, it will be passed
    # directly to stretcher.
    #
    # @param query [String|Hash] the search query.
    # @param opts [Hash] query options.
    # @return [ActiveModel|Array] the search results.
    def search(query, opts = {}, query_sanitized = false)

      {
        sort: { _score: 'desc' }
      }.update(opts)

      # Perform the query in a try/catch block, attempt
      # to sanitize the query if it fails.
      begin
        res = ElasticMapper.index.type(
          self.instance_variable_get(:@_mapping_name)
        ).search({ size: 12, query: {
            "bool" => {
              "must" => [
                # This pattern is here for reference, it's useful
                # when it comes time to add multi-tenant support.
                # {"term" => {"user_id" => id}},
                {"query_string" => {"query" => query}}
              ]
            }
          }
        }.merge(opts))
      rescue Stretcher::RequestError => e
        # the first time a query fails, attempt to
        # sanitize the query and retry the search.
        # This gives users the power of the Lucene DSL
        # while protecting them from badly formed queries.
        if query_sanitized
          raise e
        else
          return search(sanitize_query(query), opts, true)
        end
      end

      ordered_results(res.results.map(&:id))
    end

    # Fetch a set of ActiveRecord resources, looking up
    # by the id returned by ElasticSearch. Maintain ElasticSearch's
    # ordering.
    #
    # @param ids [Array] array of ordered ids.
    # @return results [Array] ActiveModel result set.
    def ordered_results(ids)
      model_lookup = self.find(ids).inject({}) do |h, m|
        h[m.id] = m
        h
      end
      
      ids.map { |id| model_lookup[id] }
    end
    private :ordered_results

    # sanitize a search query for Lucene. Useful if the original
    # query raises an exception due to invalid DSL parse.
    #
    # http://stackoverflow.com/questions/16205341/symbols-in-query-string-for-elasticsearch
    #
    # @param str [String] the query string to sanitize.
    def sanitize_query(str)
      # Escape special characters
      # http://lucene.apache.org/core/old_versioned_docs/versions/2_9_1/queryparsersyntax.html#Escaping Special Characters
      escaped_characters = Regexp.escape('\\+-&|!(){}[]^~*?:\/')
      str = str.gsub(/([#{escaped_characters}])/, '\\\\\1')

      # AND, OR and NOT are used by lucene as logical operators. We need
      # to escape them
      ['AND', 'OR', 'NOT'].each do |word|
        escaped_word = word.split('').map {|char| "\\#{char}" }.join('')
        str = str.gsub(/\s*\b(#{word.upcase})\b\s*/, " #{escaped_word} ")
      end

      # Escape odd quotes
      quote_count = str.count '"'
      str = str.gsub(/(.*)"(.*)/, '\1\"\3') if quote_count % 2 == 1

      str
    end
    private :sanitize_query

  end
end
