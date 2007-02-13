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
    /// </summary>
    public class Image
    {
        private int width, height;
        private BufferCell[,] cells;
        private char t;

        public int Width { get { return width; } }
        public int Height { get { return height; } }
        public char Transparent { get { return t; } }
        public BufferCell[,] Cells { get { return cells; } }

        protected internal Image(BufferCell[,] cells, char t)
        {
            this.cells = cells;
            this.t = t;
            // cache dimensions for performance
            height = cells.GetUpperBound(0) + 1;
            width = cells.GetUpperBound(1) + 1;
        }
    }
}
