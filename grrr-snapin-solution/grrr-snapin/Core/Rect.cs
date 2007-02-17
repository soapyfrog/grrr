using System;
using System.Collections.Generic;
using System.Text;

namespace Soapyfrog.Grrr.Core
{
    public interface IRect
    {
        int X { get;}
        int Y { get;}
        int Width { get;}
        int Height { get;}
        int X2 { get;}
        int Y2 { get;}
    }

    /// <summary>
    /// Rectangular reference, supports x,y,w,h as well as x,y,x2,y2
    /// and assignment to/from ps Rectangle
    /// </summary>
    public class Rect : IRect
    {
        private int x;
        private int y;
        private int w;
        private int h;

        public int X { get { return x; } set { x = value; } }
        public int Y { get { return y; } set { y = value; } }
        public int Width { get { return w; } set { w = value; } }
        public int Height { get { return h; } set { h = value; } }

        public int X2 { get { return x + w; } }  // last column+1
        public int Y2 { get { return y + h; } } // last row + 1

        /// <summary>
        /// Construct from intrinsics
        /// </summary>
        public Rect(int x, int y, int w, int h)
        {
            this.x = x;
            this.y = y;
            this.w = w;
            this.h = h;
        }

        public override string ToString()
        {
            return string.Format("x={0} y={1} w={2} h={3} x2={4} y2={5}",
                x, y, w, h,X2,Y2);
        }


        /// <summary>
        /// Returns true if this Rect overlaps the other one.
        /// </summary>
        public bool Overlaps(Rect other)
        {
            return !(other.x >= X2 || other.X2 < x ||
                other.y >= Y2 || other.Y2 < y);
        }

        /// <summary>
        /// Returns true if this Rect is entirely inside the
        /// other one.
        /// </summary>
        public bool Inside(Rect other)
        {
            return x >= other.x && y >= other.y && X2 <= other.X2 && Y2 <= other.Y2;
        }
    }
}
