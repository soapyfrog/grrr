using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
{

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


}