using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;

namespace Soapyfrog.Grrr.SpriteCmdlets
{
    /// <summary>
    /// Step the animation frame. Useful if you draw-sprite with the -noanim flag
    /// </summary>
    [Cmdlet("Animate", "Sprite")]
    public class AnimateSpriteCmdlet : PSCmdlet
    {
        private Sprite[] sprites;
        private bool evenIfDead;

        [Parameter(Position = 0, Mandatory = true, ValueFromPipeline = true)]
        [ValidateNotNull]
        public Sprite[] Sprites { get { return sprites; } set { sprites = value; } }

        [Parameter()]
        public SwitchParameter EvenIfDead { get { return evenIfDead; } set { evenIfDead = value; } }

        protected override void ProcessRecord()
        {
            if (sprites != null)
            {
                foreach (Sprite s in sprites)
                {
                    if (evenIfDead || s.Alive)
                    {
                        s.StepAnim();
                    }
                }
            }
        }
    }



}
