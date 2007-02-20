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
            bool b = Sound.SoundAvailable;
            Console.WriteLine(b);
        }
    }
}
