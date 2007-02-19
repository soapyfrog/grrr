using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;

namespace Soapyfrog.Grrr.SoundCmdlets
{
    /// <summary>
    /// Play a Sound created by Create-Sound cmdlet.
    /// </summary>
    [Cmdlet("Play", "Sound")]
    public class PlaySoundCmdlet : PSCmdlet
    {
        private Sound sound;
        private bool stopExisting;

        [Parameter(Position = 0, Mandatory = true)]
        [ValidateNotNull]
        public Sound Sound
        {
            get { return sound; }
            set { sound = value; }
        }

        [Parameter()]
        public SwitchParameter StopExisting
        {
            set { stopExisting = value; }
            get { return stopExisting; }
        }

        protected override void EndProcessing()
        {
            sound.Play(stopExisting); 
        }
    }
}
