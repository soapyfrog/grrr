using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;

namespace Soapyfrog.Grrr.DrawingCmdlets
{
    using Core;

    /// <summary>
    /// Draw a line in the playfield using an image as the rendering tool.
    /// </summary>
    [Cmdlet("Draw", "Line")]
    public class DrawLineCmdlet : PSCmdlet
    {
        private Playfield pf;
        private Image img;
        private int x1, y1, x2, y2;

        /// <summary>
        /// The playfield to draw into.
        /// </summary>
        [Parameter(Position = 0, Mandatory = true)]
        [ValidateNotNullOrEmpty]
        public Playfield Playfield
        {
            set { pf = value; }
            get { return pf; }
        }
        /// <summary>
        /// The start x position
        /// </summary>
        [Parameter(Position = 1, Mandatory = true)]
        public int X1
        {
            set { x1 = value; }
            get { return x1; }
        }
        /// <summary>
        /// The start y position
        /// </summary>
        [Parameter(Position = 2, Mandatory = true)]
        public int Y1
        {
            set { y1 = value; }
            get { return y1; }
        }
        /// <summary>
        /// The end x position
        /// </summary>
        [Parameter(Position = 3, Mandatory = true)]
        public int X2
        {
            set { x2 = value; }
            get { return x2; }
        }
        /// <summary>
        /// The end y position
        /// </summary>
        [Parameter(Position = 4, Mandatory = true)]
        public int Y2
        {
            set { y2 = value; }
            get { return y2; }
        }
        /// <summary>
        /// The image to use for drawing.
        /// </summary>
        [Parameter(Position = 5, Mandatory = true)]
        [ValidateNotNullOrEmpty]
        public Image Image
        {
            set { img = value; }
            get { return img; }
        }

        /// <summary>
        /// Do the drawing.
        /// TODO: probably should be delegated to another class.
        /// </summary>
        protected override void EndProcessing()
        {
            // TODO: i think this could benefit from the
            // integer rasterising algorith.
            // can also use for rectangles/curves, etc
            // .. also for producing steps for a motionpath
            int dx = x2 - x1;
            int dy = y2 - y1;

            int adx = Math.Abs(dx);
            int ady = Math.Abs(dy);

            if (adx > ady)
            {
                int len = adx;
                int ix = dx / adx;
                double iy;
                if (adx == 0) iy = 0; else iy = (double)dy / adx;
                double y = y1;
                double x = x1;
                for (int i = 0; i <= len; i++)
                {
                    pf.DrawImage(img, (int)Math.Round(x), (int)Math.Round(y));
                    y += iy;
                    x += ix;
                }
            }
            else
            {
                int len = ady;
                int iy = dy / ady;
                double ix;
                if (ady == 0) ix = 0; else ix = (double)dx / ady;
                double x = x1;
                double y = y1;
                for (int i = 0; i <= len; i++)
                {
                    pf.DrawImage(img, (int)Math.Round(x), (int)Math.Round(y));
                    x += ix;
                    y += iy;
                }
            }

        }

    }


}
