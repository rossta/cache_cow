module CacheCow
  module Cacheable
    extend ActiveSupport::Concern

    module ClassMethods

      def fetch_cache(*args, &block)
        options = args.extract_options!
        keys    = args.flatten

        # raise "Doesn't support multiget" unless keys.size == 1
        rails_cache.fetch cache_key(keys.first), &block
      end

      def read_cache(cache_id = nil, options = {})
        rails_cache.read cache_key(cache_id), options
      end

      def write_cache(cache_id, value, options = {})
        rails_cache.write cache_key(cache_id), value, { :expires_in => 1500 }.merge(options)
      end

      def expire_cache(cache_id = nil, options = {})
        rails_cache.delete cache_key(cache_id), options
      end

      def read_multi_cache(*cache_ids)
        cache_keys = cache_ids.map { |cache_id| cache_key(cache_id) }
        rails_cache.read_multi(*cache_keys)
      end

      def fetch_multi_cache(*cache_ids, &block)
        cache_key_map = map_cache_keys_to_cache_ids(cache_ids)
        cache_keys    = cache_key_map.keys
        cache_hits    = rails_cache.read_multi(*cache_keys)
        missed_keys   = cache_keys - cache_hits.keys
        cache_hits.tap do |hits|
          missed_keys.each do |cache_key|
            hits[cache_key] = rails_cache.fetch(cache_key) { block.call(cache_key_map[cache_key]) }
          end
        end
      end

      def cached?(cache_id = nil)
        rails_cache.exist?(cache_key(cache_id))
      end

      def cache_key(cache_id)
        [cache_name, cache_cow_version, cache_id].compact.join(':').gsub(' ', '_')[0..(max_key_length - 1)]
      end

      def cache_name
        @cache_name ||= respond_to?(:base_class) ? base_class.name : name
      end

      def max_key_length
        200
      end

      private

      def rails_cache
        Rails.cache
      end

      def map_cache_keys_to_cache_ids(cache_ids)
        {}.tap do |map|
          cache_ids.each do |cache_id|
            map[cache_key(cache_id)] = cache_id
          end
        end
      end

    end

    module InstanceMethods

      def fetch_cache(key = nil, options = {}, &block)
        self.class.fetch_cache cache_id(key), options, &block
      end

      def write_cache(key = nil, options = {})
        self.class.write_cache cache_id(key), options
      end

      def read_cache(key = nil, options = {})
        self.class.read_cache cache_id(key), options
      end

      def expire_cache(key = nil, options = {})
        self.class.expire_cache cache_id(key), options
      end

      def cache_key(key = nil)
        self.class.cache_key cache_id(key)
      end

      protected

      def cache_id(key = nil)
        key.nil? ? id.to_s : "#{id}:#{key}"
      end

    end

  end
end