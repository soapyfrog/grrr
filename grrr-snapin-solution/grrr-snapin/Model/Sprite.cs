using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
{
    /// <summary>
    /// Definition of a Sprite, which is basically a list if Images (for
    /// animation frames) and a position and state.
    /// 
    /// Sprites also have behaviour handlers for dealing with movement,
    /// collisions, etc.
    /// </summary>
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
        public int AnimRate { get { return animrate; } set { animrate = value; } }
        public Image[] Images { get { return images; } }

        protected internal Sprite(Image[]images,int x,int y,int z,bool alive,int animrate)
        {
            this.images = images;
            this.x = x;
            this.y = y;
            this.z = z;
            this.alive = alive;
            this.animrate = animrate;
        }
    }
}
