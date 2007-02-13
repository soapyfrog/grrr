using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;

namespace Soapyfrog.Grrr.KeyEventCmdlets
{
    /// <summary>
    /// Create a key event map.
    /// </summary>
    [Cmdlet("Process","KeyEvents")]
    public class ProcessKeyEventsCmdlet : PSCmdlet
    {
        private KeyEventMap keyeventmap;

        [Parameter(Position=0,Mandatory=true)]
        [ValidateNotNull]
        public KeyEventMap KeyEventMap
        {
            get { return keyeventmap; }
            set { keyeventmap = value; }
        }

        protected override void EndProcessing()
        {
            keyeventmap.ProcessKeyEvents(Host.UI.RawUI);
        }
    }
}
