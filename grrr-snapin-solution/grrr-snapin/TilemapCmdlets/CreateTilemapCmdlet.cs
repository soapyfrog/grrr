using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;
using Soapyfrog.Grrr.Core;

namespace Soapyfrog.Grrr.TilemapCmdlets
{
    /// <summary>
    /// Create a tilemap. A tilemap is a set of same-size tile images keyed
    /// by a character. An array of string lines denotes where each tile goes.
    /// TODO: explain this better, note scramble demo.
    /// </summary>
    [Cmdlet("Create", "Tilemap")]
    public class CreateTilemapCmdlet : PSCmdlet
    {
        private string[] lines;
        private List<string> allLines = new List<string>();
        private IDictionary imagemap;

        [Parameter(Position = 0, ValueFromPipeline = true, Mandatory = true)]
        [ValidateNotNullOrEmpty]
        public string[] Lines { set { lines = value; } get { return lines; } }

        [Parameter(Position = 1, Mandatory = true)]
        [ValidateNotNullOrEmpty]
        public IDictionary ImageMap { get { return imagemap; } set { imagemap = value; } }


        protected override void ProcessRecord()
        {
            if (lines != null) allLines.AddRange(lines);
        }

        protected override void EndProcessing()
        {
            // bloddy powershell
            // for some reason, if you pass a hashtable ..   @{"a"=4}
            // as a parameter, it arrives as a IDictionary of 
            // String->PSObject with BaseObject of whatever.
            Hashtable pukka = new Hashtable();
            foreach (object o in imagemap)
            {
                DictionaryEntry de = (DictionaryEntry)o;
                PSObject pso = (PSObject)de.Value;
                pukka.Add(de.Key, pso.BaseObject);
            }
            Tilemap tm = new Tilemap(allLines.ToArray(), pukka);
            WriteObject(tm, false);
        }
    }


}
