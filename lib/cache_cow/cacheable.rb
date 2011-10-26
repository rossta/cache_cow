module CacheCow
  module Cacheable
    extend ActiveSupport::Concern

    module ClassMethods

      def read_cache(cache_id = nil)
        Rails.cache.read(cache_key(cache_id))
      end

      def fetch_cache(*args, &block)
        options = args.extract_options!
        keys    = args.flatten

        # raise "Doesn't support multiget" unless keys.size == 1
        Rails.cache.fetch(cache_key(keys.first), &block)
      end

      def write_cache(cache_id, value, options = {})
        Rails.cache.write cache_key(cache_id), value, { :expires_in => 1500 }.merge(options)
      end

      def expire_cache(cache_id = nil, options = {})
        Rails.cache.delete cache_key(cache_id), options
      end

      def cached?(cache_id = nil)
        read_cache(cache_id).nil? ? false : true
      end

      def cache_key(cache_id)
        [cache_name, acts_as_cached_version, cache_id].compact.join(':').gsub(' ', '_')[0..(max_key_length - 1)]
      end

      def cache_name
        @cache_name ||= respond_to?(:base_class) ? base_class.name : name
      end

      def max_key_length
        200
      end

    end

    module InstanceMethods

      def fetch_cache(key = nil, options = {}, &block)
        self.class.fetch_cache(cache_id(key), options, &block)
      end

      def cache_id(key = nil)
        key.nil? ? id.to_s : "#{id}:#{key}"
      end

    end

  end
end