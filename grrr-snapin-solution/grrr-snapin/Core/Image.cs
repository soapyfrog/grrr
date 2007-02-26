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
    /// It encapsulates an array of buffer cells, has a effectiveWidth and effectiveHeight
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

        /// <summary>
        /// width of the image in cells
        /// </summary>
        public int Width { get { return width; } }
        /// <summary>
        /// height of the image in cells
        /// </summary>
        public int Height { get { return height; } }
        /// <summary>
        /// X reference point of the image (ie which cell is drawn at the target x,y point)
        /// </summary>
        public int RefX { get { return refx; } set { refx = value; } }
        /// <summary>
        /// X reference point of the image (ie which cell is drawn at the target x,y point)
        /// </summary>
        public int RefY { get { return refy; } set { refy = value; } }
        /// <summary>
        /// The character designated as transparent. No cell will be drawn with this value.
        /// </summary>
        public char Transparent { get { return t; } }
        /// <summary>
        /// The 2d array of cells representing this image.
        /// </summary>
        public BufferCell[,] Cells { get { return cells; } }

        /// <summary>
        /// Construct an Image
        /// </summary>
        /// <param name="cells"></param>
        /// <param name="t"></param>
        /// <param name="refx"></param>
        /// <param name="refy"></param>
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
