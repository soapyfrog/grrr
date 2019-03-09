using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;
using System.Security;

namespace Soapyfrog.Grrr.TilemapCmdlets
{
    /// <summary>
    /// Get a Tilemap from an input stream (eg a file).
    /// </summary>
    [Cmdlet("Get", "Tilemap")]
    [SecurityCritical]
    public class GetTilemapCmdlet : PSCmdlet
    {
        // TODO: lots of work to be done here
    }


}
