using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;

namespace Soapyfrog.Grrr.SoundCmdlets
{
    /// <summary>
    /// Create a Sound - something that can be played/stopped/etc.
    /// Returns one for each filename supplied.
    /// </summary>
    [Cmdlet("Create", "Sound")]
    public class CreateSoundCmdlet : PSCmdlet
    {
        private string[] soundfiles;

        /// <summary>
        /// Supply filenames on the cmdline
        /// </summary>
        [Parameter(Position=0,ValueFromPipeline=true,Mandatory=true)]
        [ValidateNotNullOrEmpty]
        public string[] SoundFiles
        {
            get { return soundfiles; }
            set { soundfiles = value; }
        }

        protected override void  ProcessRecord()
        {
            foreach (string soundfile in soundfiles)
            {
                WriteObject(new Sound(soundfile), false);
            }
        }
    }
}
