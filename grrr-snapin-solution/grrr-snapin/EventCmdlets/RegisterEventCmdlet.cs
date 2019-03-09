using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;
using System.Security;

namespace Soapyfrog.Grrr.EventCmdlets
{
    /// <summary>
    /// Register an event.
    /// </summary>
    [Cmdlet("Register", "Event")]
    [SecurityCritical]
    public class RegisterEventCmdlet : PSCmdlet
    {
        private EventMap eventmap;
        private ScriptBlock sb;
        private int keyDown = -1, keyUp = -1, after = -1;
        private object context = null;

        [Parameter(Position = 0, Mandatory = true)]
        [ValidateNotNull]
        public EventMap EventMap
        {
            get { return eventmap; }
            set { eventmap = value; }
        }

        [Parameter(Position = 1, Mandatory = true)]
        [ValidateNotNull]
        public ScriptBlock ScriptBlock { set { sb = value; } get { return sb; } }

        [Parameter(Position = 2)]
        [ValidateNotNull]
        public object Context { set { context = value; } get { return context; } }

        [Parameter()]
        [ValidateRange(1, 65535)]
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
            if (keyDown > 0) eventmap.RegisterKeyDownEvent(keyDown, sb, context);
            else if (keyUp > 0) eventmap.RegisterKeyUpEvent(keyUp, sb, context);
            else if (after > 0) eventmap.RegisterAfterEvent(after, sb, context);
            else throw new Exception("Should specify exactly one of KeyUp,KeyDown or After parameters");
        }
    }
}
