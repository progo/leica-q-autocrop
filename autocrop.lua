--[[
Autocrop: crop 24 MP Leica Q images from its native 28 mm FOV to 35 mm
or 50 mm equivalents according to EXIF tags.

INSTALLATION
* copy this file in $CONFIGDIR/lua/ where CONFIGDIR
   is your darktable configuration directory
* add the following line in the file $CONFIGDIR/luarc:
   require "autocrop"

USAGE
* Prepare two styles, named "Leica Q: 35 mm" and "Leica Q: 50 mm".
  This script does the rest.

ADDITIONAL SOFTWARE NEEDED FOR THIS SCRIPT
* exiftool

]]

local darktable = require "darktable"


-- Forward declare the functions
local autocrop_apply_one_image, autocrop_apply_one_image_event, autocrop_apply,exiftool_attribute,capture

-- Receive the event triggered
function autocrop_apply_one_image_event(event,image)
   autocrop_apply_one_image(image)
end

-- Apply the style to an image, if it matches the tag condition
function autocrop_apply_one_image (image)
   local style_name

   -- Now we'll see if the image needs a crop
   local ok, crop_factor = pcall(exiftool_attribute, image.path .. '/' .. image.filename, "DigitalZoomRatio")

   if (not ok) then
      return
   end

   if crop_factor == '1.25' then
      style_name = "Leica Q: 35 mm"
   elseif crop_factor == '1.8' then
      style_name = "Leica Q: 50 mm"
   else
      return
   end

   local styles = darktable.styles
   local style

   for _, s in ipairs(styles) do
      if s.name == style_name then
         style = s
      end
   end

   if (not style) then
      darktable.print("style not found for autocrop: " .. style_name)
      return
   end

   darktable.styles.apply(style, image)
end 


function autocrop_apply(shortcut)
  local images = darktable.gui.action_images
  for _,image in pairs(images) do
    autocrop_apply_one_image(image)
  end
end

-- Retrieve the attribute through exiftool
function exiftool_attribute(path,attr)
  local cmd="exiftool -" .. attr .. " '" ..path.. "'";
  local exifresult=get_stdout(cmd)
  local attribute=string.match(exifresult,": (.*)")
  if (attribute == nil) then
    darktable.print( "Could not find the attribute " .. attr .. " using the command: <" .. cmd .. ">")
    -- Raise an error to the caller
    error( "Could not find the attribute " .. attr .. " using the command: <" .. cmd .. ">");
  end
  return attribute
end

-- run command and retrieve stdout
function get_stdout(cmd)
  -- Open the command, for reading
  local fd = assert(io.popen(cmd, 'r'))
  darktable.control.read(fd)
  -- slurp the whole file
  local data = assert(fd:read('*a'))

  fd:close()
  -- Replace carriage returns and linefeeds with spaces
  data = string.gsub(data, '[\n\r]+', ' ')
  -- Remove spaces at the beginning
  data = string.gsub(data, '^%s+', '')
  -- Remove spaces at the end
  data = string.gsub(data, '%s+$', '')
  return data
end

-- Registering events
darktable.register_event("autocrop-q",
                         "shortcut",
                         autocrop_apply,
                         "Crop the photo according to the EXIF data.")
darktable.register_event("autocrop-q",
                         "post-import-image",
                         autocrop_apply_one_image_event)


