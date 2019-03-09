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
    /// Draw all passed sprites, calling their handlers if present, optionally drawing
    /// inactive sprites too.
    /// </summary>
    [Cmdlet("Move", "Sprite")]
    [SecurityCritical]
    public class MoveSpriteCmdlet : PSCmdlet
    {
        private Sprite[] sprites;
        private bool evenIfInactive;

        [Parameter(Position = 0, Mandatory = true, ValueFromPipeline = true)]
        [ValidateNotNull]
        public Sprite[] Sprites { get { return sprites; } set { sprites = value; } }

        [Parameter(Position = 1)]
        public SwitchParameter EvenIfInactive { get { return evenIfInactive; } set { evenIfInactive = value; } }

        protected override void ProcessRecord()
        {
            if (sprites != null)
            {
                foreach (Sprite s in sprites)
                {
                    if (evenIfInactive || s.Active)
                    {
                        s.StepMotion();
                    }
                }
            }
        }
    }



}
