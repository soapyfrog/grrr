using System;
using System.Collections;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr.Core
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
        private SpriteHandler handler;
        private MotionPath motionpath;
        private Hashtable state=new Hashtable();

        /// <summary>
        /// User settable state properties. Saves mucking about with
        /// adding note-properties.
        /// </summary>
        public Hashtable State
        {
            get { return state; }
            set { state = value; }
        }


        public int Width { get { return width; } set { width = value; } }
        public int Height { get { return height; } set { height = value; } }
        public int X { get { return x; } set { x = value; } }
        public int Y { get { return y; } set { y = value; } }
        public int Z { get { return z; } set { z = value; } }
        public bool Alive { get { return alive; } set { alive = value; } }
        public int AnimRate { get { return animSpeed; } set { animSpeed = value; } }
        public Image[] Images { get { return images; } }


        // stuff for animation
        private int animSpeed = 1;          // 1 means update every frame
        private int numAnimFrames;          
        private int nextAnimFrame = 0;      // frame sequence
        private int animSpeedCounter = 0;   // when reaches animSpeed, nextAnimFrame++

        // stuff for motion path
        private int nextMPDeltaIndex = 0;           // the index of the next delta to use
        private int nextMPDeltaRepeatCount = 0;     // the repeat count for the specific delta

        public SpriteHandler Handler
        {
            get { return handler; }
            set { handler = value; }
        }

        public MotionPath MotionPath
        {
            get { return motionpath; }
            set
            {
                motionpath = value;
                nextMPDeltaIndex = 0;
                nextMPDeltaRepeatCount = 0;
            }
        }

        /// <summary>
        /// Step along the motion path. We do this here because state is per sprite, not
        /// per MotionPath.
        /// </summary>
        internal void StepMotionPath()
        {
            if (motionpath != null)
            {
                Delta d = motionpath.Deltas[nextMPDeltaIndex];
                x += d.dx;
                y += d.dy;
                if (++nextMPDeltaRepeatCount == d.num)
                {
                    nextMPDeltaRepeatCount = 0;
                    nextMPDeltaIndex = (nextMPDeltaIndex + 1) % motionpath.Deltas.Count;
                }
            }
        }
        /// <summary>
        /// Call willDraw scriptblock if any
        /// </summary>
        internal void WillDraw()
        {
            if (handler != null && handler.WillDraw != null) handler.WillDraw.Invoke(this);
        }
        /// <summary>
        /// Call didDraw scriptblock if any
        /// </summary>
        internal void DidDraw()
        {
            if (handler != null && handler.DidDraw != null) handler.DidDraw.Invoke(this);
        }

        /// <summary>
        /// Return the next image in the anim sequence for drawing.
        /// TODO: support non-automatic frame stepping
        /// </summary>
        public Image NextImage
        {
            get
            {
                int f = nextAnimFrame;
                if (++animSpeedCounter == animSpeed)
                {
                    animSpeedCounter = 0;
                    nextAnimFrame = (nextAnimFrame + 1) % numAnimFrames;
                }
                return images[f];
            }
        }

        /// <summary>
        /// Returns the current image (the one calculated by
        /// the most recent call to NextImage)
        /// </summary>
        public Image CurrImage
        {
            get { return images[nextAnimFrame]; }
        }

        protected internal Sprite(Image[] images, int x, int y, int z, bool alive, int animrate, SpriteHandler sh,MotionPath mp)
        {
            this.images = images;
            this.x = x;
            this.y = y;
            this.z = z;
            this.alive = alive;
            this.animSpeed = animrate;
            this.handler = sh;
            this.motionpath = mp;
            numAnimFrames = images.Length;
            // FIXME: the following are a bit of hack - what if images are diff sizes?
            width = images[0].Width;
            height = images[0].Height;
        }

        /// <summary>
        /// Determines if this sprite's rectangle intersects with
        /// the other one.
        /// 
        /// Both sprites need to be alive unless evenIfDead is true
        /// </summary>
        /// <param name="other">The other sprite to check</param>
        /// <param name="evenIfDead">Check even if not alive</param>
        /// <returns>true if overlapping, else false</returns>
        public bool Overlaps(Sprite other,bool evenIfDead)
        {
            int right = x + width;
            int otherRight = other.x + other.width;
            int bottom = y + height;
            int otherBottom = other.y + other.height;
            return !(other.x >= right || otherRight < x
                || other.y >= bottom || otherBottom < y);
        }
    }
}
