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
        private ScriptBlock di;
        private ScriptBlock wd;
        private ScriptBlock dd;

        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty]
        public ScriptBlock DidInit
        {
            get { return di; }
            set { di = value; }
        }

        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty]
        public ScriptBlock WillDraw
        {
            get { return wd; }
            set { wd = value; }
        }

        [Parameter(Position = 2)]
        [ValidateNotNullOrEmpty]
        public ScriptBlock DidDraw
        {
            get { return dd; }
            set { dd = value; }
        }

        protected override void EndProcessing()
        {
            SpriteHandler sh = new SpriteHandler(di, wd, dd);
            WriteObject(sh, false);
        }

    }
}
