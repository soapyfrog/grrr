using System;
using System.Collections.Generic;
using System.Text;

namespace Soapyfrog.Grrr.Core
{
    public class Delta
    {
        public readonly int dx, dy, dz;

        public Delta(int dx, int dy, int dz)
        {
            this.dx = dx;
            this.dy = dy;
            this.dz = dz;
        }
    }
}
