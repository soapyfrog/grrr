using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
{

    [Cmdlet("Draw", "Line")]
    public class DrawLineCmdlet : PSCmdlet
    {

    }


    [Cmdlet("Draw", "Point")]
    public class DrawPointCmdlet : PSCmdlet
    {
    }

    [Cmdlet("Draw", "Rectangle")]
    public class DrawRectangleCmdlet : PSCmdlet
    {
    }

    // TODO circles?

}
