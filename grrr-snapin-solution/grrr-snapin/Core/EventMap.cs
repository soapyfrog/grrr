using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr.Core
{
    public class KeyEventMap
    {
        private Dictionary<int, ScriptBlock> keydown = new Dictionary<int, ScriptBlock>();
        private Dictionary<int, ScriptBlock> keyup = new Dictionary<int, ScriptBlock>();

        // this is to keep track of keys down to avoid invoking handlers on autorepeat.
        private Dictionary<int, bool> downMap = new Dictionary<int, bool>();

        private bool allowAutoRepeat;

        protected internal KeyEventMap(bool allowAutoRepeat)
        {
            this.allowAutoRepeat = allowAutoRepeat;
        }

        public void RegisterKeyEvent(int keycode, ScriptBlock down, ScriptBlock up)
        {
            if (down != null) keydown.Add(keycode, down);
            if (up != null) keyup.Add(keycode, up);
        }

        public void ProcessKeyEvents(PSHostRawUserInterface ui)
        {
            while (ui.KeyAvailable)
            {
                KeyInfo ki = ui.ReadKey(ReadKeyOptions.IncludeKeyDown | ReadKeyOptions.IncludeKeyUp | ReadKeyOptions.NoEcho);
                int vk = ki.VirtualKeyCode;
                ScriptBlock sb = null;
                if (ki.KeyDown)
                {
                    if (allowAutoRepeat || !downMap.ContainsKey(vk))
                    {
                        keydown.TryGetValue(vk, out sb);
                        downMap.Add(vk, true);
                    }
                }
                else
                {
                    downMap.Remove(vk);
                    keyup.TryGetValue(vk, out sb);
                }

                if (sb != null) sb.Invoke();
            }
        }

    }
}
