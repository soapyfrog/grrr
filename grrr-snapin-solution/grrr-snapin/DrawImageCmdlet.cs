using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
{
    [Cmdlet("Draw", "Image")]
    public class DrawImageCmdlet : PSCmdlet
    {
        private string[] words;

        /// <summary>
        /// A series of words to be passed in on the commandline
        /// </summary>
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty]
        public string[] Words
        {
            get { return words; }
            set { words = value; }
        }


        protected override void ProcessRecord()
        {
            if (words == null)
            {
                WriteObject("Nothing to say!", false);
            }
            else
            {
                WriteObject(words, true);
            }
        }
    }
}