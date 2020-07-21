module Aspen
  module AST
    module Nodes
      class Type

        STRING  = "STRING"
        INTEGER = "INTEGER"
        FLOAT   = "FLOAT"

        MATCH_FLOAT   = /^([\d,]+\.\d+)$/
        MATCH_INTEGER = /^([\d,]+)$/
        MATCH_STRING  = /^(.+)$/

        def self.determine(value)
          new(
            case value
            when MATCH_FLOAT   then FLOAT
            when MATCH_INTEGER then INTEGER
            when MATCH_STRING  then STRING            
            else
              raise ArgumentError, "Could not determine a type for value:\n\t#{value.inspect}"
            end
          )
        end

        attr_reader :content, :converter

        def initialize(type_const)
          @content   = Aspen::AST::Nodes::Content.new(type_const)
          @converter = get_converter(type_const)
        end

        def get_converter(type_const)
          case type_const
          when FLOAT   then :to_f
          when INTEGER then :to_i
          when STRING  then :to_s
          else
            raise ArgumentError, "Could not determine a converter method for type:\n\t#{value.inspect}"
          end
        end

      end
    end
  end
end