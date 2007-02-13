using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;

namespace Soapyfrog.Grrr.SpriteCmdlets
{
    /// <summary>
    /// Create a MotionPath controller taking a string like:
    /// "10e h3 5w2" which will move 10 times to the east,
    /// then hold for 3 frames, then move west 2 steps, 5 times
    /// (bring it back to the beginning twice as fast).
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
            foreach (string s in mp.Errors) { WriteWarning(s); }
            WriteObject(mp, false);
        }

    }
}
