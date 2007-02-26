using System;
using System.Collections.Generic;
using System.Text;

namespace Soapyfrog.Grrr.Core
{
    /// <summary>
    /// Rectangular reference, supports x,y,w,h as well as x,y,x2,y2
    /// and assignment to/from ps Rectangle
    /// </summary>
    public class Rect
    {
        private int x;
        private int y;
        private int w;
        private int h;

        /// <summary>
        /// 
        /// </summary>
        public int X { get { return x; } set { x = value; } }
        /// <summary>
        /// 
        /// </summary>
        public int Y { get { return y; } set { y = value; } }
        /// <summary>
        /// 
        /// </summary>
        public int Width { get { return w; } set { w = value; } }
        /// <summary>
        /// 
        /// </summary>
        public int Height { get { return h; } set { h = value; } }

        /// <summary>
        /// 
        /// </summary>
        public int X2 { get { return x + w; } }  // last column+1
        /// <summary>
        /// 
        /// </summary>
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

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
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
        /// Determines if this rect is completely inside the other one.
        /// </summary>
        /// <param name="other"></param>
        /// <returns>A bitwise OR of Edge of which edges this rect has exceeded 
        /// (Edge.None if completely inside).
        /// </returns>
        public Edge Inside(Rect other)
        {
            Edge edges = Edge.None;
            if (x < other.x) edges |= Edge.Left;
            if (y < other.y) edges |= Edge.Top;
            if (X2 > other.X2) edges |= Edge.Right;
            if (Y2 > other.Y2) edges |= Edge.Bottom;
            return edges;
            //return x >= other.x && y >= other.y && X2 <= other.X2 && Y2 <= other.Y2;
        }
    }
    /// <summary>
    /// A flag-style enum of edges, representing the sides of rectangle.
    /// </summary>
    [Flags]
    public enum Edge { 
        /// <summary>
        /// 
        /// </summary>
        None = 0, 
        /// <summary>
        /// 
        /// </summary>
        Left = 1, 
        /// <summary>
        /// 
        /// </summary>
        Right = 2, 
        /// <summary>
        /// 
        /// </summary>
        Top = 4, 
        /// <summary>
        /// 
        /// </summary>
        Bottom = 8 
    }
}
