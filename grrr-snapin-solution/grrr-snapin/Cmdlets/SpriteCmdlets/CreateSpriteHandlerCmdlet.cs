using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
{

    [Cmdlet("Create", "SpriteHandler")]
    public class CreateSpriteHandlerCmdlet : PSCmdlet
    {
        private ScriptBlock didInit;
        private ScriptBlock willDraw;
        private ScriptBlock didDraw;
        private ScriptBlock didOverlap;
        private ScriptBlock didHitBoundary;

        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty]
        public ScriptBlock DidInit
        {
            get { return didInit; }
            set { didInit = value; }
        }

        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty]
        public ScriptBlock WillDraw
        {
            get { return willDraw; }
            set { willDraw = value; }
        }

        [Parameter(Position = 2)]
        [ValidateNotNullOrEmpty]
        public ScriptBlock DidDraw
        {
            get { return didDraw; }
            set { didDraw = value; }
        }

        protected override void EndProcessing()
        {
            SpriteHandler sh = new SpriteHandler(didInit, willDraw, didDraw);
            WriteObject(sh, false);
        }

    }
}
