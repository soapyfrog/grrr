using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
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

    /// <summary>
    /// Create an image from a set of lines of text, foreground and background colours and
    /// a character used for transparency.
    /// </summary>
    [Cmdlet("Create", "Image")]
    public class CreateImageCmdlet : PSCmdlet
    {
        private string[] lines;
        private ConsoleColor f = ConsoleColor.White, b = ConsoleColor.Black;
        private char t = '\0';

        private List<string> allLines = new List<string>();

        [Parameter(Position = 0, ValueFromPipeline = true, Mandatory = true)]
        public string[] Lines { set { lines = value; } get { return lines; } }

        [Parameter(Position = 1)]
        public ConsoleColor Foreground { set { f = value; } }

        [Parameter(Position = 2)]
        public ConsoleColor Background { set { b = value; } }

        [Parameter(Position = 3)]
        public char Transparent { set { t = value; } }


        protected override void ProcessRecord()
        {
            if (lines != null)
            {
                allLines.AddRange(lines);
            }
        }

        protected override void EndProcessing()
        {
            BufferCell[,] cells = Host.UI.RawUI.NewBufferCellArray(allLines.ToArray(), f, b);
            Image img = new Image(cells, t);
            WriteObject(img, false);

        }

    }

    /// <summary>
    /// Draw an image onto the specified playfield at specific coord
    /// </summary>
    [Cmdlet("Draw", "Image")]
    public class DrawImageCmdlet : PSCmdlet
    {
        private Playfield pf;
        private Image img;
        private int x, y;

        [Parameter(Position=0,Mandatory=true)]
        [ValidateNotNullOrEmpty]
        public Playfield Playfield
        {
            set { pf = value; }
            get { return pf; }
        }
        [Parameter(Position = 1, Mandatory = true)]
        [ValidateNotNullOrEmpty]
        public Image Image
        {
            set { img = value; }
            get { return img; }
        }
        [Parameter(Position = 2, Mandatory = true)]
        public int X
        {
            set { x = value; }
            get { return x; }
        }
        [Parameter(Position = 3, Mandatory = true)]
        public int Y
        {
            set { y = value; }
            get { return y; }
        }


        protected override void EndProcessing()
        {
            base.EndProcessing();
            // primative operations on the playfield (like image drawing) is done
            // Playfield itself
            pf.DrawImage(img, x, y);
        }
    }


    [Cmdlet("Scan", "Image")]
    public class ScanImageCmdlet : PSCmdlet
    {
        private Playfield pf;
        private int x, y,w,h;
        private char t;

        [Parameter(Position = 0, Mandatory = true)]
        [ValidateNotNullOrEmpty]
        public Playfield Playfield
        {
            set { pf = value; }
            get { return pf; }
        }
        [Parameter(Position = 1, Mandatory = true)]
        public int X
        {
            set { x = value; }
            get { return x; }
        }
        [Parameter(Position = 2, Mandatory = true)]
        public int Y
        {
            set { y = value; }
            get { return y; }
        }
        [Parameter(Position = 3, Mandatory = true)]
        public int Width
        {
            set { w = value; }
            get { return w; }
        }
        [Parameter(Position = 4, Mandatory = true)]
        public int Height
        {
            set { h = value; }
            get { return h; }
        }
        [Parameter(Position = 5)]
        public char Transparent
        {
            set { t = value; }
            get { return t; }
        }
        protected override void EndProcessing()
        {
            WriteObject(pf.ScanImage(x, y, w, h, t));
        }
    }

    /// <summary>
    /// Get Image(s) from a data stream
    /// </summary>
    [Cmdlet("Get", "Image")]
    public class GetImageCmdlet : PSCmdlet
    {
        // TODO: complete this
    }


}
