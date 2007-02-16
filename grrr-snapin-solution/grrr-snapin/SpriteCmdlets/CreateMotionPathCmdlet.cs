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
        private int rep;

        /// <summary>
        /// Motion path spec, see MotionPath for details.
        /// </summary>
        [Parameter(Position=0,Mandatory=true)]
        [ValidateNotNullOrEmpty]
        public string MotionPathSpec
        {
            get { return mps; }
            set { mps = value; }
        }

        /// <summary>
        /// Optional repeat count. If unspecified or set to 0,
        /// the motionpath will repeat endlessly.
        /// </summary>
        [Parameter()]
        [ValidateRange(0,int.MaxValue)]
        public int RepeatCount
        {
            get { return rep; }
            set { rep = value; }
        }


        protected override void EndProcessing()
        {
            MotionPath mp = new MotionPath(mps,rep);
            foreach (string s in mp.Errors) { WriteWarning(s); }
            WriteObject(mp, false);
        }

    }
}
