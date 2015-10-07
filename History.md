## 3.0.0 (2015-10-07)
2015-10-07: Update to the containerized builds on travis [Justin Coyne]

2015-10-07: Add full text extraction as a processor [Justin Coyne]

2015-10-06: make quality be passed when creating an image [lutz]

2015-10-02: Put the processors into their own namespace [Justin Coyne]

2015-10-01: Make the IoDecorator initializer 1-3 args [Justin Coyne]

2015-09-29: Refactor to allow saving at a uri [Justin Coyne]

2015-09-28: Transcode local files [Justin Coyne]

2015-09-30: Remove ExtractMetadata. Fixes #76 [Justin Coyne]

2015-09-28: Rename the :datastream option to :output\_path [Justin Coyne]

2015-09-25: Remove my PSU address from Travis config [Michael J. Giarlo]

2015-09-21: Use IO.select so that all buffers get read (and the process can
terminate). Ref #81 [Justin Coyne]

2015-09-16: Log the exit code on failure [Justin Coyne]

2015-09-09: Update README.md [Justin Coyne]

2015-09-04: fits version specified [Nikitas Tampakis]

2015-08-28: Update directions to install openoffice headless [ci skip] [Justin
Coyne]

2015-08-28: List supported version of libreoffice [Justin Coyne]

2015-08-21: Update documentation to show IoDecorator [Justin Coyne]

2015-08-21: Add a deprecation horizion to the deprecation message [Justin Coyne]

2015-08-06: change call to transform\_file, in the deprecated method
transform\_datastream, to not pass a default options values, since the method def
for transform\_file already sets the default values. [Jose Blanco]

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
