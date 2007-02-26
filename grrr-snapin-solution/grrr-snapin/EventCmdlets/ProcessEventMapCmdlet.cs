using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;

namespace Soapyfrog.Grrr.EventCmdlets
{
    /// <summary>
    /// Create an event map.
    /// </summary>
    [Cmdlet("Process","EventMap")]
    public class ProcessEventMapCmdlet : PSCmdlet
    {
        private EventMap eventmap;

        /// <summary>
        /// The eventmap to process
        /// </summary>
        [Parameter(Position=0,Mandatory=true)]
        [ValidateNotNull]
        public EventMap EventMap
        {
            get { return eventmap; }
            set { eventmap = value; }
        }
        /// <summary>
        /// 
        /// </summary>
        protected override void EndProcessing()
        {
            eventmap.ProcessEvents(Host.UI.RawUI);
        }
    }
}
