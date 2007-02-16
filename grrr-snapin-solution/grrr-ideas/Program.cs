using System;
using System.Collections.Generic;
using System.Text;

namespace grrr_ideas
{
    class Program
    {
        static void Main(string[] args)
        {
            Mover m = new Mover(10);
            foreach (Delta d in m)
            {
                Console.WriteLine(d);
            }
        }
    }



    class Delta {
        int dx,dy;
        internal Delta(int x,int y){dx=x;dy=y;}
        public override string ToString()
        {
            return dx + "," + dy;
        }
    }

    class Mover : IEnumerable<Delta>
    {
        private int size;
        internal Mover(int size)
        {
            this.size = size;
        }

        #region IEnumerable<Delta> Members

        public IEnumerator<Delta> GetEnumerator()
        {
            for (int i=0;i<size;i++) {
                yield return new Delta(1,1);
            }
        }

        #endregion

        #region IEnumerable Members

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
        {
            throw new Exception("The method or operation is not implemented.");
        }

        #endregion
    }
}
