using System;
using System.Collections.Generic;
using System.Text;
using Soapyfrog.Grrr.Core;
using System.Threading;
using Microsoft.DirectX;
using Microsoft.DirectX.DirectSound;
using System.Runtime.InteropServices;
using System.IO.Ports;
using System.IO;

namespace grrr_ideas
{
    class Program
    {
        static void Main(string[] args)

        {
            FileStream fs = new FileStream   ( @"C:\Documents and Settings\adrian\_viminfo",FileMode.Open);
            byte[] buf = new byte[30];
            AsyncCallback cb = delegate(IAsyncResult res)
            {
                Console.WriteLine("callback:" + Thread.CurrentThread.ManagedThreadId);
                foreach (byte b in buf)
                {
                    Console.Write((char)b);
                }
                fs.EndRead(res);
            };
            Console.WriteLine("main:"+Thread.CurrentThread.ManagedThreadId);
            fs.BeginRead(buf, 0, 30, cb, "hello");


        }
    }
}
