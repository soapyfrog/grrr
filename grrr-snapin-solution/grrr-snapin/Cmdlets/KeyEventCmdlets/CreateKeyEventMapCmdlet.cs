using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr.Cmdlets
{
    /// <summary>
    /// Create a key event map.
    /// </summary>
    [Cmdlet("Create","KeyEventMap")]
    public class CreateKeyEventMapCmdlet : PSCmdlet
    {
        protected override void EndProcessing()
        {
            WriteObject(new KeyEventMap(), false);
        }
    }
}
