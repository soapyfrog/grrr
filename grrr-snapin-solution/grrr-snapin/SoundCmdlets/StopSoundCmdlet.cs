using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;

namespace Soapyfrog.Grrr.SoundCmdlets
{
    /// <summary>
    /// Stop a Sound created by Create-Sound cmdlet.
    /// </summary>
    [Cmdlet("Stop", "Sound")]
    public class StopSoundCmdlet : PSCmdlet
    {
        private Sound sound;

        [Parameter(Position = 0, Mandatory = true)]
        [ValidateNotNull]
        public Sound Sound
        {
            get { return sound; }
            set { sound = value; }
        }

        protected override void EndProcessing()
        {
            sound.Stop(); 
        }
    }
}
