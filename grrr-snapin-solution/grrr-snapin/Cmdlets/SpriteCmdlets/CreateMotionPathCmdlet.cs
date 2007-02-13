using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
{
    /// <summary>
    /// Create a MotionPath controller taking a string like:
    /// "e4 s4 w4 n4" which will move in a square
    /// </summary>
    [Cmdlet("Create", "MotionPath")]
    public class CreateMotionPathCmdlet : PSCmdlet
    {
        private string mps;

        [Parameter(Position=0,Mandatory=true)]
        [ValidateNotNullOrEmpty]
        public string MotionPathSpec
        {
            get { return mps; }
            set { mps = value; }
        }

        protected override void EndProcessing()
        {
            MotionPath mp = new MotionPath(mps);
            WriteObject(mp, false);
        }

    }
}
