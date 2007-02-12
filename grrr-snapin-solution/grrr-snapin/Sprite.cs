using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
{
    public class Sprite
    {
        private Image[] images;
        private int width, height;
        private int x, y, z;
        bool alive = true;
        int animrate = 1;

        public int Width { get { return width; } set { width = value; } }
        public int Height { get { return height; } set { height = value; } }
        public int X { get { return x; } set { x = value; } }
        public int Y { get { return y; } set { y = value; } }
        public int Z { get { return z; } set { z = value; } }
        public bool Alive { get { return alive; } set { alive = value; } }

        protected internal Sprite(Image[]i,int x,int y,int z,bool a,int ar)
        {
            images = i;
            this.x = x;
            this.y = y;
            this.z = z;
            alive = a;
            animrate = ar;
        }
    }

    [Cmdlet("Create", "Sprite")]
    public class CreateSpriteCmdlet : PSCmdlet
    {
        protected override void EndProcessing()
        {
         //   Sprite s = new Sprite(
        }
    }


    [Cmdlet("Draw", "Sprite")]
    public class DrawSpriteCmdlet : PSCmdlet
    {
    }


    // TODO can add handlers, hit testing and so on in here too.

}
