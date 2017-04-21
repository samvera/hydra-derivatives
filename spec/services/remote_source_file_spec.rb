require 'spec_helper'

class TestObject < ActiveFedora::Base
  attr_accessor :source_file_name
end

describe Hydra::Derivatives::RemoteSourceFile do
  describe '.call' do
    let(:file_name) { 'my_source_file.mp4' }

    context 'when you pass in a String file name' do
      let(:input_obj) { file_name }
      let(:options) { Hash.new }

      it 'it yields the file name' do
        expect do |blk|
          described_class.call(input_obj, options, &blk)
        end.to yield_with_args(file_name)
      end
    end

    context 'when you pass in an ActiveFedora::Base object ' do
      let(:input_obj) { TestObject.new(source_file_name: file_name) }
      let(:options) { { source: :source_file_name } }

      it 'it yields the file name' do
        expect do |blk|
          described_class.call(input_obj, options, &blk)
        end.to yield_with_args(file_name)
      end
    end
  end
end
