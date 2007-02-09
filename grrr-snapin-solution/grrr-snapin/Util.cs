using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;


namespace Soapyfrog.Grrr
{
    public class Util
    {
        /// <summary>
        /// Draw the image BufferCell array onto the playfield BufferCell array at 
        /// the x,y offsets, skipping cells that are transparent. 
        /// Drawing is clipped to the playfield, with fast exit if no overlap.
        /// </summary>
        /// <param name="img"></param>
        /// <param name="pf"></param>
        /// <param name="x"></param>
        /// <param name="y"></param>
        /// <returns></returns>
        public static int DrawImage(BufferCell[,] img, BufferCell[,] pf, int x, int y, char transparent)
        {
            int count = 0; // number of cells drawn

            // fast exclude images entirely outside of the buffer
            int bw = pf.GetUpperBound(1) + 1; // playfield width
            int iw = img.GetUpperBound(1) + 1; // image width
            if (x >= bw || (x + iw < 0)) return count; // fast quit

            // heights
            int bh = pf.GetUpperBound(0) + 1;
            int ih = img.GetUpperBound(0) + 1;

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
            if (transparent != 0)
            {
                // todo make this more efficient than cell-by-cell copying
                for (int r = 0; r < numrows; r++)
                {
                    for (int c = 0; c < numcols; c++)
                    {
                        BufferCell cell = img[(startrow + r), (startcol + c)];
                        if (cell.Character != transparent)
                        {
                            pf[(y + startrow + r), (x + startcol + c)] = cell;
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
                    Array.Copy(img, ioffset, pf, boffset, numcols); //fast copy whole row
                    ioffset += iw;
                    boffset += bw;
                    count += numcols;
                }
            }
            return count;

        }


        public static object runblock(ScriptBlock block, params object[] args)
        {
            //block.Invoke(args);
            return block.Invoke(args);
        }


    }
}
