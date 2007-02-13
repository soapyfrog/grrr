using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr.MiscCmdlets
{
    /// <summary>
    /// Initialise the console, ensuring it is big enough
    /// for requirements, etc.
    /// </summary>
    [Cmdlet("Init","Console")]
    public class InitConsoleCmdlet : PSCmdlet
    {
        private int w=120, h=50;

        [Parameter(Position = 0)]
        [ValidateRange(1, 32767)]
        public int Width { get { return w; } set { w = value; } }

        [Parameter(Position = 1)]
        [ValidateRange(1, 32767)]
        public int Height { get { return h; } set { h = value; } }

        protected override void EndProcessing()
        {
            PSHostRawUserInterface ui = Host.UI.RawUI;
            // ensure that the host console is big enough for our needs
            int bw = ui.BufferSize.Width;
            int bh = ui.BufferSize.Height;
            bw = Math.Max(w, bw);
            bh = Math.Max(h, bh);
            ui.BufferSize = new Size(bw, bh);
            ui.WindowSize = new Size(w, h);
        }
    }
}
