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
    /// Stop a Sound created by Create-Sound cmdlet.
    /// </summary>
    [Cmdlet("Stop", "Sound")]
    [SecurityCritical]
    public class StopSoundCmdlet : PSCmdlet
    {
        [Parameter(Position = 0, Mandatory = true)]
        [ValidateNotNull]
        public Sound Sound { get; set; }

        protected override void EndProcessing()
        {
            Sound.Stop(); 
        }
    }
}
