using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;

namespace Soapyfrog.Grrr.SpriteCmdlets
{
    /// <summary>
    /// Draw all passed sprites, calling their handlers if present.
    /// </summary>
    [Cmdlet("Draw", "Sprite")]
    public class DrawSpriteCmdlet : PSCmdlet
    {
        private Playfield pf;
        private Sprite[] sprites;
        private bool evenIfDead;

        [Parameter(Position = 0, Mandatory = true)]
        [ValidateNotNull]
        public Playfield Playfield { set { pf = value; }  get { return pf; } }

        [Parameter(Position = 1, Mandatory = true, ValueFromPipeline = true)]
        [ValidateNotNull]
        public Sprite[] Sprites { get { return sprites; } set { sprites = value; } }

        [Parameter(Position = 2)]
        public SwitchParameter EvenIfDead { get { return evenIfDead; } set { evenIfDead = value; } }

        protected override void ProcessRecord()
        {
            if (sprites != null)
            {
                foreach (Sprite s in sprites)
                {
                    if (evenIfDead || s.Alive)
                    {
                        s.StepMotionPath();
                        s.WillDraw();
                        pf.DrawImage(s.NextImage, s.X, s.Y);
                        s.DidDraw();
                    }
                }
            }
        }
    }



}
