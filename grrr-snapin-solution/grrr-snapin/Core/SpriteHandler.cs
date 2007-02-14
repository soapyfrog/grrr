using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr.Core
{
    public class SpriteHandler
    {

        private ScriptBlock didInit;

        public ScriptBlock DidInit
        {
            get { return didInit; }
        }

        private ScriptBlock willDraw;
        public ScriptBlock WillDraw
        {
            get { return willDraw; }
        }

        private ScriptBlock didDraw;
        public ScriptBlock DidDraw
        {
            get { return didDraw; }
        }

        private ScriptBlock didOverlap;
        public ScriptBlock DidOverlap
        {
            get { return didOverlap; }
        }

        private ScriptBlock didExceedBounds;
        public ScriptBlock DidExceedBounds
        {
            get { return didExceedBounds; }
        }

        protected internal SpriteHandler(
            ScriptBlock didInit,
            ScriptBlock willDraw,
            ScriptBlock didDraw,
            ScriptBlock didOverlap,
            ScriptBlock didExceedBounds)
        {
            this.didDraw = didDraw;
            this.willDraw = willDraw;
            this.didInit = didInit;
            this.didOverlap = didOverlap;
            this.didExceedBounds = didExceedBounds;
        }

    }
}
