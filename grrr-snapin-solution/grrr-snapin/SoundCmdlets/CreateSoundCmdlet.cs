using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;

namespace Soapyfrog.Grrr.SoundCmdlets
{
    /// <summary>
    /// Create a Sound - something that can be played/stopped/etc.
    /// Returns one for each filename supplied.
    /// </summary>
    [Cmdlet("Create", "Sound")]
    public class CreateSoundCmdlet : PSCmdlet
    {
        private string[] soundfiles;

        /// <summary>
        /// Supply filenames on the cmdline
        /// </summary>
        [Parameter(Position=0,ValueFromPipeline=true,Mandatory=true)]
        [ValidateNotNullOrEmpty]
        public string[] SoundFiles
        {
            get { return soundfiles; }
            set { soundfiles = value; }
        }

        protected override void  ProcessRecord()
        {
            foreach (string soundfile in soundfiles)
            {
                // i have no idea how to easily access a com object in c# without
                // messing about with interop import dlls and wotnot, so just use
                // powershell itself.
                ScriptBlock createPlayer = InvokeCommand.NewScriptBlock(@"
$player = New-Object -ComObject 'wmplayer.ocx'
$media = $player.NewMedia($args[0])
[void]$player.CurrentPlaylist.AppendItem($media)
return $player
");
                object player = createPlayer.InvokeReturnAsIs(soundfile);

                // TODO: errors?

                ScriptBlock play = InvokeCommand.NewScriptBlock(@"$args[0].Controls.Play()");
                ScriptBlock stop = InvokeCommand.NewScriptBlock(@"$args[0].Controls.Stop()");
                ScriptBlock pause = InvokeCommand.NewScriptBlock(@"$args[0].Controls.Pause()");
                ScriptBlock replay = InvokeCommand.NewScriptBlock(@"$s=$args[0].Controls;$s.Stop();$s.Play()");


                // wrap the resulting object in a Sound object and write 
                // to the pipe.
                WriteObject(new Sound(player,play,stop,pause,replay), false);
            }
        }
    }
}
