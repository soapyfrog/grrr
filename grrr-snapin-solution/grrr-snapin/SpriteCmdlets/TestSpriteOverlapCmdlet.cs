using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;
using System.Security;

namespace Soapyfrog.Grrr.SpriteCmdlets
{

    /// <summary>
    /// Determine if any sprites in set a overlap any sprites in set b.
    /// Calls their DidOverlap handlers if so.
    /// If OutputPairs switch is set, returns them also.
    /// By default, will not test inactive sprites, but this can be overriden
    /// with EvenIfInactive switch.
    /// 
    /// TODO: add option for cell-level overlap
    /// </summary>
    [Cmdlet("Test", "SpriteOverlap")]
    [SecurityCritical]
    public class TestSpriteOverlapCmdlet : PSCmdlet
    {
        private Sprite[] spritesA;

        [Parameter(Position = 0, Mandatory = true)]
        [ValidateNotNull]
        public Sprite[] SpritesA
        {
            get { return spritesA; }
            set { spritesA = value; }
        }

        private Sprite[] spritesB;

        [Parameter(Position = 1, Mandatory = true, ValueFromPipeline = true)]
        [ValidateNotNullOrEmpty]
        public Sprite[] SpritesB
        {
            get { return spritesB; }
            set { spritesB = value; }
        }

        private bool evenIfInactive = false;

        [Parameter(Position = 2)]
        public SwitchParameter EvenIfInactive
        {
            get { return evenIfInactive; }
            set { evenIfInactive = value; }
        }

        private bool outputPairs = false;

        /// <summary>
        /// If set, the colliding pairs will be output as Pair objects.
        /// </summary>
        [Parameter(Position = 3)]
        public SwitchParameter OutputPairs
        {
            get { return outputPairs; }
            set { outputPairs = value; }
        }



        protected override void ProcessRecord()
        {
            foreach (Sprite a in spritesA)
            {
                foreach (Sprite b in spritesB)
                {
                    if (a != b && a.Overlaps(b, evenIfInactive))
                    {
                        // notify both parties
                        a.DidOverlap(b);
                        b.DidOverlap(a);
                        // write out the b if required
                        if (outputPairs) WriteObject(new Pair<Sprite>(a,b), false);
                    }
                }
            }
        }
    }
}
