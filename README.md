hydra-derivatives
=================

Derivative generation for hydra

If you have an ActiveFedora class like this:
```ruby
    class GenericFile < ActiveFedora::Base
        include Hydra::Derivatives
        
        has_file_datastream :content
        attr_accessor :mime_type

        makes_derivatives_of :content, when: :mime_type, is_one_of: ['image/tiff', 'image/jpeg],
             derivatives: { :thumbnail => {size: "200x150>", datastream: 'thumbnail'} }
        makes_derivatives_of :content, when: :mime_type, is: 'application/pdf',
             derivatives: { :thumbnail => {size: "338x493", datastream: 'thumbnail'} }
        makes_derivatives_of :content, when: :mime_type, is_one_of: ['video/mpeg', 'video/avi'],
             derivatives: { :webm => {format: "webm", datastream: 'webm'}, :mp4 => {format: "mp4", datastream: 'mp4'} }, processors: :video
        makes_derivatives_of :content, when: :mime_type, is_one_of: ['audio/wav', 'audio/mpeg'],
             derivatives: {  :mp3 => {format: 'mp3', datastream: 'mp3'}, :ogg => {format: 'ogg', datastream: 'ogg'} }, processors: :audio
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
