using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;
using System.Security;

namespace Soapyfrog.Grrr.PlayfieldCmdlets
{

    [Cmdlet("Flush", "Playfield")]
//    [SecurityCritical]
    public class FlushPlayfieldCmdlet : PSCmdlet
    {
        private Playfield pf;

        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty]
        public Playfield Playfield { set { pf = value; } }


        private int sync;

        [Parameter(Position=1)]
        [ValidateRange(0,3600)]
        public int Sync
        {
            get { return sync; }
            set { sync = value; }
        }


        protected override void EndProcessing()
        {
            pf.Flush(sync);
            base.EndProcessing();
        }

    }

}
