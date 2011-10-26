module CacheCow
  module ActsAsCached
    extend ActiveSupport::Concern

    module ClassMethods

      def acts_as_cached
        include Cacheable
        include CachedIdList
      end

      def acts_as_cached_options
        @acts_as_cached_options ||= {}
      end

      def acts_as_cached_version
        acts_as_cached_options[:version] || 1
      end

    end
  end
end


class ActiveRecord::Base
  include CacheCow::ActsAsCached
end

# ActiveRecord::Base.send :include, CacheCow::ActsAsCached

# def self.included(base)
#   base.extend ClassMethods
# end
#
# module ClassMethods
#   @@nil_sentinel = :_nil
#
#   def self.extended(a_class)
#     class << a_class
#       alias_method_chain :inherited, :acts_as_cached
#     end
#   end
#
#   def inherited_with_acts_as_cached(subclass)
#     inherited_without_acts_as_cached(subclass)
#     subclass.acts_as_cached acts_as_cached_options
#   end
#
#   def acts_as_cached(options = {})
#     @acts_as_cached_options = options
#   end
#
#   def acts_as_cached_options
#     @acts_as_cached_options ||= {}
#   end
#
#   def acts_as_cached_version
#     acts_as_cached_options[:version] || 1
#   end
#
#   def cached(method, options = {})
#     fetch_cache(method, options) { send(method) }
#   end
#
#   def fetch_cache(*args, &block)
#     options = args.last.is_a?(Hash) ? args.pop : {}
#     keys    = args.flatten
#
#     raise "Doesn't support multiget" unless keys.size == 1
#
#     if (value = Rails.cache.read(cache_key(keys.first), options))
#       value == @@nil_sentinel ? nil : value
#     else
#       value = fetch_cachable_data(keys.first, &block)
#       value_to_cache = value.nil? ? @@nil_sentinel : value
#       Rails.cache.write(cache_key(keys.first), value_to_cache, options)
#       return value
#     end
#   end
#
#   def get_multi(cache_ids, &block)
#     cache_keys = cache_ids.map { |cache_id| cache_key(cache_id) }
#     cache_hits = Rails.cache.read_multi(*cache_keys)
#     yield MultigetContext.new(self, cache_hits)
#   end
#
#   def fetch_cachable_data(cache_id = nil, &block)
#     if block_given?
#       yield(cache_id)
#     else
#       find(cache_id)
#     end
#   end
#
#   def cached?(cache_id = nil)
#     read_cache(cache_id).nil? ? false : true
#   end
#
#   def read_cache(cache_id = nil)
#     Rails.cache.read(cache_key(cache_id))
#   end
#
#   def set_cache(cache_id, value, ttl = nil)
#     returning(value) do |v|
#       v = @@nil_sentinel if v.nil?
#       Rails.cache.write(cache_key(cache_id), v, :expires_in => (ttl || 1500))
#     end
#   end
#
#   def expire_cache(cache_id = nil)
#     Rails.cache.delete cache_key(cache_id)
#     true
#   end
#
#   def cache_name
#     @cache_name ||= respond_to?(:base_class) ? base_class.name : name
#   end
#
#   def max_key_length
#     200
#   end
#
#   def cache_key(cache_id)
#     [cache_name, acts_as_cached_version, cache_id].compact.join(':').gsub(' ', '_')[0..(max_key_length - 1)]
#   end
#
#   private
#
#   NIL_SENTINEL = @@nil_sentinel
#
#   class MultigetContext
#     def initialize(klass, cache_hits)
#       @klass = klass
#       @cache_hits = cache_hits
#     end
#
#     def fetch_cache(*args, &block)
#       args_temp = args.dup
#       options   = args_temp.last.is_a?(Hash) ? args.pop  : {}
#       keys      = args_temp.flatten
#       if value = @cache_hits[@klass.cache_key(keys.first)]
#         value == NIL_SENTINEL ? nil : value
#       else
#         @klass.fetch_cache(args, options, &block)
#       end
#     end
#   end
# end
#
# def fetch_cache(key = nil, options = {}, &block)
#   self.class.fetch_cache(cache_id(key), options, &block)
# end
#
# def cached(method, options = {})
#   self.class.fetch_cache(cache_id(method), options) { send(method) }
# end
#
# def cached?(key = nil)
#   self.class.cached? cache_id(key)
# end
#
# def read_cache(key = nil)
#   self.class.read_cache cache_id(key)
# end
#
# def expire_cache(key = nil)
#   self.class.expire_cache(cache_id(key))
# end
#
# def cache_id(key = nil)
#   key.nil? ? id.to_s : "#{id}:#{key}"
# end
