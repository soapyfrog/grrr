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
        #region static content
        private static Device device;

        static Sound()
        {
            try
            {
                device = new Microsoft.DirectX.DirectSound.Device();
                device.SetCooperativeLevel(GetDesktopWindow(), CooperativeLevel.Priority);
            }
            catch (Exception e)
            {
                throw new Exception("DirectX DirectSound unavailable",e);
            }
        }

        /// <summary>
        /// DirectSound apps need a window handle so sound can be muted when lose focus or something.
        /// This lets us use the desktop window handle.
        /// </summary>
        /// <returns></returns>
        [DllImport("user32.dll", SetLastError = true, CallingConvention = CallingConvention.Winapi)]
        static extern IntPtr GetDesktopWindow();

        public static bool SoundAvailable { get { return device!=null; } }

        #endregion

        private SecondaryBuffer secbuf;


        protected internal Sound(string fileName)
        {
            if (device == null) throw new Exception("Sound device is not available");
            // buffer description
            BufferDescription bd = new BufferDescription();
            bd.Control3D = false;
            bd.ControlVolume = true;
            bd.ControlFrequency = true;
            bd.Flags |= BufferDescriptionFlags.GlobalFocus; // so always plays

            // secondary buffer for wave file
            try
            {
                secbuf = new SecondaryBuffer(fileName, bd, device);
            }
            catch (Exception e)
            {
                throw new Exception("Unable to create buffer for sound", e);
            }
        }

        public void Play(bool stopExisting)
        {
            if (secbuf != null)
            {
                if (stopExisting) secbuf.Stop();
                secbuf.Play(0, BufferPlayFlags.Default);
            }
        }

        public void Stop()
        {
            if (secbuf != null) {
                secbuf.Stop();
            }
        }

        ~Sound()
        {
            if (secbuf != null)
                secbuf.Dispose();
        }

    }
}
