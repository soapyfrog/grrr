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
    /// Create a key event map.
    /// </summary>
    [Cmdlet("Create","EventMap")]
    [SecurityCritical]
    public class CreateEventMapCmdlet : PSCmdlet
    {
        private bool allowAutoRepeat;

        /// <summary>
        /// By default, the eventmap will not send down events when the
        /// keyboard autorepeats (to avoid unneccessary scriptblock
        /// invocations). Setting this switch will allow them.
        /// </summary>
        [Parameter()]
        public SwitchParameter AllowAutoRepeat
        {
            get { return allowAutoRepeat; }
            set { allowAutoRepeat = value; }
        }
	
        protected override void EndProcessing()
        {
            WriteObject(new EventMap(allowAutoRepeat), false);
        }
    }
}
