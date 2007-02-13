using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr.Core
{
    /// <summary>
    /// A play field is rectangular viewport in the visible
    /// part of the console (usually) with a backing buffer
    ///  held in a BufferCell array in memory.
    ///
    /// Drawing is always done in the backing buffer, then
    /// flushed to the visual buffer to give the illusion
    /// of instant rendering.
    ///
    /// See clear-playfield, flush-playfield, etc.
    ///
    /// The console should be set up appropriately before
    /// calling this (ie number of rows/cols, windows size
    /// and position).
    /// </summary>
    public class Playfield
    {
        private Size size;
        private Coordinates coord;
        private ConsoleColor background;

        private BufferCell[,] buffer, erasebuffer;
        private PSHostRawUserInterface ui;

        public int Width { get { return size.Width; } }
        public int Height { get { return size.Height; } }
        public int X { get { return coord.X; } }
        public int Y { get { return coord.Y; } }
        public ConsoleColor Background { get { return background; } }


        // stuff for fps stats
        private DateTime flushtime = DateTime.Now;
        private double[] stats = new double[20];
        private int nextstat = 0;
        private int fps;

        protected internal Playfield(PSHostRawUserInterface ui, int w, int h, int x, int y, ConsoleColor c)
        {
            this.ui = ui;
            coord = new Coordinates(x, y);
            size = new Size(w, h);
            background = c;
            erasebuffer = ui.NewBufferCellArray(size, new BufferCell(' ', ConsoleColor.White, background, BufferCellType.Complete));
            buffer = (BufferCell[,])erasebuffer.Clone();
        }

        /// <summary>
        /// Flush the contents of the playfield buffer to the screen.
        /// </summary>
        /// <param name="sync">the number of millis between flushes</param>
        public void Flush(int sync)
        {
            if (sync > 0)
            {
                TimeSpan elapsed = DateTime.Now - flushtime;
                int remain = sync - (int)elapsed.TotalMilliseconds;
                if (remain > 0) System.Threading.Thread.Sleep(remain);
            }
            DateTime thisflushtime = DateTime.Now;
            stats[nextstat++] = (thisflushtime - flushtime).TotalMilliseconds;
            nextstat = (nextstat + 1) % stats.Length;
            if (nextstat == 0)
            {
                int sum = 0, num = 0;
                foreach (int n in stats)
                {
                    if (n > 0) { sum += n; num++; }
                }
                if (num > 0) fps = (int)(1000.0 / (sum / num));
            }
            flushtime = thisflushtime;
            ui.SetBufferContents(coord, buffer);
        }

        public int FPS { get {return fps;}}

        /// <summary>
        /// Clear the playfield buffer to the original empty state 
        /// </summary>
        public void Clear()
        {
            Array.Copy(erasebuffer, buffer, buffer.Length);
        }

        /// <summary>
        /// Draw an Image into the playfield buffer at the specified coords, clipping
        /// to the playfield boundary.
        /// </summary>
        /// <param name="img">The Image to draw</param>
        /// <param name="x">x coord (zero-based from left)</param>
        /// <param name="y">y coord (zero-based from top)</param>
        /// <returns>The number of cells actually drawn (some may be transparent or clipped)</returns>
        public int DrawImage(Image img, int x, int y)
        {
            int count = 0; // number of cells drawn

            // fast exclude images entirely outside of the buffer
            int bw = Width; // playfield width
            int iw = img.Width; // image width
            if (x >= bw || (x + iw < 0)) return count; // fast quit

            // heights
            int bh = Height;
            int ih = img.Height;

            if (y >= bh || (y + ih < 0)) return count;  // fast quit

            // now handle partial clipping
            int startrow = 0;
            int numrows = ih;
            // clip top
            if (y < 0) { startrow = -y; numrows += y; }
            // clip bottom
            int overlap = bh - (y + ih);
            if (overlap < 0) numrows += overlap;
            // clip left
            int startcol = 0;
            int numcols = iw;
            int ilen = iw;
            if (x < 0) { startcol = -x; numcols += x; }
            // clip right
            overlap = bw - (x + iw);
            if (overlap < 0) numcols += overlap;

            // do the copying
            BufferCell[,] icells = img.Cells;
            char t = img.Transparent;
            if (t != 0)
            {
                for (int r = 0; r < numrows; r++)
                {
                    for (int c = 0; c < numcols; c++)
                    {
                        BufferCell cell = icells[(startrow + r), (startcol + c)];
                        if (cell.Character != t)
                        {
                            buffer[(y + startrow + r), (x + startcol + c)] = cell;
                            count++;
                        }
                    }
                }

            }
            else
            {
                int boffset = (y + startrow) * bw + x + startcol;
                int ioffset = startcol;
                
                for (int i = 0; i < numrows; i++)
                {
                    Array.Copy(icells, ioffset, buffer, boffset, numcols); //fast copy whole row
                    ioffset += iw;
                    boffset += bw;
                    count += numcols;
                }
            }
            return count;
        }

        /// <summary>
        /// Scan an image from the playfield buffer.
        /// The resulting image maybe smaller than requested
        /// if it is clipped at playfield boundary.
        /// </summary>
        /// <param name="x">x position in playfield</param>
        /// <param name="y">y position in playfield</param>
        /// <param name="w">width of image</param>
        /// <param name="h">height of image</param>
        /// <param name="t">transparent character</param>
        /// <returns>an Image</returns>
        public Image ScanImage(int x, int y, int w, int h, char t)
        {
            // determine intersecting rectangle
            // px,py->px2,py2 is playfield
            // x,y->x2,y2 is image
            int px = 0, py = 0;
            int px2 = Width, py2 = Height;
            int x2 = x + w, y2 = y + h;
            // ox,oy->ox2,oy2 is output intersection
            int ox = Math.Max(x, px);
            int oy = Math.Max(y, py);
            int ox2 = Math.Min(x2, px2);
            int oy2 = Math.Min(y2, py2);
            int owidth = ox2 - ox;
            int oheight = oy2 - oy;
            BufferCell[,] cells = ui.NewBufferCellArray(owidth, oheight, new BufferCell());
            // do copying
            for (int iy = 0; iy < oheight; iy++)
                for (int ix = 0; ix < owidth; ix++)
                    cells[iy, ix] = buffer[y + iy, x+ix];
            return new Image(cells, t);
        }

    }

}
