using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
{

    [Cmdlet("Flush", "Playfield")]
    public class FlushPlayfieldCmdlet : PSCmdlet
    {
        private Playfield pf;

        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty]
        public Playfield Playfield { set { pf = value; } }

        protected override void EndProcessing()
        {
            pf.Flush();
            base.EndProcessing();
        }

    }

}
