using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Media;

namespace Soapyfrog.Grrr.Core
{
    public class Sound : IDisposable
    {
        private SoundPlayer player;

        protected internal Sound(string fileName)
        {

            player = new SoundPlayer();
            //player.LoadCompleted += new AsyncCompletedEventHandler(player_LoadCompleted);

            try
            {
                player.SoundLocation = fileName;
                player.Load();

            }
            catch (Exception e)
            {
                throw new Exception("Unable to create buffer for sound", e);
            }
        }

        public void Play(bool stopExisting, bool loop)
        {
            if (stopExisting)
            {
                Stop();
            }
            if (loop)
            {
                player.PlayLooping();
            }
            else
            {
                player.Play();
            }

        }

        public void Stop()
        {
            player.Stop();
        }



        ~Sound()
        {
            Dispose();
        }

        public void Dispose()
        {
            player.Dispose();
        }
    }

}
