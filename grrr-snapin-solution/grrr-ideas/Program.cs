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
            foreach (string ts in new string[]{"abcdefghi","jklmnopqr","stuvwxyz","0123456789","!@#$%^&*()",
                "-_=+[{]}","\\|'\",.<>/?`~"})
            {
                Console.WriteLine(ts);
                string[] ss = Banner.Render(ts);
                foreach (string s in ss) Console.WriteLine(s);
            }
        }
    }
}
