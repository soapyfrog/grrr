using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;

namespace Soapyfrog.Grrr.EventCmdlets
{
    /// <summary>
    /// Register an event.
    /// </summary>
    [Cmdlet("Register", "Event")]
    public class RegisterEventCmdlet : PSCmdlet
    {
        private EventMap eventmap;
        private ScriptBlock sb;
        private int keyDown = -1, keyUp = -1, after = -1;

        [Parameter(Position = 0, Mandatory = true)]
        [ValidateNotNull]
        public EventMap EventMap
        {
            get { return eventmap; }
            set { eventmap = value; }
        }

        [Parameter(Position=1,Mandatory=true)]
        [ValidateNotNull]
        public ScriptBlock ScriptBlock { set { sb = value; } get { return sb; } }

        [Parameter()]
        [ValidateRange(1,65535)]
        public int KeyDown
        {
            get { return keyDown; }
            set { keyDown = value; }
        }
        [Parameter()]
        [ValidateRange(1, 65535)]
        public int KeyUp
        {
            get { return keyUp; }
            set { keyUp = value; }
        }

        [Parameter()]
        [ValidateRange(1, int.MaxValue)]
        public int After
        {
            get { return after; }
            set { after = value; }
        }

        protected override void EndProcessing()
        {
            if (keyDown > 0) eventmap.RegisterKeyDownEvent(keyDown, sb);
            else if (keyUp > 0) eventmap.RegisterKeyUpEvent(keyUp, sb);
            else if (after > 0) eventmap.RegisterAfterEvent(after, sb);
            else throw new Exception("Should specify exactly one of KeyUp,KeyDown or After parameters");
        }
    }
}
