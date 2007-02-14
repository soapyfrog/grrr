using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;

namespace Soapyfrog.Grrr.SpriteCmdlets
{

    [Cmdlet("Create", "SpriteHandler")]
    public class CreateSpriteHandlerCmdlet : PSCmdlet
    {
        private ScriptBlock didInit;
        private ScriptBlock willDraw;
        private ScriptBlock didDraw;
        private ScriptBlock didOverlap;
        private ScriptBlock didExceedBounds;

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
        [Parameter(Position = 3)]
        [ValidateNotNullOrEmpty]
        public ScriptBlock DidOverlap
        {
            get { return didOverlap; }
            set { didOverlap = value; }
        }
        [Parameter(Position = 4)]
        [ValidateNotNullOrEmpty]
        public ScriptBlock DidExceedBounds
        {
            get { return didExceedBounds; }
            set { didExceedBounds = value; }
        }

        protected override void EndProcessing()
        {
            SpriteHandler sh = new SpriteHandler(didInit, willDraw, didDraw,didOverlap,didExceedBounds);
            WriteObject(sh, false);
        }

    }
}
