using System;
using System.Collections.Generic;
using System.Text;

namespace Soapyfrog.Grrr.Core
{
    /// <summary>
    /// Rectangular reference
    /// </summary>
    public class Rect
    {

        private int x;

        public int X
        {
            get { return x; }
            set { x = value; }
        }

        private int y;

        public int Y
        {
            get { return y; }
            set { y = value; }
        }

        private int w;

        public int Width
        {
            get { return w; }
            set { w = value; }
        }

        private int h;

        public int Height
        {
            get { return h; }
            set { h = value; }
        }

        public int X2 { get { return x + w; } }  // last column+1
        public int Y2 { get { return y + h; } } // last row + 1

        public Rect(int x, int y, int w, int h)
        {
            this.x = x;
            this.y = y;
            this.w = w;
            this.h = h;
        }

        public override string ToString()
        {
            return string.Format("x={0} y={1} w={2} h={3}", x, y, w, h);
        }

    }
}
