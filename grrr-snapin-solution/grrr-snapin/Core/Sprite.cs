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
        private int x, y, z;
        private bool alive = true;
        private Hashtable state = new Hashtable(); // used by handlers to store their one state
        private SpriteHandler handler;
        private MotionPath motionpath;
        private string tag; // optional tag string
        private Rect bounds; // optional bounds

        // This is the rectangle in which all images will be drawn. It's used for checking if
        // the sprite goes out of bounds and for overlap tests.
        private Rect rect = new Rect(0, 0, 0, 0);
        private int refx, refy; // cache reference point offset


        /// <summary>
        /// User settable state properties. Saves mucking about with
        /// adding note-properties.
        /// </summary>
        public Hashtable State
        {
            get { return state; }
            set { state = value; }
        }

        /// <summary>
        /// The bounds in which this sprite will be drawn. If the
        /// sprite is not completely within bounds, DidExceedBounds
        /// handler is fired.
        /// </summary>
        public Rect Bounds { get { return bounds; } set { bounds = value; } }

        /// <summary>
        /// The rectangle used to draw the sprite, regardless of image used.
        /// </summary>
        public Rect Rect { get { return rect; } }

        public int X { get { return x; } set { rect.X = value - refx; x = value; } }
        public int Y { get { return y; } set { rect.Y = value - refy; y = value; } }
        public int Z { get { return z; } set { z = value; } }

        public bool Alive { get { return alive; } set { alive = value; } }
        public int AnimRate { get { return animRate; } set { animRate = value; } }
        public Image[] Images { get { return images; } }
        public string Tag { get { return tag; } set { tag = value; } }

        // Width and Height properties are based on current image so can change.
        public int Width { get { return CurrImage.Width; } }
        public int Height { get { return CurrImage.Height; } }


        // stuff for animation
        private int animRate = 1;          // 1 means update every frame
        private int numAnimFrames;
        private int nextAnimFrame = 0;      // frame sequence
        private int animSpeedCounter = 0;   // when reaches animRate, nextAnimFrame++

        // stuff for motion path
        private System.Collections.Generic.IEnumerator<Delta> motionpathDeltaEnumerator;

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
                motionpathDeltaEnumerator = motionpath.GetDeltaEnumerator();
            }
        }

        /// <summary>
        /// Move the anim frame pointer to the next frame ready for drawing next time.
        /// If there is a DidEndAnim handler, it will be called.
        /// 
        /// This should be called after drawing as a common use for it is to reset
        /// the animation frames or sequence and this should be done after the last
        /// frame was drawn.
        /// 
        /// TODO: eventually, we might want to implement this as an image
        /// Enumerator to provide for more general image sequencing.
        /// </summary>
        internal void StepAnim()
        {
            if (++animSpeedCounter == animRate)
            {
                animSpeedCounter = 0;
                nextAnimFrame = (nextAnimFrame + 1) % numAnimFrames;
                if (nextAnimFrame == 0 && handler != null && handler.DidEndAnim != null)
                    handler.DidEndAnim.InvokeReturnAsIs(this);
            }
        }

        /// <summary>
        /// Make a motion step of a motionpath has been specified.
        /// Regardless, WillMove and DidMove handlers are fired if available.
        /// 
        /// If a motionhandler comes to an end and DidEndMotion handler is available,
        /// it will be fired.
        /// </summary>
        internal void StepMotion()
        {
            // always fire WillMove
            if (handler != null && handler.WillMove != null) handler.WillMove.InvokeReturnAsIs(this);
            // if we have an Enumerator...
            if (motionpathDeltaEnumerator != null)
            {
                if (motionpathDeltaEnumerator.MoveNext())
                {
                    Delta d = motionpathDeltaEnumerator.Current;
                    X += d.dx;
                    Y += d.dy;
                    Y += d.dz;
                    // out of bounds check
                    if (handler != null && handler.DidExceedBounds != null & OutOfBounds)
                        handler.DidExceedBounds.InvokeReturnAsIs(this);
                }
                else
                {
                    motionpathDeltaEnumerator = null; // prevent indefinite firing of DidEndMotion
                    if (handler != null && handler.DidEndMotion != null)
                        handler.DidEndMotion.InvokeReturnAsIs(this);
                }
            }
            // always fire DidMove
            if (handler != null && handler.DidMove != null) handler.DidMove.InvokeReturnAsIs(this);
        }

        /// <summary>
        /// Call willDraw scriptblock if any
        /// </summary>
        internal void PreDraw()
        {
            if (handler != null && handler.WillDraw != null) handler.WillDraw.InvokeReturnAsIs(this);
        }
        /// <summary>
        /// Call didDraw scriptblock if any
        /// </summary>
        internal void PostDraw()
        {
            if (handler != null && handler.DidDraw != null) handler.DidDraw.InvokeReturnAsIs(this);
        }

        /// <summary>
        /// Call the didOverlap for this sprite with the overlapping partner as the second param
        /// and this as the first.
        /// This is called by Test-SpriteOverlap.
        /// </summary>
        /// <param name="otherSprite"></param>
        internal void DidOverlap(Sprite otherSprite)
        {
            if (handler != null && handler.DidOverlap != null) handler.DidOverlap.InvokeReturnAsIs(this, otherSprite);
        }

        /// <summary>
        /// Returns the current image (the one calculated by
        /// the most recent call to StepAnim or changed manually)
        /// </summary>
        public Image CurrImage
        {
            get { return images[nextAnimFrame]; }
        }

        protected internal Sprite(Image[] images, int x, int y, int z, bool alive, int animrate,
            SpriteHandler sh, MotionPath mp, string tag, Rect bounds)
        {
            this.images = images;
            this.animRate = animrate;
            numAnimFrames = images.Length;
            this.bounds = bounds;

            this.x = x;
            this.y = y;
            this.z = z;
            this.alive = alive;
            this.tag = tag;

            this.handler = sh;

            motionpath = mp;
            if (mp != null) motionpathDeltaEnumerator = mp.GetDeltaEnumerator();

            // set up the rectangle in which the sprite will be drawn
            // regardless of which image is being used.
            fixDrawRect();
        }


        private void fixDrawRect()
        {
            Image i = images[0]; // TODO: should check sizes of all images
            refx = i.RefX;
            refy = i.RefY;
            rect.X = x - refx;
            rect.Y = y - refy;
            rect.Width = i.Width;
            rect.Height = i.Height;
        }

        /// <summary>
        /// Determines if this sprite's rectangle intersects with
        /// the b one.
        /// 
        /// Both sprites need to be alive unless evenIfDead is true
        /// </summary>
        /// <param name="b">The b sprite to check</param>
        /// <param name="evenIfDead">Check even if not alive</param>
        /// <returns>true if overlapping, else false</returns>
        public bool Overlaps(Sprite other, bool evenIfDead)
        {
            if (!evenIfDead && !(alive && other.alive)) return false;
            return rect.Overlaps(other.rect);
        }


        /// <summary>
        /// Check if any part of the sprite has gone outside of the boundary. This takes into
        /// account the reference point, so a large 10 cell wide sprite with ref point of 5,0
        /// would be out of bounds if the X pos was 4.
        /// </summary>
        public bool OutOfBounds
        {
            get { return bounds != null && !rect.Inside(bounds); }
        }

    }

}
