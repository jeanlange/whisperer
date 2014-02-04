module Whisperer
  class Dsl
    class Base
      class << self
        attr_reader :container_class

        def link_dsl(name)
          define_method(name) do |&block|
            sub_dsl = Whisperer::Dsl.const_get(name.capitalize).new(
              @container.public_send(name)
            )

            sub_dsl.instance_eval &block
          end
        end

        def build
          if self.container_class
            new(
              self.container_class.new
            )
          else
            raise ArgumentError.new(
              'You should associate a container (model) with this dsl class, before building it'
            )
          end
        end

        def link_container_class(val)
          @container_class = val
        end
      end

      def initialize(container)
        @container = container
      end
    end # class Base
  end # module Dsl
end # module Whisperer