module Crogo
  module Utils
    module HashyJson
      macro included
        {{"@data = {} of String => JSON::Type".id}}
        {{"getter :data".id}}
        {{"forward_missing_to @data".id}}
        {{"include Crogo::Utils::HashyJson::Moddy".id}}
      end

      module Moddy
        # Fetch value from message data
        #
        # @param *keys [String, Symbol] path to value
        # @param type [Symbol] expected data type
        # @return [JSON::Type]
        def get(*keys, type = :string)
          val = keys.reduce(JSON::Any.new(data.unsmash)) do |memo, key|
            value = memo.as_h.fetch(key.to_s, nil)
            break unless value
            JSON::Any.new(value)
          end
          if (val)
            case type
            when :string
              val.as_s
            when :array
              val.as_a
            when :bool
              val.as_bool
            when :float
              val.as_f
            when :hash
              val.as_h
            when :integer
              val.as_i
            when :any
              val
            else
              raise "Invalid data type defined for casting `#{type}`"
            end
          else
            nil
          end
        end

        # Set a configuration item
        #
        # @param keys [String] name of item
        # @param value [JSON::Type] value of item
        # @return [JSON::Any] value of item
        def set(*keys, value) : JSON::Any
          final_key = keys.last
          context = keys.to_a[0, keys.size - 1].reduce(data) do |memo, key|
            result = memo.as(Hash(String, JSON::Type)).fetch(key.to_s, nil)
            if (result.nil?)
              result = {} of String => JSON::Type
              memo.as(Hash(String, JSON::Type))[key.to_s] = result
            end
            result
          end
          value = Crogo::Smash.value_convert(value)
          context.as(Hash(String, JSON::Type))[final_key.to_s] = value
          JSON::Any.new(value)
        end

        # Convert hash to hash of string key and value
        #
        # @param original_hash [Hash(String, JSON::Type)]
        # @return [Hash(String, String)]
        def hashify(original_hash : Hash(String, JSON::Type)) : Hash(String, String)
          new_hash = {} of String => String
          original_hash.each do |key, value|
            new_hash[key] = value.to_s
          end
          new_hash
        end
      end
    end
  end
end
