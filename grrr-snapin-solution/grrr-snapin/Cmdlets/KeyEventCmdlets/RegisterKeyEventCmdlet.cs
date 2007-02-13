using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
{
    /// <summary>
    /// Create a key event map.
    /// </summary>
    [Cmdlet("Register","KeyEvent")]
    public class RegisterKeyEventCmdlet : PSCmdlet
    {
        private KeyEventMap keyeventmap;

        [Parameter(Position=0,Mandatory=true)]
        [ValidateNotNull]
        public KeyEventMap KeyEventMap
        {
            get { return keyeventmap; }
            set { keyeventmap = value; }
        }

        private int keyCode;

        [Parameter(Position=1,Mandatory=true)]
        public int KeyCode
        {
            get { return keyCode; }
            set { keyCode = value; }
        }

        private ScriptBlock up;

        [Parameter(Position=2)]
        [ValidateNotNull]
        public ScriptBlock KeyUp
        {
            get { return up; }
            set { up = value; }
        }

        private ScriptBlock down;

        [Parameter(Position = 3)]
        [ValidateNotNull]
        public ScriptBlock KeyDown
        {
            get { return down; }
            set { down = value; }
        }

        protected override void EndProcessing()
        {
            keyeventmap.RegisterKeyEvent(keyCode, down, up);
        }
    }
}
