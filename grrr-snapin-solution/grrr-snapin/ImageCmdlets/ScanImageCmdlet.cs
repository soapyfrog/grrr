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

    [Cmdlet("Scan", "Image")]
    public class ScanImageCmdlet : PSCmdlet
    {
        private Playfield pf;
        private int x, y, w, h;
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

}
