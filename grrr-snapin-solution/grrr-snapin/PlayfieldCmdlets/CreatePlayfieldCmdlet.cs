using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;

namespace Soapyfrog.Grrr.PlayfieldCmdlets
{

    [Cmdlet("Create", "Playfield")]
    public class CreatePlayfieldCmdlet : PSCmdlet
    {
        private int x, y, w, h;
        private ConsoleColor c;

        [Parameter(Position = 0,HelpMessage="Hello!")]
        [ValidateRange(1, 1000)]
        public int Width { set { w = value; } }
        [Parameter(Position = 1)]
        [ValidateRange(1, 1000)]
        public int Height { set { h = value; } }
        [Parameter(Position = 2)]
        [ValidateRange(0, 1000)]
        public int X { set { x = value; } }
        [Parameter(Position = 3)]
        [ValidateRange(0, 1000)]
        public int Y { set { y = value; } }
        [Parameter(Position = 4)]
        [Alias("bg")]
        public ConsoleColor Background { set { c = value; } }

        /// <summary>
        /// Put out the created Playfield
        /// </summary>
        protected override void EndProcessing()
        {
            Playfield pf = new Playfield(Host.UI.RawUI, w, h, x, y, c);
            WriteObject(pf, false);
            base.EndProcessing();
        }

    }

}
