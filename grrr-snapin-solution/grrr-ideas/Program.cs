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
            PlayDirectX();
        }

        /// <summary>
        /// DirectSound apps need a window handle so sound can be muted when lose focus or something.
        /// This lets us use the desktop window handle.
        /// </summary>
        /// <returns></returns>
        [DllImport("user32.dll", SetLastError = true, CallingConvention = CallingConvention.Winapi)]
        static extern IntPtr GetDesktopWindow();

        static void PlayDirectX()
        {
            // get a device
            Device device = new Microsoft.DirectX.DirectSound.Device();
            device.SetCooperativeLevel(GetDesktopWindow(), CooperativeLevel.Priority);

            // buffer description
            BufferDescription bd = new BufferDescription();
            bd.Control3D = false;
            bd.ControlVolume = true;
            bd.ControlFrequency = true;
            bd.Flags |= BufferDescriptionFlags.GlobalFocus; // so always plays

            // secondary buffer for wave file
            SecondaryBuffer secbuf = new SecondaryBuffer(@"c:\windows\media\tada.wav", bd, device);

            secbuf.Play(0, BufferPlayFlags.Default);

            // cool

            Thread.Sleep(1000);
        }

    }



}
