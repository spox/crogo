module Crogo

  class Attribute(T)
    property name : String
    property required : Bool = false
    property original : T? = nil
    property default : T? | Proc(T)?

    @value : T?

    def initialize(@name : String, @value : T? = nil, @required : Bool = false, @default : Proc(T)? | T? = nil)
      defaulter = @default
      if(@value.nil? && defaulter)
        @value = defaulter.is_a?(Proc) ? defaulter.call : defaulter
      end
      if(@required && @value.nil?)
        raise Error::RequiredValue.new("Required value not set! (Attribute name `#{name}`)")
      end
      unless(@value.nil?)
        @original = @value
      end
    end

    def unset
      if(required)
        raise Error::RequiredValue.new("Cannot unset required value! (Attribute name `#{name}`)")
      else
        @value = nil
      end
    end

    def clean? : Bool
      @original == @value
    end

    def clean! : T?
      @original = @value
    end

    def dirty? : Bool
      !clean?
    end

    def set(val : T) : T
      @original = @value
      @value = val
    end

    def get : T?
      @value
    end

  end

  module Lazy

    alias LAZY_TYPES = String | Int8 | Int32 | Int64 | UInt8 | UInt32 | UInt64 | Float32 | Float64 | Bool | Time

    macro included
      @@attributes = [] of Symbol
      @@initers = {} of String => Proc(self, Crogo::Lazy::LAZY_TYPES?, Nil)
      {% types = [String, Int8, Int32, Int64, UInt8, UInt32, UInt64, Float32, Float64, Bool, Time].map{|x| "Crogo::Attribute(#{x})"}.join(" | ") %}
      {{"property attributes = {} of Symbol => #{types.id}".id}}

      def self.attributes
        @@attributes
      end
    end

    macro attribute(name, type, required = false, default = nil)

      @@attributes << {{name}}
      @@initers["{{name.id}}"] = ->(obj : self, init_val : Crogo::Lazy::LAZY_TYPES?){ {{"obj.init_#{name.id}".id}}(init_val); nil }

      def lazy_init!(init_vals = {} of String => Crogo::Lazy::LAZY_TYPES)
        @@initers.each do |i_name, init|
          init.call(self, init_vals[i_name]?)
        end
      end

      def {{"init_#{name.id}".id}}(val=nil)
        val = val.as({{type.id}}) unless val.nil?
        new_attr = Crogo::Attribute({{type.id}}).new("{{name.id}}", val, {{required}}, {{default}})
        attributes[{{name}}] = new_attr
      end

      def {{name.id}} : {{type.id}}?
        l_attr = attributes[{{name}}]?
        if(l_attr.nil?)
          nil
        else
          val = l_attr.get
          if(val.nil?)
            nil
          else
            val.as({{type.id}})
          end
        end
      end

      def {{"#{name.id}=".id}}(val : {{type.id}}?) : {{type.id}}?
        l_attr = attributes[{{name}}].as(Crogo::Attribute({{type.id}}))
        if(val.nil?)
          l_attr.unset
        else
          l_attr.set(val)
        end
        val
      end

      def dirty?
        attributes.values.any?{|a| a.dirty?}
      end

      def clean?
        attributes.values.all?{|a| a.clean?}
      end

      def dirty
        result = typeof(self.attributes).new
        attributes.each do |a_name, att|
          if(att.dirty?)
            result[a_name] = att
          end
        end
        result
      end

      def clean!
        attributes.values.each do |att|
          att.clean!
        end
      end

    end

  end
end
