module CacheCow
  module CachedIdList
    extend ActiveSupport::Concern

    module ClassMethods
      # For example:
      #
      #   cached_id_list :groups, :accessor => :member_of?
      def cached_id_list(association_name, options = {})
        accessor_name = options[:accessor]
        cache_key     = cached_id_list_cache_key(association_name)

        define_method(cache_key) do
          fetch_cache cache_key.inspect, :expires_in => 1.month do
            send(association_name).select("id").map(&:id)
          end
        end

        if accessor_name
          self.class_eval <<-RUBY
            def #{accessor_name}(model_or_id)
              return false if model_or_id.nil?
              model_id = model_or_id.is_a?(Fixnum) ? model_or_id : model_or_id.id
              #{cache_key}.include?(model_id)
            end
          RUBY
        end
      end

      def cached_id_list_cache_key(association_name)
        "cached_" + association_name.to_s.singularize + "_ids"
      end
    end

    # module InstanceMethods
    #   def expire_cached_id_list(association_name)
    #     cache_key = self.class.cached_id_list_cache_key(association_name)
    #     expire_cache cache_key
    #     instance_variable_set("@#{cache_key}", nil)
    #     instance_variable_set("@cached_#{association_name}", nil)
    #   end
    # end

  end
end