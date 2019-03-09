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
    /// This cmdlet creates a SpriteHandler instances holding zero or more scriptblock
    /// handlers that are used to control the behavious of a sprite.
    /// </summary>
    [Cmdlet("Create", "SpriteHandler")]
    [SecurityCritical]
    public class CreateSpriteHandlerCmdlet : PSCmdlet
    {
        private ScriptBlock didInit;
        private ScriptBlock willDraw;
        private ScriptBlock didDraw;
        private ScriptBlock willMove;
        private ScriptBlock didMove;
        private ScriptBlock didOverlap;
        private ScriptBlock didExceedBounds;
        private ScriptBlock didEndAnim;
        private ScriptBlock didEndMotion;

        [Parameter()]
        public ScriptBlock DidInit
        {
            get { return didInit; }
            set { didInit = value; }
        }

        [Parameter()]
        public ScriptBlock WillMove
        {
            get { return willMove; }
            set { willMove = value; }
        }

        [Parameter()]
        public ScriptBlock DidMove
        {
            get { return didMove; }
            set { didMove = value; }
        }


        [Parameter()]
        public ScriptBlock WillDraw
        {
            get { return willDraw; }
            set { willDraw = value; }
        }

        [Parameter()]
        public ScriptBlock DidDraw
        {
            get { return didDraw; }
            set { didDraw = value; }
        }
        [Parameter()]
        public ScriptBlock DidOverlap
        {
            get { return didOverlap; }
            set { didOverlap = value; }
        }
        [Parameter()]
        public ScriptBlock DidExceedBounds
        {
            get { return didExceedBounds; }
            set { didExceedBounds = value; }
        }

        [Parameter()]
        public ScriptBlock DidEndAnim
        {
            get { return didEndAnim; }
            set { didEndAnim = value; }
        }

        [Parameter()]
        public ScriptBlock DidEndMotion
        {
            get { return didEndMotion; }
            set { didEndMotion = value; }
        }

        protected override void EndProcessing()
        {
            SpriteHandler sh = new SpriteHandler(didInit, willMove,didMove, willDraw, didDraw,didOverlap,
                didExceedBounds,didEndAnim,didEndMotion);
            WriteObject(sh, false);
        }

    }
}
