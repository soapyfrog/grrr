using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr.Core
{
    /// <summary>
    /// Class used to represent the image - created by the cmdlet
    /// It encapsulates an array of buffer cells, has a width and height
    /// and reference point offset.
    /// If you draw an image at x,y, the reference point is at x,y which
    /// might not be topleft (could be in the middle).
    /// </summary>
    public class Image
    {
        private int width, height;
        private int refx, refy;
        private BufferCell[,] cells;
        private char t;

        public int Width { get { return width; } }
        public int Height { get { return height; } }
        public int RefX { get { return refx; } }
        public int RefY { get { return refy; } }
        public char Transparent { get { return t; } }
        public BufferCell[,] Cells { get { return cells; } }

        protected internal Image(BufferCell[,] cells, char t,int refx,int refy)
        {
            this.cells = cells;
            this.t = t;
            this.refx = refx;
            this.refy = refy;
            // cache dimensions for performance
            height = cells.GetUpperBound(0) + 1;
            width = cells.GetUpperBound(1) + 1;
        }
    }
}
