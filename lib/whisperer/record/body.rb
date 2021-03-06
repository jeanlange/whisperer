module Whisperer
  # This class is used for request and response parts of HTTP
  # interactions, it should include only common attributes and methods.
  class Body
    include Virtus.model

    attribute :encoding,   String, default: proc { DefaultValue.new('UTF-8') }
    attribute :string,     String, default: proc { DefaultValue.new('') }

    # Attributes which are not part of Vcr response
    attribute :data_obj,         Object
    attribute :serializer,       Symbol, default: proc { DefaultValue.new(:json) }
    attribute :serializer_opts,  Hash,   default: {}
  end # class Body
end # module Whisperer