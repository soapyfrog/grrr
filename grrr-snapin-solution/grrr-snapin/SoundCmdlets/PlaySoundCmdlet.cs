using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;
using System.Security;

namespace Soapyfrog.Grrr.SoundCmdlets
{
    /// <summary>
    /// Play a Sound created by Create-Sound cmdlet.
    /// </summary>
    [Cmdlet("Play", "Sound")]
    [SecurityCritical]
    public class PlaySoundCmdlet : PSCmdlet
    {
        private Sound sound;
        private bool stopExisting;
        private bool loop;

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

        [Parameter()]
        public SwitchParameter Loop
        {
            set { loop = value; }
            get { return loop; }
        }

        protected override void EndProcessing()
        {
            sound.Play(stopExisting,loop); 
        }
    }
}
