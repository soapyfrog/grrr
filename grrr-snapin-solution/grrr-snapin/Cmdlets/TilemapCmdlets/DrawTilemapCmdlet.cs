using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
{
    [Cmdlet("Draw", "Tilemap")]
    public class DrawTilemapCmdlet : PSCmdlet
    {

        private Playfield pf;
        private Tilemap tilemap;

        private int offsetY, offsetX;
        private int x, y;
        private int w, h;

        [Parameter(Position = 0, Mandatory = true)]
        [ValidateNotNull]
        public Playfield Playfield { set { pf = value; } get { return pf; } }

        [Parameter(Position = 1, Mandatory = true)]
        [ValidateNotNull]
        public Tilemap Tilemap { get { return tilemap; } set { tilemap = value; } }

        [Parameter(Position = 2, Mandatory = true)]
        public int OffsetX { get { return offsetX; } set { offsetX = value; } }
        [Parameter(Position = 3, Mandatory = true)]
        public int OffsetY { get { return offsetY; } set { offsetY = value; } }

        [Parameter(Position = 3, Mandatory = true)]
        public int X { get { return x; } set { x = value; } }
        [Parameter(Position = 4, Mandatory = true)]
        public int Y { get { return y; } set { y = value; } }

        [Parameter(Position = 5)]
        public int Width { get { return w; } set { w = value; } }
        [Parameter(Position = 6)]
        public int Height { get { return h; } set { h = value; } }

        // FIXME: processing should probably not be in here.
        protected override void EndProcessing()
        {
            // optimisations?
            int tw = tilemap.TileWidth;
            int th = tilemap.TileHeight;
            int numlines = tilemap.MapHeight;

            // make a -ve offset in the playfield to start drawing tiles
            x -= offsetX % tw;
            y -= offsetY % th;


            // tx,ty is the index into the tile character map
            // TODO: check c# does proper truncate int div
            int tx = offsetX / tw;
            int ty = offsetY / th;

            // these vars get reset after the inner loop, so we save them here
            int txsaved = tx;
            int xsaved = x;

            // boundary x/y
            int bx = x + w + tw;
            int by = y + h + th;

            // draw the tiles
            while (y < by && ty < numlines)
            {
                string line = tilemap.Lines[ty];
                int linelen = line.Length;
                while (x < bx && tx < linelen)
                {
                    string ch = line.Substring(tx, 1);
                    Image img = (Image)tilemap.ImageMap[ch];
                    if (img!=null) pf.DrawImage(img, x, y);
                    tx++;
                    x += tw;
                }
                ty++;
                y += th;
                // reset outer loop vars
                tx = txsaved;
                x = xsaved;
            }

        }

    }


}
