using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using Soapyfrog.Grrr.Core;

namespace Soapyfrog.Grrr.MiscCmdlets
{
    [Cmdlet("Out","Banner")]
    public class OutBannerCmdlet : Cmdlet
    {
        private string[] text;
        private char fgc = (char)0x2588; // solid block
        private char bgc = ' ';
        private int lineswritten = 0;
        

        [Parameter(Position = 0, ValueFromPipeline = true, Mandatory = true)]
        [ValidateNotNull]
        public string[] Text { get { return text; } set { text = value; } }


        [Parameter(Position=1)]
        [Alias("fg","fgc")]
        public char ForegroundChar
        {
            get { return fgc; }
            set { fgc = value; }
        }

        [Parameter(Position = 2)]
        [Alias("bg", "bgc")]
        public char BackgroundChar
        {
            get { return bgc; }
            set { bgc = value; }
        }

        protected override void ProcessRecord()
        {
            foreach (string s in text)
            {
                if (lineswritten++ > 0) WriteObject("");
                WriteObject(Banner.Render(s,fgc,bgc));
            }
        }


    }
}
