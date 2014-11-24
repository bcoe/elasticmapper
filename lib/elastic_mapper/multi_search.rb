# search across multiple models at the same
# time. NO WAY!
class ElasticMapper::MultiSearch

  # takes a hash lookup which maps from
  # a mapping name on to an ActiveRecord model.
  def initialize(obj_map)
    @obj_map = obj_map # used to create classes from mappings.
    @_mapping_name = @obj_map.keys.join(',')
    self.extend(ElasticMapper::Search::ClassMethods)
  end

  # receives queries in the form:
  # {
  #  id: "#{obj._type}_#{obj.id}",
  #  obj_id: obj.id,
  #  type: obj._type
  # }
  def find(ids_hash)
    results = {}

    # 1. iterate over each active model we care about.
    # 2. perform a bulk lookup based on id.
    # 3. map everything onto results hash, so that we can maintain sort order.
    @obj_map.keys.each do |key|
      ids = ids_hash.select {|id_hash| id_hash[:type] == key.to_s}.map {|obj| obj[:obj_id]}
      next unless ids.count > 0
      @obj_map[key].find(ids).each do |record|
        results["#{key}_#{record.id}"] = record
      end
    end

    results
  end
end
