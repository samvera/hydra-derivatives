# hydra-derivatives [![Version](https://badge.fury.io/rb/hydra-derivatives.png)](http://badge.fury.io/rb/hydra-derivatives) [![Build Status](https://travis-ci.org/projecthydra/hydra-derivatives.png?branch=master)](https://travis-ci.org/projecthydra/hydra-derivatives) [![Dependency Status](https://gemnasium.com/projecthydra/hydra-derivatives.png)](https://gemnasium.com/projecthydra/hydra-derivatives)

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
          when 'image/png', 'image/jpg', 'image/tiff'
            transform_datastream :content, { :medium => "300x300>", :thumb => {size: "100x100>", datastream: 'thumbnail'} }
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

Then when you call `obj.create_derivatives` two new datastreams, 'thumbnail' and 'content_medium', will have been created with downsized images in them.

We recommend you run `obj.create_derivatives` in a background worker, because some derivative creation (especially videos) can take a long time.

# Installation 

Just add `gem 'hydra-derivatives'` to your Gemfile.

## Dependencies

* [FITS](http://fitstool.org/)
* [FFMpeg](http://www.ffmpeg.org/)
* [LibreOffice](https://www.libreoffice.org/)
* [ImageMagick](http://www.imagemagick.org/)

To enable LibreOffice, FFMpeg, ImageMagick and FITS support, you make sure they are on your path.  Most people will put that in their .bash_profile or somewhere similar.  For example:

```bash
# in .bash_profile
export PATH=${PATH}:/Users/justin/workspace/fits-0.6.2:/Applications/LibreOffice.app/Contents/MacOS
```

Alternatively, you can configure their paths:
```ruby
Hydra::Derivatives.ffmpeg_path = '/opt/local/ffmpeg/bin/ffmpeg'
Hydra::Derivatives.fits_path = '/opt/local/fits/bin/fits.sh'
Hydra::Derivatives.libreoffice_path = '/opt/local/libreoffice_path/bin/soffice'
```
