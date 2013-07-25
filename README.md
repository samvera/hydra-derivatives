hydra-derivatives
=================

Derivative generation for hydra

If you have an ActiveFedora class like this:
```ruby
    class GenericFile < ActiveFedora::Base
        include Hydra::Derivatives
        
        has_file_datastream :content
        attr_accessor :mime_type
        
        # Use a block to declare which derivatives you want to generate
        makes_derivatives do |obj| 
          case obj.mime_type
          when 'application/pdf'
            obj.transform_datastream :content, { :thumb => "100x100>" }
          when 'audio/wav'
            obj.transform_datastream :content, { :mp3 => {format: 'mp3'}, :ogg => {format: 'ogg'} }, processor: :audio
          when 'video/avi'
            obj.transform_datastream :content, { :mp4 => {format: 'mp4'}, :webm => {format: 'webm'} }, processor: :video
          when 'image/png', 'image/jpg'
            obj.transform_datastream :content, { :medium => "300x300>", :thumb => "100x100>" }
          end
        end
    end
```

Or a class like this:

```ruby
    class GenericFile < ActiveFedora::Base
        include Hydra::Derivatives
    
        has_file_datastream :content
        attr_accessor :mime_type

        # Use a callback method to declare which derivatives you want
        makes_derivatives :generate_derivatives
        
        def generate_derivatives
          case mime_type
          when 'application/pdf'
            transform_datastream :content, { :thumb => "100x100>" }
          when 'audio/wav'
            transform_datastream :content, { :mp3 => {format: 'mp3'}, :ogg => {format: 'ogg'} }, processor: :audio
          when 'video/avi'
            transform_datastream :content, { :mp4 => {format: 'mp4'}, :webm => {format: 'webm'} }, processor: :video
          when 'image/png', 'image/jpg'
            transform_datastream :content, { :medium => "300x300>", :thumb => "100x100>" }
          end
        end
    end
```

And you add some content to it:

```ruby
   obj = GenericFile.new
   obj.content.content = File.open(...)
   obj.mime_type = 'image/tiff'
   obj.save
```

Then when you call `obj.create_derivatives` a new datastream, called 'thumbnail' will have been created, with a downsized image in it.

We recommend you run `obj.create_derivatives` in a background worker, because some derivative creation (especially videos) can take a long time.

You may want to adjust your path to add LibreOffice and Fits.sh support:
```bash
# in .bash_profile
export PATH=${PATH}:/Users/justin/workspace/fits-0.6.2:/Applications/LibreOffice.app/Contents/MacOS
```
