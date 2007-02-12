using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
{

    [Cmdlet("Draw", "String")]
    public class DrawStringCmdlet : PSCmdlet
    {
        private Playfield pf;
        private string text;
        private int x, y;
        private ConsoleColor fg = ConsoleColor.White;
        private ConsoleColor bg = ConsoleColor.Black;


        [Parameter(Position = 0, Mandatory = true)]
        [ValidateNotNullOrEmpty]
        public Playfield Playfield
        {
            set { pf = value; }
            get { return pf; }
        }

        [Parameter(Position = 1, Mandatory = true)]
        public string String
        {
            set { text = value; }
            get { return text; }
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

        [Parameter(Position = 4)]
        [Alias("fg")]
        public ConsoleColor Foreground { set { fg = value; } }

        [Parameter(Position = 5)]
        [Alias("bg")]
        public ConsoleColor Background { set { bg = value; } }


        protected override void EndProcessing()
        {
            BufferCell[,] cells = Host.UI.RawUI.NewBufferCellArray(new string[]{text}, fg, bg);
            Image im = new Image(cells, '\0');
            pf.DrawImage(im, x, y);
        }
    }


}
