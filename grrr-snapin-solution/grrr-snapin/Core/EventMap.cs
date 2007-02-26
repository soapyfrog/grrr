using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr.Core
{
    public class EventMap
    {
        private Dictionary<int, Tuple<ScriptBlock, object>> keyDownScripts = new Dictionary<int, Tuple<ScriptBlock, object>>();
        private Dictionary<int, Tuple<ScriptBlock, object>> keyUpScripts = new Dictionary<int, Tuple<ScriptBlock, object>>();
        private List<Tuple<int, ScriptBlock, object>> afterScripts = new List<Tuple<int, ScriptBlock, object>>();

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
            while (ui.KeyAvailable)
            {
                KeyInfo ki = ui.ReadKey(ReadKeyOptions.IncludeKeyDown | ReadKeyOptions.IncludeKeyUp | ReadKeyOptions.NoEcho);
                int vk = ki.VirtualKeyCode;
                Tuple<ScriptBlock, object> sbo = null;
                if (ki.KeyDown)
                {
                    if (allowAutoRepeat || !keyDownState.ContainsKey(vk))
                    {
                        keyDownScripts.TryGetValue(vk, out sbo);
                        keyDownState.Add(vk, true);
                    }
                }
                else
                {
                    keyDownState.Remove(vk);
                    keyUpScripts.TryGetValue(vk, out sbo);
                }
                // invoke the script passing this and the keyinfo in
                if (sbo != null) sbo.A.InvokeReturnAsIs(this, ki, sbo.B);
            }
            // not check if there are any timed events
            eventNum++;
            while (afterScripts.Count > 0 && afterScripts[0].A >= eventNum)
            {
                // if found, pass this and the eventnum in
                afterScripts[0].B.InvokeReturnAsIs(this, eventNum,afterScripts[0].C);
                afterScripts.RemoveAt(0);
            }
        }


        internal void RegisterKeyDownEvent(int keyDown, ScriptBlock sb,object context)
        {
            keyDownScripts.Add(keyDown, new Tuple<ScriptBlock, object>(sb, context));
        }

        internal void RegisterKeyUpEvent(int keyUp, ScriptBlock sb, object context)
        {
            keyUpScripts.Add(keyUp, new Tuple<ScriptBlock, object>(sb, context));
        }

        internal void RegisterAfterEvent(int after, ScriptBlock sb, object context)
        {
            afterScripts.Add(new Tuple<int, ScriptBlock, object>(eventNum + after, sb, context));
            // keep it sorted in ascending target eventNum order
            afterScripts.Sort(delegate(Tuple<int, ScriptBlock, object> a, Tuple<int, ScriptBlock, object> b) { return a.A.CompareTo(b.A); });
        }
    }
}
