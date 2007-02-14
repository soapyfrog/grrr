using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;

namespace Soapyfrog.Grrr.SpriteCmdlets
{

    /// <summary>
    /// Determine if a sprite is overlapping any 
    /// other sprites. Returns a collection of sprites
    /// that do hit.
    /// TODO: add option for cell-level overlap
    /// </summary>
    [Cmdlet("Test", "SpriteOverlap")]
    public class TestSpriteOverlapCmdlet : PSCmdlet
    {
        private Sprite sprite;

        [Parameter(Position=0,Mandatory=true)]
        [ValidateNotNull]
        public Sprite Sprite
        {
            get { return sprite; }
            set { sprite = value; }
        }

        private Sprite[] otherSprites;

        [Parameter(Position=1,Mandatory=true,ValueFromPipeline=true)]
        [ValidateNotNullOrEmpty]
        public Sprite[] OtherSprites
        {
            get { return otherSprites; }
            set { otherSprites = value; }
        }

        private bool evenIfDead = false;

        [Parameter(Position = 2)]
        public bool EvenIfDead
        {
            get { return evenIfDead; }
            set { evenIfDead = value; }
        }

        private bool noOutput = false;

        [Parameter(Position = 3,HelpMessage="if false, will return overlapping sprites"]
        [SwitchParameter]
        public bool NoOutput
        {
            get { return noOutput; }
            set { noOutput = value; }
        }



        protected override void ProcessRecord()
        {
            foreach (Sprite other in otherSprites)
            {
                if (sprite.Overlaps(other,evenIfDead))
                {
                    // notify both parties
                    sprite.DidOverlap(other);
                    other.DidOverlap(sprite);
                    // write out the other if required
                    if (!noOutput) WriteObject(other, false);
                }
            }
        }

    }


}
