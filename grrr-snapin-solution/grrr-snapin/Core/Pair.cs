using System;
using System.Collections.Generic;
using System.Text;

namespace Soapyfrog.Grrr.Core
{
    public class Tuple<T1, T2>
    {
        private T1 a;
        private T2 b;

        public T1 A
        {
            get { return a; }
            set { a = value; }
        }

        public T2 B
        {
            get { return b; }
            set { b = value; }
        }

        public Tuple(T1 a, T2 b) { this.a = a; this.b = b; }
    }
    public class Tuple<T1, T2, T3>
    {
        private T1 a;
        private T2 b;
        private T3 c;

        public T1 A
        {
            get { return a; }
            set { a = value; }
        }

        public T2 B
        {
            get { return b; }
            set { b = value; }
        }
        public T3 C
        {
            get { return c; }
            set { c = value; }
        }

        public Tuple(T1 a, T2 b, T3 c) { this.a = a; this.b = b; this.c = c; }
    }

    public class Pair<T> : Tuple<T, T> {
        public Pair(T a, T b) : base(a, b) { }
    }
}
