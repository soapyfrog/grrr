using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
{
    public class SpriteHandler
    {

        private ScriptBlock didinit;

        public ScriptBlock DidInit
        {
            get { return didinit; }
        }

        private ScriptBlock willdraw;
        public ScriptBlock WillDraw
        {
            get { return willdraw; }
        }

        private ScriptBlock diddraw;
        public ScriptBlock DidDraw
        {
            get { return diddraw; }
        }


        protected internal SpriteHandler(ScriptBlock didinit, ScriptBlock willdraw, ScriptBlock diddraw)
        {
            this.diddraw = diddraw;
            this.willdraw = willdraw;
            this.didinit = didinit;
        }
        
    }
}
