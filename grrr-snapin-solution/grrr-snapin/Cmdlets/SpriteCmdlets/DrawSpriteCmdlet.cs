using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
{
    /// <summary>
    /// Draw all passed sprites, calling their handlers if present.
    /// </summary>
    [Cmdlet("Draw", "Sprite")]
    public class DrawSpriteCmdlet : PSCmdlet
    {
        private Playfield pf;
        private Sprite[] sprites;

        [Parameter(Position = 0, Mandatory = true)]
        [ValidateNotNull]
        public Playfield Playfield { set { pf = value; }  get { return pf; } }

        [Parameter(Position = 1, Mandatory = true, ValueFromPipeline = true)]
        [ValidateNotNull]
        public Sprite[] Sprites { get { return sprites; } set { sprites = value; } }

        protected override void ProcessRecord()
        {
            if (sprites != null)
            {
                foreach (Sprite s in sprites)
                {
                    SpriteHandler sh = s.Handler;
                    if (sh != null && sh.WillDraw != null) sh.WillDraw.Invoke(s);
                    pf.DrawImage(s.NextImage, s.X, s.Y);
                    if (sh != null && sh.DidDraw != null) sh.DidDraw.Invoke(s);
                }
            }
        }
    }



}
