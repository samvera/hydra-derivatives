## 0.1.1 (2014-07-21)
 - Define a logger

## 0.1.0 (2014-05-09)
 - Add support for thumbnailing documents

## 0.0.8 (2014-04-09)
 - Add support for JPEG2000 Derivatives
 - Correcting Railtie initializer
 - Added ImageMagick dependency
 - Updated FITS URL
 - Adding input and output options to ffmpeg and video processor
 - Revert "Switch to streamio_ffmpeg for easier handling of ffmpeg arguments"
 - Switch to streamio_ffmpeg for easier handling of ffmpeg arguments
 - Adding Railtie for initialization

## 0.0.7 (2013-10-11)
 - Restore `Hydra::Derivatives::ExtractMetadata#to_tempfile`

## 0.0.6 (2013-10-10)
 - Added version badge
 - Adding Hydra::FileCharacterization
 - Updating CONTRIBUTING.md as per Hydra v6.0.0
 - Adding microsoft openxmlformats as output formats
 - Adding rewind to allow image data to be extracted properly
 - Replacing rmagick with mini_magick
 - Refactoring extraction to implicitly close
 - Changes audio encoding to libfdk_aac for video derivatives

## 0.0.5 (2013-07-25)
- Allow images to change format without being resize [Justin Coyne]

## 0.0.4 (2013-07-25)
- Handle invalid mime-type on the datastream [Justin Coyne]

## 0.0.3 (2013-07-25)
- Added LibreOffice support [Justin Coyne]
- Updating README [Matt Zumwalt]
- explicitly testing support for using makes_derivatives with callback methods
[Matt Zumwalt]
- support both block syntax and callbacks [Matt Zumwalt]
- Break out the config [Justin Coyne]
- sample implementation of block syntax [Matt Zumwalt]

## 0.0.2 (2013-07-24)
- Video and PDF support [Justin Coyne]
- API Change
- Video and audio processor accepts ':datastream' as an argument [Justin Coyne]

## 0.0.1 (2013-07-23)
- initial release
