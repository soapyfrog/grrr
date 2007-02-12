using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
{
    public class KeyEventMap
    {
        private Dictionary<int,ScriptBlock> keydown = new Dictionary<int,ScriptBlock>();
        private Dictionary<int,ScriptBlock> keyup = new Dictionary<int,ScriptBlock>();

        protected internal KeyEventMap()
        {
            // just to prevent someone from creating one manually
        }

        public void RegisterKeyEvent(int keycode, ScriptBlock down, ScriptBlock up)
        {
            if (down != null) keydown.Add(keycode,down);
            if (up != null) keyup.Add(keycode,up);
        }

        public void ProcessKeyEvents(PSHostRawUserInterface ui)
        {
            while (ui.KeyAvailable)
            {
                KeyInfo ki = ui.ReadKey(ReadKeyOptions.IncludeKeyDown | ReadKeyOptions.IncludeKeyUp| ReadKeyOptions.NoEcho);
                int vk = ki.VirtualKeyCode;
                ScriptBlock sb;
                if (ki.KeyDown)
                    keydown.TryGetValue(vk, out sb);
                else
                    keyup.TryGetValue(vk, out sb);

                if (sb != null) sb.Invoke();
            }
        }

    }
}
