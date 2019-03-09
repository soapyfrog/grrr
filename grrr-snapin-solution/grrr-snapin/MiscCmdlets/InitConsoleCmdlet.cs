using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using System.Security;

namespace Soapyfrog.Grrr.MiscCmdlets
{
    /// <summary>
    /// Initialise the console, ensuring it is big enough
    /// for requirements, etc.
    /// Will throw an exception if you try to exceed the physical bounds of the screen.
    /// </summary>
    [Cmdlet("Init","Console")]
    [SecurityCritical]
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
            Size max = ui.MaxPhysicalWindowSize;
            if (w > max.Width || h > max.Height)
            {
                throw new InvalidOperationException(
                    string.Format("Console can not be bigger than {0}x{1}. Consider using a smaller font size.", max.Width, max.Height));
            }
            // ensure that the host console is big enough for our needs
            int bw = ui.BufferSize.Width;
            int bh = ui.BufferSize.Height;
            bw = Math.Max(w, bw);
            bh = Math.Max(h, bh);
            ui.BufferSize = new Size(bw, bh);
            ui.WindowSize = new Size(w, h);

            // now erase using current background colour (not sure how to call clear-host)
            ui.SetBufferContents(new Rectangle(0, 0, bw - 1, bh - 1), 
                new BufferCell(' ', ui.ForegroundColor, ui.BackgroundColor, BufferCellType.Complete));
            ui.CursorPosition = new Coordinates(0, 0);
        }
    }
}
