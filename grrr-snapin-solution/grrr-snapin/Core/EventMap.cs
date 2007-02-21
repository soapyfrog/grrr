using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr.Core
{
    public class EventMap
    {
        private Dictionary<int, ScriptBlock> keyDownScripts = new Dictionary<int, ScriptBlock>();
        private Dictionary<int, ScriptBlock> keyUpScripts = new Dictionary<int, ScriptBlock>();
        private List<Tuple<int,ScriptBlock>> afterScripts = new List<Tuple<int,ScriptBlock>>();

        // this is to keep track of keys down to avoid invoking handlers on autorepeat.
        private Dictionary<int, bool> keyDownState = new Dictionary<int, bool>();

        private bool allowAutoRepeat;

        private int eventNum = 0; // used for "after" events

        protected internal EventMap(bool allowAutoRepeat)
        {
            this.allowAutoRepeat = allowAutoRepeat;
        }

        public void ProcessEvents(PSHostRawUserInterface ui)
        {
            // key events first
            ScriptBlock sb;
            while (ui.KeyAvailable)
            {
                KeyInfo ki = ui.ReadKey(ReadKeyOptions.IncludeKeyDown | ReadKeyOptions.IncludeKeyUp | ReadKeyOptions.NoEcho);
                int vk = ki.VirtualKeyCode;
                sb = null;
                if (ki.KeyDown)
                {
                    if (allowAutoRepeat || !keyDownState.ContainsKey(vk))
                    {
                        keyDownScripts.TryGetValue(vk, out sb);
                        keyDownState.Add(vk, true);
                    }
                }
                else
                {
                    keyDownState.Remove(vk);
                    keyUpScripts.TryGetValue(vk, out sb);
                }
                // invoke the script passing this and the keyinfo in
                if (sb != null) sb.InvokeReturnAsIs(this,ki);
            }
            // not check if there are any timed events
            eventNum++;
            while (afterScripts.Count > 0 && afterScripts[0].A == eventNum)
            {
                // if found, pass this and the eventnum in
                afterScripts[0].B.InvokeReturnAsIs(this, eventNum);
                afterScripts.RemoveAt(0);
            }
        }


        internal void RegisterKeyDownEvent(int keyDown, ScriptBlock sb)
        {
            keyDownScripts.Add(keyDown, sb);
        }

        internal void RegisterKeyUpEvent(int keyUp, ScriptBlock sb)
        {
            keyUpScripts.Add(keyUp, sb);
        }

        internal void RegisterAfterEvent(int after, ScriptBlock sb)
        {
            afterScripts.Add(new Tuple<int, ScriptBlock>(eventNum + after, sb));
            // keep it sorted in ascending target eventNum order
            afterScripts.Sort(delegate(Tuple<int, ScriptBlock> a, Tuple<int, ScriptBlock> b) { return a.A.CompareTo(b.A); });
        }
    }
}
