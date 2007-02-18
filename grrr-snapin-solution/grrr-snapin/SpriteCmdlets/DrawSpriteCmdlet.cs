using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;

namespace Soapyfrog.Grrr.SpriteCmdlets
{
    /// <summary>
    /// Draw all passed sprites, calling their handlers if present, optionally drawing
    /// dead sprites too.
    /// </summary>
    [Cmdlet("Draw", "Sprite")]
    public class DrawSpriteCmdlet : PSCmdlet
    {
        private Playfield pf;
        private Sprite[] sprites;
        private bool evenIfDead;
        private bool noAnim;

        [Parameter(Position = 0, Mandatory = true)]
        [ValidateNotNull]
        public Playfield Playfield { set { pf = value; }  get { return pf; } }

        [Parameter(Position=1,Mandatory = true, ValueFromPipeline = true)]
        [ValidateNotNull]
        public Sprite[] Sprites { get { return sprites; } set { sprites = value; } }

        [Parameter()]
        public SwitchParameter EvenIfDead { get { return evenIfDead; } set { evenIfDead = value; } }

        /// <summary>
        /// If set, do not step to the next animation frame.
        /// </summary>
        [Parameter()]
        public SwitchParameter NoAnim { get { return noAnim; } set { noAnim = value; } }

        protected override void ProcessRecord()
        {
            if (sprites != null)
            {
                foreach (Sprite s in sprites)
                {
                    if (evenIfDead || s.Alive)
                    {
                        s.PreDraw();
                        pf.DrawImage(s.CurrImage, s.X, s.Y);
                        s.PostDraw();
                        if (!noAnim) s.StepAnim();
                    }
                }
            }
        }
    }



}
