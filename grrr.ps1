#------------------------------------------------------------------------------
# grrr.ps1 
#
# A source-able PowerShell module to handle playfields,
# sprites, tiles, scrolling, eventing and other stuff
# that can be useful in writing games.
#
# To use this in a script:
# . grrr.ps1
#
# All functions etc will be created in the calling scope.
#
#------------------------------------------------------------------------------



#------------------------------------------------------------------------------
# Creates a play field.
#
# A play field is rectangular piece of console in the
# visible window, with a backing buffer of the same
# size outside the visible window.
#
# Drawing is always done in the backing buffer, then
# flushed to the visual buffer to give the illusion
# of instant rendering.
#
# See clear-playfield, flush-playfield, etc.
#
# The console should be set up appropriately before
# calling this (ie number of rows/cols, windows size
# and position).
#
# TODO: this semi-assumes that the visual part of the 
# console is at the top - likely in most uses, but
# perhaps should not do so.
#
function create-playfield {
  param(
      [int]$width=80,               # width of playfield
      [int]$height=25,              # height of playfield
      [int]$x,[int]$y,              # top left of the visual part
      [string]$colour="black"       # background colour (default black)
      )

  # back buffer goes at the bottom of the console buffer
  # TODO: need to handle different back buffers
  [int]$by = ($host.ui.rawui.BufferSize.Height - $height)

  return @{
    # vcoord and vrect are for the visual bit
    "vcoord" = new-object Management.Automation.Host.Coordinates -argumentList $x,$y
    "vrect"  = new-object Management.Automation.Host.Rectangle -argumentList $x,$y,($x+$width-1),($y+$height-1)
    # bcoord and brect are for the back buffer bit
    "bcoord" = new-object Management.Automation.Host.Coordinates -argumentList $x,$by
    "brect"  = new-object Management.Automation.Host.Rectangle -argumentList $x,$by,($x+$width-1),($by+$height-1)

    # default background fill cell
    "fillcell" = new-object Management.Automation.Host.BufferCell -argumentList ' ',"white",$colour,"Complete" 
    "xx" = 3
  }
}

#------------------------------------------------------------------------------
# Clears the back buffer of the playfield
#
# To see the results, flush-playfield
#
function clear-playfield {
  param(
      $playfield = $(throw "you must supply a playfield"),
      [string]$colour           # optional colour - if ommitted, uses playfield default
      )
  if ($colour -eq "") { $fillcell = $playfield.fillcell }
  else { $fillcell = new-object Management.Automation.Host.BufferCell -argumentList ' ',"white",$colour,"Complete" }
  $host.ui.rawui.SetBufferContents($playfield.brect,$fillcell)
}


#------------------------------------------------------------------------------
# Flushes a play field to visual buffer
#
# This copies the content of the back buffer to the
# visual buffer
#
function flush-playfield {
  param(
      $playfield = $(throw "you must supply a playfield")
      )
  $blitcells = $host.ui.rawui.GetBufferContents($playfield.brect)
  $host.ui.rawui.SetBufferContents($playfield.vcoord,$blitcells)
}



#------------------------------------------------------------------------------
# Create an image
#
# An image is made of of one or more lines of text with a specific
# foreground and background colour.
#
# Internally, it is converted into a BufferCell array
#
# The lines in the array do not need to be the same length; the resulting
# rectangle will be as wide as the largest string, with spaces padding
# the shorter ones on the right.
#
function create-image {
  param(
    [string[]] $lines=@("X"), # an array of text lines (should be same length)
    [string]$fg = "white",    # foreground colour (default white) 
    [string]$bg = "black"     # background colour (default black)
    ) 

  $lines | foreach {[int]$width=0}{$width = [Math]::Max($_.length,$width)}
  $height = $lines.count

  # create a buffercellarray 
  $bca = $host.ui.RawUI.NewBufferCellArray( $lines, $fg, $bg )

  return @{
    "bca"     = $bca     # array of buffercell arrays
    "width"   = $width
    "height"  = $height
  }
}


#------------------------------------------------------------------------------
# Draw an image into the back buffer of a playfield
#
function draw-image {
  param(
      $playfield = $(throw "you must supply a playfield"),
      $image = $(throw "you must supply an image"),
      [int]$x,
      [int]$y
      )
  $coord = new-object Management.Automation.Host.Coordinates -argumentList ($playfield.bcoord.X+$x),($playfield.bcoord.Y+$y)  
  $host.ui.rawui.SetBufferContents($coord,$image.bca)
  
}


#------------------------------------------------------------------------------
# Create a sprite.
#
# A sprite is set of animated images frames with a position (x,y) a depth
# and assorted other meta data, such as liveness.
#
function create-sprite {
  param(
    [object[]]$images = $(throw "you must supply an array of images"),
    [int]$x = 0,                  # initial x position
    [int]$y = 0,                  # initial y position
    [int]$z = 0,                  # initial z position
    [boolean]$alive = $true       # initial live status (won't be drawn if not alive)
    )
  
  return @{
    "images"      = $images
    "x"           = $x
    "y"           = $y
    "z"           = $z
    "alive"       = $alive
    "numframes"   = ($images.count)
    "fseq"        = 0               # frame sequence
  }
}


#------------------------------------------------------------------------------
# Draw a sprite in the back buffer of the play field, using the next
# frame of animation, or the specified frame.
#
function draw-sprite {
  param(
      $playfield = $(throw "you must supply a playfield"),
      $sprite = $(throw "you must supply a sprite"),
      [int]$frame = -1,     # which frame to draw (default is auto)
      [int]$dx = 0,         # amount to add to x value before drawing
      [int]$dy = 0,         # amount to add to y value before drawing
      [int]$dz = 0          # amount to add to z value before drawing
      )
  if ($frame -eq -1) {
    $f = (($sprite.fsec++) % ($sprite.numframes))
  }
  else {
    $f = ($frame % ($sprite.numframes))
  }
  # only update values if non-zero - prob quicker
  if ($dx) { $sprite.x += $dx }
  if ($dy) { $sprite.y += $dy }
  if ($dz) { $sprite.z += $dz }
  draw-image $playfield ($sprite.images[$f]) $sprite.x $sprite.y
}

    

