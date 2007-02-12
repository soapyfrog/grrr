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
        private bool alive = true;
        private int animrate = 1;
        private SpriteHandler handler;

        public int Width { get { return width; } set { width = value; } }
        public int Height { get { return height; } set { height = value; } }
        public int X { get { return x; } set { x = value; } }
        public int Y { get { return y; } set { y = value; } }
        public int Z { get { return z; } set { z = value; } }
        public bool Alive { get { return alive; } set { alive = value; } }
        public int AnimRate { get { return animrate; } set { animrate = value; } }
        public Image[] Images { get { return images; } }

        private int numframes;
        private int fseq = 0; // frame sequence
        private int animcounter = 0; // when reaches animrate, fseq++



        public SpriteHandler SpriteHandler
        {
            get { return handler; }
            set { handler = value; }
        }

        /// <summary>
        /// Return the next image in the anim sequence for drawing.
        /// </summary>
        public Image NextImage
        {
            get
            {
                int f = fseq;
                if (++animcounter == animrate)
                {
                    animcounter = 0;
                    fseq = (fseq + 1) % numframes;
                }
                return images[f];
            }
        }

        protected internal Sprite(Image[] images, int x, int y, int z, bool alive, int animrate,SpriteHandler sh)
        {
            this.images = images;
            this.x = x;
            this.y = y;
            this.z = z;
            this.alive = alive;
            this.animrate = animrate;
            this.handler = sh;
            numframes = images.Length;
        }
    }
}
