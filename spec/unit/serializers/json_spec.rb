require 'spec_helper'

class TestChildJson < Whisperer::Serializers::Json
  protected
    def post_prepare_data(data)
      {test: data}
    end
end

class TestObj
  def initialize(attrs)
    @first_name = attrs[:first_name]
    @last_name  = nil
  end

  # we need to make sure that our serializer uses accessors methods
  # when it exists.
  def last_name
    'Snow'
  end
end

class TestObjWithAttrs
  def attributes
    {
      first_name: 'John',
      last_name:  'Snow'
    }
  end
end

describe Whisperer::Serializers::Json do
  describe '#serialize' do
    shared_examples 'serializing an object' do
      it 'returns json string with serialized attributes' do
        expect(subject.serialize).to eq('{"first_name":"John","last_name":"Snow"}')
      end

      context 'when the class is inherited' do
        subject { TestChildJson.new(given_obj) }

        context 'when the child class alters the data structure' do
          it 'returns the altered structure' do
            expect(subject.serialize).to eq(
              '{"test":{"first_name":"John","last_name":"Snow"}}'
            )
          end
        end
      end
    end

    let(:attrs) {
      {
        first_name: 'John',
        last_name:  'Snow'
      }
    }

    subject { described_class.new(given_obj) }

    context 'when an open struct object is given' do
      let(:given_obj) {
        OpenStruct.new(attrs)
      }

      it_behaves_like 'serializing an object'
    end

    context 'When a pure ruby object is given' do
      let(:given_obj) {
        TestObj.new(attrs)
      }

      it_behaves_like 'serializing an object'
    end

    context 'when an object has the attributes method' do
      let(:given_obj) {
        TestObjWithAttrs.new
      }

      it_behaves_like 'serializing an object'
    end
  end
end