# leica-q-autocrop

Leica Q allows one to frame pictures in full 28 mm view, or crop in 35
mm or 50 mm equivalent. These crop instructions are stored in DNG
files but Darktable as of now doesn't run them. This lua script will
make the crops automatically, provided you create the crop styles
yourself.

See instructions in the file header.

# Requirements

* Darktable 3.6 with Lua support enabled.
* Exiftool installed and available.
* Two styles named precisely:
  * `Leica Q: 35 mm`
  * `Leica Q: 50 mm`
* You may try your luck with the dtstyle files under `styles/`
  directory. 

## Leica Q2?

Q2 and Q2 Monochrom produce larger resolution files and feature an
extra crop mode, "75 mm". This script will probably work with Q2 and
Q2M files out of the box when 35/50 crop modes are used. The 75mm crop
mode will be ignored silently as for now. It is a simple modification
of the script to include support for that. You can ask me for details
and help.

## Caveats

This script will attempt to apply these styles to any file having the
appropriate EXIF metadata, so it is not limited to Leica Q files.
Importing some Q files to darktable you may get warning messages but
nothing should break.
