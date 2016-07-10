module Crogo
  class Smash

    include Crogo::Utils::HashyJson

    # @return [Hash(String, JSON::Type)]
    def unsmash
      result = {} of String => JSON::Type
      self.keys.each do |key|
        result[key] = Crogo::Smash.value_convert(self[key])
      end
      result
    end

    # Convert given value to allowed value type within Smash
    #
    # @param val [Object]
    # @return [JSON::Type]
    def self.value_convert(val) : JSON::Type
      if(val.is_a?(Hash))
        new_val = {} of String => JSON::Type
        val.keys.each do |k|
          new_val[k.to_s] = value_convert(val[k])
        end
      elsif(val.is_a?(Smash))
        new_val = {} of String => JSON::Type
        val.keys.each do |k|
          new_val[k.to_s] = value_convert(val[k])
        end
      elsif(val.is_a?(Array))
        new_val = Array(JSON::Type).new
        val.each do |item|
          new_val.push(value_convert(item))
        end
      else
        new_val = val
      end
      new_val
    end

    # Perform deep merge on two Smash types
    #
    # @param original [Smash] base instance
    # @param overlay [Smash] instance to be applied to base
    # @return [Smash] newly merged instance
    def deep_merge(overlay : Smash) : Smash
      Crogo::Smash.deep_merge(self, overlay)
    end

    # Perform deep merge on two Smash types
    #
    # @param original [Smash] base instance
    # @param overlay [Smash] instance to be applied to base
    # @return [Smash] newly merged instance
    def self.deep_merge(original : Smash, overlay : Smash) : Smash
      result = Crogo::Smash.new
      original.keys.each do |okey|
        base = original[okey]
        base = base.unsmash if base.is_a?(Smash)
        if(overlay.has_key?(okey))
          over = overlay[okey]
          over = over.unsmash if over.is_a?(Smash)
          if(base.is_a?(Hash) && over.is_a?(Hash))
            result[okey] = deep_merge(base.to_smash, over.to_smash).unsmash
          else
            result[okey] = over
          end
        else
          result[okey] = base
        end
      end
      (overlay.keys - original.keys).each do |okey|
        over = overlay[okey]
        over = over.unsmash if over.is_a?(Smash)
        result[okey] = over
      end
      result
    end

  end
end

class Hash
  # @return [Omnivore::Smash]
  def to_smash
    result = Crogo::Smash.new
    self.keys.each do |k|
      result[k.to_s] = Crogo::Smash.value_convert(self[k])
    end
    result
  end

  # @return [Hash]
  def unsmash
    result = {} of String => JSON::Type
    self.keys.each do |key|
      result[key] = Crogo::Smash.value_convert(self[key])
    end
    result
  end

end

Smash = Crogo::Smash
