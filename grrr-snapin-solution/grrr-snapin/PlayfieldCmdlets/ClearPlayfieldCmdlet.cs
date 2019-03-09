using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;
using System.Security;

namespace Soapyfrog.Grrr.PlayfieldCmdlets
{

    [Cmdlet("Clear", "Playfield")]
    [SecurityCritical]
    public class ClearPlayfieldCmdlet : PSCmdlet
    {
        private Playfield pf;

        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty]
        public Playfield Playfield { set { pf = value; } }

        protected override void EndProcessing()
        {
            pf.Clear();
            base.EndProcessing();
        }
    }
}
