using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
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


        protected override void ProcessRecord()
        {
            foreach (Sprite other in otherSprites)
            {
                if (sprite.Overlaps(other,evenIfDead))
                {
                    WriteObject(other, false);
                }
            }
        }

    }


}
