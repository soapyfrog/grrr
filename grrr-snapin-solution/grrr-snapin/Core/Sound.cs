using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using Microsoft.DirectX;
using Microsoft.DirectX.DirectSound;
using System.Runtime.InteropServices;

namespace Soapyfrog.Grrr.Core
{
    public class Sound
    {
        static Sound()
        {
        }

        private SecondaryBuffer secbuf;

        /// <summary>
        /// DirectSound apps need a window handle so sound can be muted when lose focus or something.
        /// This lets us use the desktop window handle.
        /// </summary>
        /// <returns></returns>
        [DllImport("user32.dll", SetLastError = true, CallingConvention = CallingConvention.Winapi)]
        static extern IntPtr GetDesktopWindow();


        protected internal Sound(string fileName)
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
            secbuf = new SecondaryBuffer(fileName, bd, device);
        }

        public void Play(bool stopExisting)
        {
            secbuf.Play(0, BufferPlayFlags.Default);
        }

    }
}
