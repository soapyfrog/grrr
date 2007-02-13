using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;

namespace Soapyfrog.Grrr.ImageCmdlets
{

    /// <summary>
    /// Draw an image onto the specified playfield at specific coord
    /// </summary>
    [Cmdlet("Draw", "Image")]
    public class DrawImageCmdlet : PSCmdlet
    {
        private Playfield pf;
        private Image img;
        private int x, y;

        [Parameter(Position = 0, Mandatory = true)]
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


}
