require 'spec_helper'

describe Whisperer::Generator do
  let(:record) { double(sub_path: 'test') }

  let(:hash) {
    {
      'request' => {
        'uri'    => 'http://google.com',
        'method' => :get
      },
      'response' => {
        'body' => 'test body'
      },
      'recorded_at' => Time.now.httpdate
    }
  }

  let(:interraction) do
    VCR::HTTPInteraction.from_hash(hash)
  end

  describe '#generate' do
    let(:path_to_cassette_dir) { VCR.configuration.cassette_library_dir + '/test/' }
    let(:path_to_cassette)     { path_to_cassette_dir + 'testcassette.yml' }

    subject { described_class.new(record, 'testcassette') }

    before do
      allow(Whisperer::Preprocessors).to receive(:process!).and_return(record)
      allow(Whisperer::Convertors::Interaction).to receive(:convert).and_return(interraction)
    end

    after do
      File.delete(path_to_cassette)
      Dir.delete(path_to_cassette_dir)
    end

    it 'processes preprocessors' do
      expect(Whisperer::Preprocessors).to receive(:process!).with(record)

      subject.generate
    end

    it 'converts the record into VCR http interraction object' do
      expect(Whisperer::Convertors::Interaction).to receive(:convert).with(record).and_return(interraction)

      subject.generate
    end

    it 'generates a VCR cassette' do
      subject.generate

      expect(
        File.exists?(path_to_cassette)
      ).to be_truthy
    end

    it 'returns a generated cassette' do
      subject.generate

      expect(subject.generate).to match(/http_interactions:/)
    end

    it 'removes the duplication' do
      Dir.mkdir(path_to_cassette_dir)

      f = File.open(path_to_cassette, 'w')
      f.write('mytest')
      f.close

      subject.generate

      expect(subject.generate).to_not match(/mytest/)
    end
  end
end