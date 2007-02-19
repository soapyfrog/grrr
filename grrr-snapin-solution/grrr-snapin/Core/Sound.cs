using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;

namespace Soapyfrog.Grrr.Core
{
    public class Sound
    {
        private object player;
        internal readonly ScriptBlock play,pause,stop,replay;

        public object Player
        {
            get { return player; }
        }

        protected internal Sound(object player, 
            ScriptBlock play, ScriptBlock stop, ScriptBlock pause, ScriptBlock replay)
        {
            this.player = player;
            this.play = play;
            this.pause = pause;
            this.stop = stop;
            this.replay = replay;
        }


    }
}
