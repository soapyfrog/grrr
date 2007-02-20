using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using Microsoft.DirectX;
using Microsoft.DirectX.DirectSound;
using System.Runtime.InteropServices;


namespace Soapyfrog.Grrr.Core 
{
    public class Sound : IDisposable
    {
        #region static content
        private static Device device;
        private static int bufCount = 0;
        private static bool available;

        /// <summary>
        /// DirectSound apps need a window handle so sound can be muted when lose focus or something.
        /// This lets us use the desktop window handle.
        /// </summary>
        /// <returns></returns>
        [DllImport("user32.dll", SetLastError = true, CallingConvention = CallingConvention.Winapi)]
        static extern IntPtr GetDesktopWindow();

        public static bool SoundAvailable { get { return available; } }

        static Sound()
        {
            // Not sure what the equiv of java's Class.forName() is for testing availability...
            try
            {
                Device d = new Microsoft.DirectX.DirectSound.Device();
                d.Dispose();
                available = true;
            }
            catch (Exception e){
                // to avoid warning on e not being used. 
                // is there a [SuppressWarning] attribute?
                available = (e == null); 
            }

        }

        /// <summary>
        /// Lets you see how many buffers exist. If non-zero, the device will be held open.
        /// You should explicitly Dispose of sounds you create when you're done, other wise
        /// the GC will deal with it eventually.
        /// </summary>
        public static int BufferCount { get { return bufCount; } }


        /// <summary>
        /// Get the Device to use
        /// </summary>
        private static Device AudioDevice
        {
            get {
                if (!available) throw new Exception("DirectX DirectSound not available");
                if (device == null)
                {
                    try
                    {
                        device = new Microsoft.DirectX.DirectSound.Device();
                        device.SetCooperativeLevel(GetDesktopWindow(), CooperativeLevel.Priority);
                        return device;
                    }
                    catch (Exception e)
                    {
                        throw new Exception("Error getting sound device", e);
                    }
                }
                return device;
            }
        }

        #endregion

        private SecondaryBuffer secbuf;


        protected internal Sound(string fileName)
        {
            // buffer description
            BufferDescription bd = new BufferDescription();
            bd.Control3D = false;
            bd.ControlVolume = true;
            bd.ControlFrequency = true;
            bd.Flags |= BufferDescriptionFlags.GlobalFocus; // so always plays

            // secondary buffer for wave file
            try
            {
                Device dev = AudioDevice;
                bufCount++;
                secbuf = new SecondaryBuffer(fileName, bd, dev);
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
            Dispose(false);
        }


        #region IDisposable Members

        internal void Dispose(bool disposing)
        {
            if (secbuf != null)
                secbuf.Dispose();
            if (--bufCount == 0)
            {
                device.Dispose();
                device = null;
            }
        }

        public void Dispose() { Dispose(true); GC.SuppressFinalize(this); }

        #endregion
    }
}
