using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr.Core
{
    /// <summary>
    /// A holder for scriptblock behaviour handlers.
    /// </summary>
    public class SpriteHandler
    {
        private ScriptBlock didInit;
        public ScriptBlock DidInit
        {
            get { return didInit; }
            set { didInit = value; }
        }

        private ScriptBlock willDraw;
        public ScriptBlock WillDraw
        {
            get { return willDraw; }
            set { willDraw = value; }
        }

        private ScriptBlock didDraw;
        public ScriptBlock DidDraw
        {
            get { return didDraw; }
            set { didDraw = value; }
        }

        private ScriptBlock willMove;
        public ScriptBlock WillMove
        {
            get { return willMove; }
            set { willMove = value; }
        }

        private ScriptBlock didMove;
        public ScriptBlock DidMove
        {
            get { return didMove; }
            set { didMove = value; }
        }

        private ScriptBlock didOverlap;
        public ScriptBlock DidOverlap
        {
            get { return didOverlap; }
            set { didOverlap = value; }
        }

        private ScriptBlock didExceedBounds;
        public ScriptBlock DidExceedBounds
        {
            get { return didExceedBounds; }
            set { didExceedBounds = value; }
        }

        private ScriptBlock didEndAnim;
        public ScriptBlock DidEndAnim
        {
            get { return didEndAnim; }
            set { didEndAnim = value; }
        }

        private ScriptBlock didEndMotion;
        public ScriptBlock DidEndMotion
        {
            get { return didEndMotion; }
            set { didEndMotion = value; }
        }

        protected internal SpriteHandler(
            ScriptBlock didInit,
            ScriptBlock willMove,
            ScriptBlock didMove,
            ScriptBlock willDraw,
            ScriptBlock didDraw,
            ScriptBlock didOverlap,
            ScriptBlock didExceedBounds,
            ScriptBlock didEndAnim,
            ScriptBlock didEndMotion)
        {
            this.didMove = didMove;
            this.willMove = willMove;
            this.didDraw = didDraw;
            this.willDraw = willDraw;
            this.didInit = didInit;
            this.didOverlap = didOverlap;
            this.didExceedBounds = didExceedBounds;
            this.didEndAnim = didEndAnim;
            this.didEndMotion = didEndMotion;
        }

    }
}
