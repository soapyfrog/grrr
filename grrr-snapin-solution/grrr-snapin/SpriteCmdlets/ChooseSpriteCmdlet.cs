using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;
using System.Security;

namespace Soapyfrog.Grrr.SpriteCmdlets
{
    /// <summary>
    /// Choose a Sprite from input Sprite based on the supplied critieria.
    /// Useful for picking a Sprite to participate in, say, firing a missile
    /// or starting a new motionpath.
    /// 
    /// Can return a random sprite (-Any), the first one (-First) or all (-All)
    /// with predicates of -Active or -Inactive.
    /// </summary>
    [Cmdlet("Choose", "Sprite")]
    [SecurityCritical]
    public class ChooseSpriteCmdlet : PSCmdlet
    {
        private List<Sprite> allsprites = new List<Sprite>();
        private Sprite[] sprites;
        private static readonly Random RND = new Random(new DateTime().Millisecond);

        [Parameter(Position = 0, Mandatory = true, ValueFromPipeline = true)]
        [ValidateNotNull]
        public Sprite[] Sprites { get { return sprites; } set { sprites = value; } }

        private static readonly Predicate<Sprite> ACTIVE_PRED = delegate(Sprite s) { return s.Active; };
        private static readonly Predicate<Sprite> INACTIVE_PRED = delegate(Sprite s) { return !s.Active; };

        private Predicate<Sprite> pred = null;

        [Parameter()]
        public SwitchParameter Active
        {
            get { return pred == ACTIVE_PRED; }
            set { pred = value ? ACTIVE_PRED : null; }
        }

        [Parameter()]
        public SwitchParameter Inactive
        {
            get { return pred == INACTIVE_PRED; }
            set { pred = value ? INACTIVE_PRED : null; }
        }

        private bool any;
        [Parameter()]
        public SwitchParameter Any
        {
            get { return any; }
            set { any = value; }
        }

        private bool all;
        [Parameter()]
        public SwitchParameter All
        {
            get { return all; }
            set { all = value; }
        }

        private bool first;
        [Parameter()]
        public SwitchParameter First
        {
            get { return first; }
            set { first = value; }
        }

        protected override void ProcessRecord()
        {
            if (sprites != null)
            {
                foreach (Sprite s in sprites) allsprites.Add(s);
            }
        }

        protected override void EndProcessing()
        {
            Sprite[] sa = allsprites.ToArray();
            if (pred != null)
                sa = Array.FindAll(sa, pred);
            if (any)
                WriteObject(sa[RND.Next(sa.Length)]);
            else if (first && sa.Length > 0)
                WriteObject(sa[0]);
            else if (all)
                WriteObject(sa,true);
            else
                WriteWarning("You must chose one of -Any, -All or -First");
        }
    }



}
