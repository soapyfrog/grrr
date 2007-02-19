using System;
using System.Collections.Generic;
using System.Text;
using Soapyfrog.Grrr.Core;
using System.Threading;
using WMPLib;
using System.Runtime.InteropServices;
using System.Media;

namespace grrr_ideas
{
    class Program
    {
        static void Main(string[] args)
        {
            PlayWMPIOP();

        }

        // this is no better than the System.Media.SoundPlayer
        [DllImport("winmm.dll", SetLastError = true,
                              CallingConvention = CallingConvention.Winapi)]
        static extern bool PlaySound(
            string pszSound,
            IntPtr hMod,
            SoundFlags sf);

        public enum SoundFlags : int
        {
            SND_SYNC = 0x0000,  // play synchronously (default) 
            SND_ASYNC = 0x0001,  // play asynchronously 
            SND_NODEFAULT = 0x0002,  // silence (!default) if sound not found 
            SND_MEMORY = 0x0004,  // pszSound points to a memory file
            SND_LOOP = 0x0008,  // loop the sound until next sndPlaySound 
            SND_NOSTOP = 0x0010,  // don't stop any currently playing sound 
            SND_NOWAIT = 0x00002000, // don't wait if the driver is busy 
            SND_ALIAS = 0x00010000, // name is a registry alias 
            SND_ALIAS_ID = 0x00110000, // alias is a predefined ID
            SND_FILENAME = 0x00020000, // name is file name 
            SND_RESOURCE = 0x00040004  // name is resource name or atom 
        }

        static void PlayMM()
        {
            for (int i = 0; i < 4; i++)
            {
                PlaySound(@"c:\windows\media\tada.wav", IntPtr.Zero, SoundFlags.SND_ASYNC | SoundFlags.SND_FILENAME);
                Thread.Sleep(100);
            }
            Thread.Sleep(1000);
        }

        static void PlayWMPIOP()
        {
            Type t = Type.GetTypeFromProgID("wmplayer.ocx");
            object player = Activator.CreateInstance(t);
            Console.WriteLine(player.GetType());
            bool iscom=System.Runtime.InteropServices.Marshal.IsComObject(player);
            Console.WriteLine("is com " + iscom);

            player = Marshal.GetActiveObject("wmplayer.ocx");
             iscom=System.Runtime.InteropServices.Marshal.IsComObject(player);
            Console.WriteLine("is com " + iscom);
        }

        static void PlayWMP()
        {
            WindowsMediaPlayerClass[] players = new WindowsMediaPlayerClass[4];
            for (int i = 0; i < players.Length; i++)
            {
                players[i] = new WindowsMediaPlayerClass();
                IWMPMedia tada = players[i].newMedia(@"c:\windows\media\tada.wav");
                players[i].currentPlaylist.appendItem(tada);

            }

            for (int i = 0; i < players.Length; i++)
            {
                players[i].controls.play();
                Thread.Sleep(100);
            }
            Thread.Sleep(1000);
        }

        static void PlaySP()
        {
            SoundPlayer[] players = new SoundPlayer[4];
            for (int i = 0; i < players.Length; i++)
            {
                players[i] = new SoundPlayer(@"c:\windows\media\tada.wav");
                players[i].Load();
            }

            for (int i = 0; i < players.Length; i++)
            {
                players[i].Play();
                Thread.Sleep(100);
            }
            Thread.Sleep(1000);
        }

    }



}
