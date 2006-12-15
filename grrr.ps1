#------------------------------------------------------------------------------
# Copyright 2006 Adrian Milliner (adrian dot milliner at soapyfrog dot com)
#
# This work is licenced under the Creative Commons 
# Attribution-NonCommercial-ShareAlike 2.5 License. 
# To view a copy of this licence, visit 
# http://creativecommons.org/licenses/by-nc-sa/2.5/ 
# or send a letter to 
# Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# $Id$
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
# some functions to aide in creating std console objects
# not used much internally, as it's another thing to slow the whole thing down 
function new-coord($x,$y) { return new-object Management.Automation.Host.Coordinates -argumentList $x,$y }
function new-rect($left,$top,$right,$bottom) { return new-object Management.Automation.Host.Rectangle -argumentList $left,$top,$right,$bottom }
function new-size($w,$h) { return new-object Management.Automation.Host.Size -argumentList $w,$h }

#------------------------------------------------------------------------------
# Globals
[int]$script:__nextbufline  = 100    # should really set this properl with init-console

#------------------------------------------------------------------------------
# Initialise the console to be a certain visible width/height with 
# specified bufferspace for backing buffers.
#
# Buffers are not reclaimed when not used, so you can use this to
# reinitialise the console for new work
#
function init-console {
  param(
    [int]$width       = 120,    # width of console window
    [int]$height      = 50,     # height of console window
    [int]$bufwidth    = 200,    # width of buffer
    [int]$bufheight   = 1000    # height of buffer
  )
  # clear console and resize it
  clear-host
  $ui=$host.ui.rawui
  $ui.BufferSize = new-size $bufwidth $bufheight
  $ui.WindowSize = new-size $width $height

  # start allocating buffers from just below visible window
  $script:__nextbufline=$height+1
}

#------------------------------------------------------------------------------
# Creates a play field.
#
# A play field is rectangular viewport in the visible
# part of the console (usually) with a backing buffer
# away from the visible part of the console.
#
# The backing buffer can be bigger than the viewport,
# and the viewport can be set to show a sub part of the
# buffer.
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
      [int]$x=0,[int]$y=0,          # top left of the viewport
      [string]$bg="black",          # background colour (default black)
      [int]$vpwidth,                # width of viewport (default same as width)
      [int]$vpheight,               # height of viewport (default same as height)
      [int]$vpx=0,                  # viewport x offset into backbuf
      [int]$vpy=0                   # viewport y offset into backbuf
      )

  # if unspecified, make the viewport width/height the same as the
  if ($vpwidth -eq 0) { $vpwidth = $width }
  if ($vpheight -eq 0) { $vpheight = $height }

  # hack value to permit writing to the buffer lazily without worrying about 
  # going out of bounds
  [int]$private:margin = 10   

  # back buffer goes at next free position - no error checking
  [int]$by = $script:__nextbufline
  $script:__nextbufline += ($height + $margin)
  [int]$bx = $margin

  return @{
    # vpcoord and vprect are for the visual viewport
    "vpcoord" = new-object Management.Automation.Host.Coordinates -argumentList $x,$y
    "vprect"  = new-object Management.Automation.Host.Rectangle -argumentList $x,$y,($x+$vpwidth-1),($y+$vpheight-1)

    # pfcoord and pfrect are for the whole back buffer
    "pfcoord" = new-object Management.Automation.Host.Coordinates -argumentList $bx,$by
    "pfrect"  = new-object Management.Automation.Host.Rectangle -argumentList $bx,$by,($bx+$width-1),($by+$height-1)

    # vpbcoord and vpbrect are for the back buffer section for just the viewport
    "vpbcoord"= new-object Management.Automation.Host.Coordinates -argumentList ($bx+$vpx),($by+$vpy)
    "vpbrect" = new-object Management.Automation.Host.Rectangle -argumentList ($bx+$vpx),($by+$vpy),($bx+$vpx+$vpwidth-1),($by+$vpy+$vpheight-1)

    # somewhat redundant, but for convenience
    "vpx"     = $vpx
    "vpy"     = $vpy
    "vpwidth" = $vpwidth
    "vpheight"= $vpheight

    # default background fill cell
    "fillcell" = new-object Management.Automation.Host.BufferCell -argumentList ' ',"white",$bg,"Complete" 
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
      [string]$bg           # optional colour - if ommitted, uses playfield default
      )
  if ($bg -eq "") { $fillcell = $playfield.fillcell }
  else { $fillcell = new-object Management.Automation.Host.BufferCell -argumentList ' ',"white",$bg,"Complete" }
  $host.ui.rawui.SetBufferContents($playfield.pfrect,$fillcell)
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
  $blitcells = $host.ui.rawui.GetBufferContents($playfield.vpbrect)
  $host.ui.rawui.SetBufferContents($playfield.vpcoord,$blitcells)
}

#------------------------------------------------------------------------------
# Reposition the viewport for the playfield.
#
# Updates the internals - makes no attempt to validate anything as
# PowerShell is soooooo f-ing slow, it's just not worth it.
#
# You need to call flush-playfield to see the result.
#
function set-playfield-viewport {
  param(
    $playfield = $(throw "you must supply a playfield"),
    $vpx = 0,       # new x offset into playfield for viewport
    $vpy = 0        # new y offset into playfield for viewport
    )

  $x = $vpx + $playfield.pfcoord.X
  $y = $vpy + $playfield.pfcoord.Y
  $vpwidth = $playfield.vpwidth
  $vpheight = $playfield.vpheight
  
  $playfield.vpbcoord = new-object Management.Automation.Host.Coordinates -argumentList $x,$y
  $playfield.vpbrect = new-object Management.Automation.Host.Rectangle -argumentList $x,$y,($x+$vpwidth-1),($y+$vpheight-1)

  $playfield.vpx = $vpx
  $playfield.vpy = $vpy
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
  $coord = new-object Management.Automation.Host.Coordinates -argumentList ($playfield.pfcoord.X+$x),($playfield.pfcoord.Y+$y)  
  $host.ui.rawui.SetBufferContents($coord,$image.bca)
  
}


#------------------------------------------------------------------------------
# Create a sprite.
#
# A sprite is set of animated images frames with a position (x,y) a depth
# and assorted other meta data, such as liveness.
#
# All the script blocks take the sprite as the first param ($args[0]).
#
function create-sprite {
  param(
    [object[]]$images = $(throw "you must supply an array of images"),
    [int]$x = 0,                  # initial x position
    [int]$y = 0,                  # initial y position
    [int]$z = 0,                  # initial z position
    [boolean]$alive = $true,      # initial live status (won't be drawn if not alive)
    $handlers = $null             # created by create-spritehandlers (and family)
    )
  
  $sprite = @{
    "images"      = $images
    "x"           = $x
    "y"           = $y
    "z"           = $z
    "alive"       = $alive
    "numframes"   = ($images.count)
    "fseq"        = 0               # frame sequence
    "handlers"    = $handlers
  }
  if ($handlers -and $handlers.didinit) { & $handlers.didinit $sprite }
  return $sprite
}

#------------------------------------------------------------------------------
# Create a sprite handlers.
#
# Sprite handlers are script blocks that are invoked at certain points
# in the sprite lifecycle. When executed, the sprite itself is passed
# as the first param ($args[0])
#
# See specialist forms for this method, eg create-motion-spritehandlers
#
function create-spritehandlers {
  param(
    [scriptblock]$didinit = $null,   # called after a sprite has been created
    [scriptblock]$willdraw = $null,  # called before a sprite is drawn
    [scriptblock]$diddraw = $null    # called after a sprite is drawn
  )
  return @{
    # script blocks used to control sprite
    "didinit"     = $didinit
    "willdraw"    = $willdraw
    "diddraw"     = $diddraw
  }
}


#------------------------------------------------------------------------------
# Draw a sprite in the back buffer of the play field, using the next
# frame of animation, or the specified frame.
#
# TODO: deal with alive, and states
#
function draw-sprite {
  param(
      $playfield = $(throw "you must supply a playfield"),
      $sprite = $(throw "you must supply a sprite"),
      [int]$frame = -1     # which frame to draw (default is auto)
      )
  $private:h = $sprite.handlers
  if ($h -and $h.willdraw) { &($h.willdraw) $sprite }
  if ($frame -eq -1) {
    $sprite.fsec = (($sprite.fsec+1) % ($sprite.numframes))
  }
  else {
    $sprite.fsec = ($frame % ($sprite.numframes))
  }
  draw-image $playfield ($sprite.images[$sprite.fsec]) $sprite.x $sprite.y
  if ($h -and $h.diddraw) { &($h.diddraw) $sprite }
}

    
#------------------------------------------------------------------------------
# Determine if two sprites are overlapping
#
# Returns $true if they are, $false if not.
#
function overlap-sprite? {
  param(
    $s1 = $(throw "you must supply sprite s1"),
    $s2 = $(throw "you must supply sprite s2")
    )
  # TODO: this is fairly efficient except for all the derefs :(
  $s1image = $s1.images[$s1.fseq]
  $s2image = $s2.images[$s2.fseq]
  [int]$s1right = $s1.x + $s1image.width 
  [int]$s2right = $s2.x + $s2image.width 
  [int]$s1bottom = $s1.y + $s1image.height 
  [int]$s2bottom = $s2.y + $s2image.height 
  return ! ($s2.x -ge $s1right -or $s2right -lt $s1.x -or $s2.y -ge $s1bottom -or $s2bottom -lt $s1.y ) 
}


#------------------------------------------------------------------------------
# Draw a set of sprites on the playfield
#
# TODO: only draw sprites that are on the playfield
#
function draw-sprites {
  param(
      $playfield = $(throw "you must supply a playfield"),
      $sprites = $(throw "you must supply a sprite array, sprites")
      )
  $sprites | where { $_.alive} | foreach {
    draw-sprite -playfield $playfield -sprite $_
  }
}



#------------------------------------------------------------------------------
# Create a tilemap - used for drawing large tile-based maps from a char based
# mapping to images.
#
function create-tilemap {
  param(
    [string[]] $lines = $(throw "lines missing: array of strings"),
    $imagemap = $(throw "imagemap missing: hash of char to image"),
    [int]$tilewidth = 3,
    [int]$tileheight = 2
  ) 
 
  return @{
    "lines"     = $lines
    "imagemap"  = $imagemap
    "tileheight"= $tileheight
    "tilewidth" = $tilewidth
    "mapheight" = $lines.length
    "mapwidth"  = $lines[0].length
  }
}

#------------------------------------------------------------------------------
# Draw the tilemap into the playfield with specified cell offset.
#
# The map is drawn into x,y,w,h with offset offsetx,offsety into the map.
# This offset is a char offset, not a tile offset.
#
function draw-tilemap {
  param(
      $playfield = $(throw "you must supply a playfield"),
      $tilemap = $(throw "you must supply a tilemap"),
      $offsetx = 0,         # x offset into the tilemap
      $offsety = 0,         # y offset into the tilemap
      $x = 0, $y = 0,       # x,y pos in playfield to draw
      $w = 0, $h = 0        # width, height to draw in playfield (default is available width)
    )

  # tw,th is an optimisation to avoid requerying the hash
  [int]$tw = $tilemap.tilewidth
  [int]$th = $tilemap.tileheight
  # other optimisations
  [int]$numlines=$tilemap.lines.length

  # make a negative offset in the playfield to start drawing tiles
  $x -= ($offsetx % $tw)
  $y -= ($offsety % $th)
  
  # tx,ty is the index into the tile character map
  # (needs Floor as ps has no integer division)
  [int]$tx = [Math]::Floor($offsetx / $tw)
  [int]$ty = [Math]::Floor($offsety / $th)

  # these vars get reset after the inner loop, so we save them here
  [int]$txsaved = $tx
  [int]$xsaved = $x

  # boundary x/y
  [int]$bx = $x + $w + $tw 
  [int]$by = $y + $h + $th

  # draw the tiles
  while ($y -lt $by -and $ty -lt $numlines) {
    $line = $tilemap.lines[$ty]
    $linelen = $line.length
    while ($x -lt $bx -and $tx -lt $linelen) {
      [string]$ch = $line[$tx]
      $img = $tilemap.imagemap[$ch]
      if ($img) { draw-image $playfield $img $x $y }
      $tx++
      $x += $tw
    }
    $ty++
    $y += $th
    #reset outer loop vars
    $tx = $txsaved
    $x = $xsaved
  }
}


#------------------------------------------------------------------------------
# Create spritehandlers for a given motion path.
#
# Path is in the form: (direction[amount] )+
#
# Eg:  "n5 e h3 s5 w"
# meaning north 5, east 1, hold for 3 south 5, west 1
#
# The motion is repeated.
#
function create-spritehandlers-for-motionpath {
  param(
    [string]$mpath = $(throw "you must supply a motion path")
    )
  $deltas = @()
  # split by space and parse the commands - crude but effective
  $mpath.split(" ") | foreach {
    $delta = $null
    $off = 1
    switch -wildcard ($_) {
      "ne*" { $delta=1,-1 ; $off=2; break } 
      "se*" { $delta=1,1 ; $off=2; break } 
      "sw*" { $delta=-1,1 ; $off=2; break } 
      "nw*" { $delta=-1,-1 ; $off=2; break } 
      "n*" { $delta=0,-1 ; break} 
      "s*" { $delta=0,1 ; break} 
      "e*" { $delta=1,0 ; break} 
      "w*" { $delta=-1,0 ; break} 
      "h*" { $delta=0,0 ; break} 
      default { throw "Illegal path command: $_" }
    }
    if ($delta) {
      [int]$n=1
      if ($_.length -ge $off) { $n = [int]$_.substring($off) }
      1..$n | foreach { $deltas += 1; $deltas[-1] = $delta }
    }
  }
  # didinit handler is used to place state in the sprite instance (curdelta)
  [scriptblock]$didinit = {
    $s = $args[0]
    $s.curdelta = 0
  }
  # willdraw handler is used to update the x,y with each delta in turn
  [scriptblock]$willdraw = {
        $s = $args[0]
        $h = $s.handlers
        $d = $h.deltas[$s.curdelta]
        $s.curdelta = (($s.curdelta + 1) % $h.numdeltas)
        $s.x += $d[0]
        $s.y += $d[1]
  }
  # handlers should not have any statethemselves... so all this is readonly(ish)
  return @{
    "deltas"      = $deltas
    "numdeltas"   = $deltas.length
    "didinit"     = $didinit
    "willdraw"    = $willdraw
  }
}

