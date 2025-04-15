# frozen_string_literal: true
require 'spec_helper'

describe Hydra::Derivatives::Processors::Image do
  subject { described_class.new(file_name, directives) }

  let(:file_name) { 'file_name' }

  context 'using ImageMagick as the image processor' do
    before do
      allow(MiniMagick).to receive(:cli).and_return(:imagemagick)
    end

    around do |example|
      cached_image_processor = ENV['IMAGE_PROCESSOR']
      ENV['IMAGE_PROCESSOR'] = 'imagemagick'
      example.run
      ENV['IMAGE_PROCESSOR'] = cached_image_processor
    end

    context 'when arguments are passed as a hash' do
      before do
        allow(subject).to receive(:load_image_transformer).and_return(mock_image)
      end

      context 'with a multi-page pdf source file' do
        let(:first_page)  { instance_double('MockPage') }
        let(:second_page) { instance_double('MockPage') }
        let(:mock_image)  { instance_double('MockImageOfPdf', layers: [first_page, second_page]) }

        before do
          allow(mock_image).to receive(:type).and_return('PDF')
          allow(first_page).to receive(:combine_options) { |&block| block.call(first_page) }
          allow(second_page).to receive(:combine_options) { |&block| block.call(second_page) }
          allow(mock_image).to receive(:combine_options) { |&block| block.call(mock_image) }
        end

        context 'when default' do
          let(:directives) { { label: :thumb, size: '200x300>', format: 'png', quality: 75 } }

          it 'uses the first page' do
            expect(first_page).to receive(:flatten)
            expect(second_page).not_to receive(:flatten)
            expect(first_page).to receive(:resize).with('200x300>')
            expect(second_page).not_to receive(:resize)
            expect(first_page).to receive(:format).with('png')
            expect(second_page).not_to receive(:format)
            expect(first_page).to receive(:quality).with('75')
            expect(second_page).not_to receive(:quality)
            expect(subject).to receive(:write_image).with(first_page)
            subject.process
          end
        end

        context 'when specifying a layer' do
          let(:directives) { { label: :thumb, size: '200x300>', format: 'png', quality: 75, layer: 1 } }

          it 'uses the second page' do
            expect(second_page).to receive(:flatten)
            expect(first_page).not_to receive(:flatten)
            expect(second_page).to receive(:resize).with('200x300>')
            expect(first_page).not_to receive(:resize)
            expect(second_page).to receive(:format).with('png')
            expect(first_page).not_to receive(:format)
            expect(second_page).to receive(:quality).with('75')
            expect(first_page).not_to receive(:quality)
            expect(subject).to receive(:write_image).with(second_page)
            subject.process
          end
        end
      end

      context 'with an image source file' do
        before { allow(mock_image).to receive(:type).and_return('JPEG') }

        context 'when default' do
          let(:mock_image) { instance_double('MockImage') }
          let(:directives) { { label: :thumb, size: '200x300>', format: 'png', quality: 75 } }

          before do
            allow(mock_image).to receive(:combine_options) { |&block| block.call(mock_image) }
          end

          it 'uses the image file' do
            expect(mock_image).not_to receive(:layers)
            expect(mock_image).to receive(:flatten)
            expect(mock_image).to receive(:resize).with('200x300>')
            expect(mock_image).to receive(:format).with('png')
            expect(mock_image).to receive(:quality).with('75')
            expect(subject).to receive(:write_image).with(mock_image)
            subject.process
          end
        end

        context 'when specifying a layer' do
          let(:first_layer)  { instance_double('MockPage') }
          let(:second_layer) { instance_double('MockPage') }
          let(:mock_image)   { instance_double('MockImage', layers: [first_layer, second_layer]) }
          let(:directives)   { { label: :thumb, size: '200x300>', format: 'png', quality: 75, layer: 1 } }

          before do
            allow(first_layer).to receive(:combine_options) { |&block| block.call(first_layer) }
            allow(second_layer).to receive(:combine_options) { |&block| block.call(second_layer) }
            allow(mock_image).to receive(:combine_options) { |&block| block.call(mock_image) }
          end

          it 'uses the layer' do
            expect(second_layer).to receive(:flatten)
            expect(first_layer).not_to receive(:flatten)
            expect(second_layer).to receive(:resize).with('200x300>')
            expect(first_layer).not_to receive(:resize)
            expect(second_layer).to receive(:format).with('png')
            expect(first_layer).not_to receive(:format)
            expect(second_layer).to receive(:quality).with('75')
            expect(first_layer).not_to receive(:quality)
            expect(subject).to receive(:write_image).with(second_layer)
            subject.process
          end
        end
      end
    end

    describe '#process' do
      let(:directives) { { size: '100x100>', format: 'png' } }

      context 'when a timeout is set' do
        before do
          subject.timeout = 0.1
          allow(subject).to receive(:create_resized_image) { sleep 0.2 }
        end
        it 'raises a timeout exception' do
          expect { subject.process }.to raise_error Hydra::Derivatives::TimeoutError
        end
      end

      context 'when not set' do
        before { subject.timeout = nil }
        it 'processes without a timeout' do
          expect(subject).to receive(:process_with_timeout).never
          expect(subject).to receive(:create_resized_image).once
          subject.process
        end
      end

      context 'when running the complete command', requires_imagemagick: true do
        let(:file_name) { File.join(fixture_path, "test.tif") }

        it 'calls the ImageMagick version of create_resized_image' do
          expect(subject).to receive(:create_resized_image_with_imagemagick)
          subject.process
        end

        it 'converts the image' do
          expect(Hydra::Derivatives::PersistBasicContainedOutputFileService).to receive(:call).with(kind_of(StringIO), directives)
          subject.process
        end
      end
    end
  end

  context 'using GraphicsMagick' do
    let(:directives) { { size: '100x100>', format: 'png' } }
    let(:file_name) { File.join(fixture_path, "test.tif") }

    before do
      allow(MiniMagick).to receive(:cli).and_return(:graphicsmagick)
    end

    around do |example|
      cached_image_processor = ENV['IMAGE_PROCESSOR']
      ENV['IMAGE_PROCESSOR'] = 'graphicsmagick'
      example.run
      ENV['IMAGE_PROCESSOR'] = cached_image_processor
    end

    it 'calls the GraphicsMagick version of create_resized_image' do
      expect(subject).to receive(:create_resized_image_with_graphicsmagick)
      subject.process
    end

    context 'when running the complete command' do
      let(:file_name) { File.join(fixture_path, 'test.tif') }

      it 'converts the image' do
        expect(Hydra::Derivatives::PersistBasicContainedOutputFileService).to receive(:call).with(kind_of(StringIO), directives)
        subject.process
      end
    end
  end

  context 'using libvips' do
    let(:mock_image) { double }

    before do
      allow(subject).to receive(:write_image_with_vips).and_call_original
      allow(mock_image).to receive(:thumbnail_image).and_return(mock_image)
      allow(mock_image).to receive(:write_to_buffer)
    end

    around do |example|
      cached_image_processor = ENV['IMAGE_PROCESSOR']
      ENV['IMAGE_PROCESSOR'] = 'libvips'
      example.run
      ENV['IMAGE_PROCESSOR'] = cached_image_processor
    end

    context 'with an image source file' do
      before do
        allow(Vips::Image).to receive(:new_from_file).with(file_name).and_return(mock_image)
        allow(subject.output_file_service).to receive(:call)
        allow_any_instance_of(described_class).to receive(:`).with("vipsheader #{file_name}").and_return "300x386 uchar, 3 bands, srgb, tiffload"
      end

      context 'with size directive' do
        let(:file_name) { File.join(fixture_path, "test.tif") }

        context 'when shrinking image down' do
          let(:directives) { { label: :thumb, size: '200x300>', format: 'png', quality: 75 } }

          it 'interprets size directives from imagemagick/graphicsmagick syntax' do
            expect(mock_image).to receive(:thumbnail_image).with(200, height: 300, size: :down)
            subject.process
          end

          it 'writes the image file using format and quality directives' do
            expect(subject).to receive(:write_image_with_vips).with(mock_image, directives)
            expect(mock_image).to receive(:write_to_buffer).with('.png[Q=75]')
            subject.process
          end
        end

        context 'when sizing image up' do
          let(:directives) { { label: :thumb, size: '200x300<' } }

          it 'interprets size directives from imagemagick/graphicsmagick syntax' do
            expect(mock_image).to receive(:thumbnail_image).with(200, height: 300, size: :up)
            subject.process
          end
        end

        context 'when ignoring original aspect ratio' do
          let(:directives) { { label: :thumb, size: '200x300!' } }

          it 'interprets size directives from imagemagick/graphicsmagick syntax' do
            expect(mock_image).to receive(:thumbnail_image).with(200, height: 300, size: :force)
            subject.process
          end
        end
      end
    end

    context 'with a pdf source file' do
      before do
        allow(subject.output_file_service).to receive(:call)
        allow(Vips::Image).to receive(:new_from_file).with(any_args).and_call_original
      end

      let(:file_name) { File.join(fixture_path, "multipage.pdf") }

      context 'when no layer directive is specified' do
        let(:directives) { { label: :thumb, size: '200x300>', format: 'png', quality: 75 } }

        it 'does not load the file with a specific page (i.e. defaults to first page)' do
          expect(Vips::Image).to receive(:new_from_file).with(file_name)
          subject.process
        end
      end

      context 'when specifying a layer' do
        let(:directives) { { label: :thumb, size: '200x300>', format: 'png', quality: 75, layer: 1 } }

        it 'loads the file with the specified page' do
          expect(Vips::Image).to receive(:new_from_file).with(file_name, page: 1)
          subject.process
        end
      end
    end

    context 'when running the complete command' do
      let(:directives) { { size: '100x100>', format: 'png' } }

      context 'with an image' do
        let(:file_name) { File.join(fixture_path, "test.tif") }

        it 'calls the libvips version of create_resized_image' do
          expect(subject).to receive(:create_resized_image_with_libvips)
          subject.process
        end

        it 'converts the image' do
          expect(Hydra::Derivatives::PersistBasicContainedOutputFileService).to receive(:call).with(kind_of(StringIO), directives)
          subject.process
        end
      end
    end
  end

  context 'using default processor (imagemagick)' do
    before do
      allow(MiniMagick).to receive(:cli).and_return(:imagemagick)
    end

    around do |example|
      cached_image_processor = ENV['IMAGE_PROCESSOR']
      ENV['IMAGE_PROCESSOR'] = nil
      example.run
      ENV['IMAGE_PROCESSOR'] = cached_image_processor
    end

    context 'when arguments are passed as a hash' do
      before do
        allow(subject).to receive(:load_image_transformer).and_return(mock_image)
      end

      context 'with an image source file' do
        before { allow(mock_image).to receive(:type).and_return('JPEG') }

        context 'when default' do
          let(:mock_image) { instance_double('MockImage') }
          let(:directives) { { label: :thumb, size: '200x300>', format: 'png', quality: 75 } }

          before do
            allow(mock_image).to receive(:combine_options) { |&block| block.call(mock_image) }
          end

          it 'uses the image file' do
            expect(mock_image).not_to receive(:layers)
            expect(mock_image).to receive(:flatten)
            expect(mock_image).to receive(:resize).with('200x300>')
            expect(mock_image).to receive(:format).with('png')
            expect(mock_image).to receive(:quality).with('75')
            expect(subject).to receive(:write_image).with(mock_image)
            subject.process
          end
        end
      end
    end
  end
end
