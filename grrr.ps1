#------------------------------------------------------------------------------
# Copyright 2006 Adrian Milliner (ps1 at soapyfrog dot com)
# http://ps1.soapyfrog.com
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
# To use it, just source it like this:
# . <path-to>\grrr.ps1
#
# You may like to include that line in your $profile
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Globals
$script:grrr_ui = $host.ui.rawui  # saves dereferencing all the time
$script:grrr_version=0,2,"alpha" # major,minor,state
$script:grrr_versionstr=[string]::join(".",$script:grrr_version)

#------------------------------------------------------------------------------
# Create a Coord
function new-coord($x,$y) { return new-object Management.Automation.Host.Coordinates -argumentList $x,$y }

#------------------------------------------------------------------------------
# Create a Rectangle
function new-rect($left,$top,$right,$bottom) {
  if ($left -gt $right) { $left,$right = $right,$left }
  if ($top -gt $bottom) { $top,$bottom = $bottom,$top }
  return new-object Management.Automation.Host.Rectangle -argumentList $left,$top,$right,$bottom 
}

#------------------------------------------------------------------------------
# Create a Size
function new-size($w,$h) { return new-object Management.Automation.Host.Size -argumentList $w,$h }

#------------------------------------------------------------------------------
# Initialise the console to be a certain visible width/height 
#
function init-console {
  param(
    [int]$width       = 120,    # width of console window
    [int]$height      = 50      # height of console window
  )
  # clear console and resize it
  # enlage the buffer size if required
  $bw = $grrr_ui.BufferSize.Width
  $bh = $grrr_ui.BufferSize.Height
  $bw = [Math]::Max($width,$bw)
  $bh = [Math]::Max($height,$bh)
  clear-host
  $grrr_ui.BufferSize = new-size $bw $bh
  $grrr_ui.WindowSize = new-size $width $height
}

#------------------------------------------------------------------------------
# Creates a play field.
#
# A play field is rectangular viewport in the visible
# part of the console (usually) with a backing buffer
# held in a BufferCell array in memory.
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
      [string]$bg="black"           # background colour (default black)
      )

  # create a back buffer as a 2d BufferCell array and clone it 
  # so we have a fast erasebuffer
  $buflines = @(" " * $width) * $height
  $buffer=$grrr_ui.NewBufferCellArray($buflines,"white",$bg)
  $erasebuffer=$buffer.Clone();

  return @{
    # coord and rect are for the visual viewport
    # these are used when blitting the buffer to the console
    # nothing should be written outside of 'rect'
    "coord" = new-coord $x $y
    "rect"  = new-rect $x $y ($x+$width-1) ($y+$height-1)

    # the buffers themselves
    "buffer"      = $buffer
    "erasebuffer" = $erasebuffer

    # somewhat redundant, but for convenience
    "width"       = $width
    "height"      = $height
    "buffersize"  = [int]($width * $height)

    # time last flush occured
    "flushtime"   = (get-date)
  }
}

#------------------------------------------------------------------------------
# Clears the back buffer of the playfield
#
# To see the results, flush-playfield
#
function clear-playfield {
  param( $playfield = $(throw "you must supply a playfield"))
  [Array]::Copy($playfield.erasebuffer,$playfield.buffer,$playfield.buffersize)
}


#------------------------------------------------------------------------------
# Flushes a play field to visual buffer
#
# This copies the content of the back buffer to the
# visual buffer
#
# Optionally takes a sync time (ms) where this function will sleep
# so that the time between flushes is constant
#
function flush-playfield {
  param( 
    $playfield = $(throw "you must supply a playfield"),
    [int]$sync=0       # the number of milliseconds between flushes
  )
  if ($sync) {
    $now = get-date
    $elapsed = $now - $playfield.flushtime
    $remain = $sync - ($elapsed.TotalMilliseconds)
    if ($remain -ge 0) { sleep -millis $remain }
    $playfield.flushtime = get-date
  }
  $grrr_ui.SetBufferContents($playfield.coord,$playfield.buffer)
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
    [string]$bg = "black",    # background colour (default black)
    [char]$transparent = [char]0  # character to indicate transparency (0=none)
    ) 
  
  [int]$width=0
  foreach ($line in $lines) {
    $width = [Math]::Max($line.length,$width)
  }
  [int]$height = $lines.Count

  # create a buffercellarray 
  $bca = $grrr_ui.NewBufferCellArray( $lines, $fg, $bg )

  return @{
    "bca"         = $bca          # buffercell array
    "width"       = $width        # width of image
    "height"      = $height       # height of image
    "transparent" = $transparent  # char to use for transparency
  }
}


#------------------------------------------------------------------------------
# Load images from a file
function get-images {
  param($filename=$(throw "supply a filename"))
  $p = resolve-path $filename # will throw if doesn't exist
  $images = @{}
  $translations = @{}
  $lines = $null
  $id = $null
  $fg = $null
  $bg = $null
  get-content $p | foreach {
    if ($_ -match "^#.*") {
      if ($_ -match "^#begin\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)") {
        $lines = @()
        $id = $matches[1]
        $fg = $matches[2]
        $bg = $matches[3]

        write-debug "found image $curid"
      }
      elseif ($_ -match "^#end") {
        if ($id) {
          write-debug "closing image"
          $images[$id] = create-image $lines -fg $fg -bg $bg
          $id=$null
        }
        else { write-warning "Unexpected #end token" }
      }
      elseif ($_ -match "^#translate\s+([^\s]+)\s+([^\s]+)") {
        $translations[[string][char]$matches[1]] = [string][char][int]$matches[2]
      }
      elseif ($_ -match "^#!") {
        # a comment
      }
      else {
        write-warning "Unknown token: $_"
      }
    }
    else {
      if ($id) {
        write-debug "adding line $_"
        $l = $_
        foreach ($t in $translations.keys) {
          $l = $l.replace($t,$translations[$t])
        }
        $lines += $l
      }
      else { 
        if (-not $_ -match "^\s*$" ){ write-warning "Skipping $_" }
      }
    }
  }
  $images
}

#------------------------------------------------------------------------------
# Draw an image into the back buffer of a playfield.
#
# This takes the image buffercell array and write its
# cell lines to the playfield buffer.
#
# Drawing is clipped to the edges and fast fails if 
# completely outside the buffer bounds.
#
function draw-image {
  param(
      $playfield = $(throw "you must supply a playfield"),
      $image = $(throw "you must supply an image"),
      [int]$x,
      [int]$y
      )
  # fast exclude images entirely outside of the buffer
  [int]$bw = $playfield.width
  [int]$iw = $image.width
  if ($x -ge $bw -or ($x+$iw -lt 0) ) { return } # fast quit
  [int]$bh = $playfield.height
  [int]$ih = $image.height
  if ($y -ge $bh -or ($y+$ih -lt 0) ) { return } # fast quit

  # now handle partial clipping
  [int]$startrow = 0
  [int]$numrows = $ih
  # clip top
  if ($y -lt 0) {$startrow = -$y; $numrows += $y}
  # clip bottom
  [int]$overlap = $bh - ($y+$ih)
  if ($overlap -lt 0) {$numrows += $overlap}
  # clip left
  [int]$startcol = 0
  [int]$numcols = $iw
  [int]$ilen=$iw
  if ($x -lt 0) {$startcol=-$x; $numcols += $x}
  # clip right
  $overlap = $bw - ($x+$iw)
  if ($overlap -lt 0) {$numcols += $overlap}

  # do the copying
  $ibca = $image.bca
  $bbca = $playfield.buffer
  [char]$transparent=$image.transparent
  if ($transparent) {
    # todo make this more efficient than cell-by-cell copying
    for ([int]$r=0;$r -lt $numrows;$r++) {
      for ([int]$c=0;$c -lt $numcols;$c++) {
        $cell = $ibca[($startrow+$r),($startcol+$c)]
        if ($cell.Character -ne $transparent) {
          $bbca[($y+$startrow+$r),($x+$startcol+$c)] = $cell
        }
      }
    }

  }
  else {
    [int]$boffset = ($y+$startrow) * $bw + $x + $startcol
    [int]$ioffset = $startcol
    for ([int]$i=0; $i -lt $numrows; $i++) {
      [Array]::Copy($ibca,$ioffset,$bbca,$boffset,$numcols) #fast copy whole row
      $ioffset += $iw
      $boffset += $bw
    }
  }
}


#------------------------------------------------------------------------------
# Create a sprite.
#
# A sprite is set of animated image frames with a position (x,y) a depth
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
    $handlers = $null,            # created by create-spritehandlers (and family)
    $animrate = 1                 # switch frame every $animrate frames
    )
  
  $sprite = @{
    "images"      = $images
    "x"           = $x
    "y"           = $y
    "z"           = $z
    "alive"       = $alive
    "numframes"   = ($images.count)
    "fseq"        = 0               # frame sequence
    "animrate"    = $animrate
    "animcounter" = 0 # when reaches animrate, fseq++
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
    if (($sprite.animcounter++) -eq $sprite.animrate) {
      $sprite.animcounter = 0;
      $sprite.fseq = (($sprite.fseq+1) % ($sprite.numframes))
    }
  }
  else {
    $sprite.fseq = ($frame % ($sprite.numframes))
  }
  draw-image $playfield ($sprite.images[$sprite.fseq]) $sprite.x $sprite.y
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
  foreach ($s in $sprites) {
    if ($s.alive) {
      draw-sprite -playfield $playfield -sprite $s
    }
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
      [int]$offsetx = 0,         # x offset into the tilemap
      [int]$offsety = 0,         # y offset into the tilemap
      [int]$x = 0, [int]$y = 0,  # x,y pos in playfield to draw
      [int]$w = 0, [int]$h = 0   # width, height to draw in playfield 
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
    [int[]]$delta = $null
    [int]$off = 1
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
    [int]$s.curdelta = 0
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



#------------------------------------------------------------------------------
# Draw a line from x1,y1 to x2,y2 using the specified image
#
function draw-line {
  param(
    $pf = $(throw "you must supply a playfield"),
    [int]$x1,[int]$y1,
    [int]$x2,[int]$y2,
    $img = $(throw "you must supply an image")
  )

  [int]$dx = $x2-$x1
  [int]$dy = $y2-$y1

  [int]$adx = [Math]::Abs($dx)
  [int]$ady = [Math]::Abs($dy)

  if ($adx -gt $ady) {
    $len =$adx
    [int]$ix = $dx/$adx
    if ($adx -eq 0) { $iy=0} else {$iy = $dy/$adx}
    $y = $y1
    $x = $x1
    for ([int]$i=0; $i -le $len; $i++) {
      draw-image $pf $img $x $y
      $y += $iy
      $x += $ix
    }
  }
  else {
    $len =$ady
    [int]$iy = $dy/$ady
    $ix = $dx/$ady
    if ($ady -eq 0) { $ix=0} else {$ix = $dx/$ady}
    $x = $x1
    $y = $y1
    for ([int]$i=0; $i -le $len; $i++) {
      draw-image $pf $img $x $y
      $x += $ix
      $y += $iy
    }
  }
}

#------------------------------------------------------------------------------
# Prepare a wave file for playing
#
# Specify a name and a file name, play it later using play-sound
#
function prepare-sound {
  param(
    [string]$name = $(throw "You need to supply a sound name"),
    [string]$path = $(throw "You need to supply a wave file path")
    )
  if (-not (test-path variable:\global:grrr_sounds)) { $script:grrr_sounds = @{} }
  $p = resolve-path "$path" -erroraction "silentlycontinue"
  if ($p) {
    $pm = new-object media.soundplayer ($p.path)
    $pm.load()
    $script:grrr_sounds[$name] = $pm
  }
  else {
    write-debug "Unable to find sound $name"
  }
}

#------------------------------------------------------------------------------
# Draw a string at the specified position in the playfield.
#
# This is really a wrapper around create-image and draw-image
#
function draw-string {
  param(
      $playfield  = $(throw "you must supply a playfield"),
      $string     = $(throw "you must supply a string"),
      [int]$x     = 0,
      [int]$y     = 0,
      [string]$fg = "white",
      [string]$bg = "black"
      )
  $image = create-image -lines @($string) -fg $fg -bg $bg
  draw-image $pf $image $x $y
}

#------------------------------------------------------------------------------
# Play a prepared sound asynchronously.
#
# Nothing happens if the sound is not prepared.
#
# TODO: support high/lowpriority sounds
#
function play-sound {
  param([string]$name=$(throw "supply a prepared sound name"))
  $pm = $script:grrr_sounds[$name]
  if ($pm) { $pm.play() }
}



