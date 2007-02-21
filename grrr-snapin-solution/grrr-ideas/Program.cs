using System;
using System.Collections.Generic;
using System.Text;
using Soapyfrog.Grrr.Core;
using System.Threading;
using Microsoft.DirectX;
using Microsoft.DirectX.DirectSound;
using System.Runtime.InteropServices;

namespace grrr_ideas
{
    class Program
    {
        static void Main(string[] args)

        {
            List<Tuple<int, string>> x = new List<Tuple<int, string>>();
            x.Add(new Tuple<int,string>(10, "hello"));
            x.Add(new Tuple<int, string>(15, "chips"));

            x.Add(new Tuple<int, string>(10, "goodbye"));
            x.Add(new Tuple<int, string>(5, "fish"));
            x.Sort(delegate(Tuple<int, string> a, Tuple<int, string> b) { return a.A.CompareTo(b.A); });
            foreach (Tuple<int, string> t in x)
            {
                Console.WriteLine("key={0}, value={1}", t.A,t.B);
            }
        }
    }
}
