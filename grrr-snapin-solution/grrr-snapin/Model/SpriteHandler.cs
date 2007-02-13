using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
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


        protected internal SpriteHandler(ScriptBlock didInit,
                                            ScriptBlock willDraw,
                                            ScriptBlock didDraw)
        {
            this.didDraw = didDraw;
            this.willDraw = willDraw;
            this.didInit = didInit;
        }

    }
}
