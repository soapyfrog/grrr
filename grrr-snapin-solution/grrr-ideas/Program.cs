using System;
using System.Collections.Generic;
using System.Text;
using Soapyfrog.Grrr.Core;

namespace grrr_ideas
{
    class Program
    {
        static void Main(string[] args)
        {
            Rect r1 = new Rect(10, 10, 5, 3);
            Rect r2 = new Rect(11, 10, 5, 3);

            Console.WriteLine("r1=" + r1);
            Console.WriteLine("r2=" + r2);

            Console.WriteLine(r1.Overlaps(r2));
            Console.WriteLine(r1.Inside(r2));



        }
    }



}
