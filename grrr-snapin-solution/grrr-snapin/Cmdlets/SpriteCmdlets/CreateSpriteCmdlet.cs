using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
{

    [Cmdlet("Create", "Sprite")]
    public class CreateSpriteCmdlet : PSCmdlet
    {
        private Image[] images;
        private int x, y, z;
        bool alive = true;
        int animrate = 1;
        private SpriteHandler sh;



        [Parameter(Position=0,Mandatory=true,ValueFromPipeline=true)]
        public Image[] Images { get { return images; } set { images = value; } }

        [Parameter(Position=1)]
        public int X { get { return x; } set { x = value; } }

        [Parameter(Position = 2)]
        public int Y { get { return y; } set { y = value; } }

        [Parameter(Position = 3)]
        public int Z { get { return z; } set { z = value; } }

        [Parameter(Position = 4)]
        public bool Alive { get { return alive; } set { alive = value; } }

        [Parameter(Position = 5)]
        public int AnimRate { get { return animrate; } set { animrate = value; } }

        [Parameter(Position=6)]
        [ValidateNotNull]
        public SpriteHandler Handler
        {
            get { return sh; }
            set { sh = value; }
        }

        protected override void EndProcessing()
        {
            Sprite s = new Sprite(images, x, y, z, alive, animrate,sh);
            SpriteHandler h = s.Handler;
            if (h != null && h.DidInit != null) sh.DidInit.Invoke(s);
            WriteObject(s, false);
        }
    }


}
