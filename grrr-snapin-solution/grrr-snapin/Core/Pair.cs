using System;
using System.Collections.Generic;
using System.Text;

namespace Soapyfrog.Grrr.Core
{
    public class Pair<T>
    {
        private T a;

        public T A
        {
            get { return a; }
            set { a = value; }
        }
        private T b;

        public T B
        {
            get { return b; }
            set { b = value; }
        }

        public Pair(T a, T b) { this.a = a; this.b = b; }
    }
}
