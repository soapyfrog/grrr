using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
{


    /// <summary>
    /// Get Image(s) from a data stream. The format is a bit cheesy
    /// and definitely needs a bit of documentation.
    /// TODO: update it!
    /// </summary>
    [Cmdlet("Get", "Image")]
    public class GetImageCmdlet : PSCmdlet
    {
        private Hashtable images = new Hashtable();
        private Dictionary<char, char> translations = new Dictionary<char, char>();
        private List<char> translationSeq = new List<char>();

        private List<string> lines;
        private string id;
        private ConsoleColor fg, bg;
        private char transparent;

        private Regex beginRE = new Regex(@"^#begin\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)");
        private Regex transparentRE = new Regex(@"^#transparent\s+([^\s]+)");
        private Regex translateRE = new Regex(@"^#translate\s+([^\s]+)\s+([^\s]+)");
        private Regex commentRE = new Regex(@"^#!");
        private Regex endRE = new Regex(@"^#end");

        private object[] input;

        /// <summary>
        /// Pipeline input - had to make it object[] because if it was string[]
        /// and the input contained blank strings, it barfed.
        /// </summary>
        [Parameter(ValueFromPipeline = true,Mandatory=true)]
        public object[] InputStrings { get { return input; } set { input = value; } }

        protected override void ProcessRecord()
        {
            if (input == null) {
                WriteWarning("no input!");
                return;
            }
            foreach (object o in input)
            {
                string p = o as string;
                if (p==null)
                {
                    WriteWarning("Input is null or not a string");
                    continue;
                }

                try
                {
                    if (p.StartsWith("#"))
                    {
                        Match m;
                        if ((m = beginRE.Match(p)).Success)
                        {
                            lines = new List<string>();
                            id = m.Groups[1].Value;
                            fg = (ConsoleColor)Enum.Parse(typeof(ConsoleColor), m.Groups[2].Value, true);
                            bg = (ConsoleColor)Enum.Parse(typeof(ConsoleColor), m.Groups[2].Value, true);
                            WriteDebug(string.Format("begin image {0} {1} {2}", id, fg, bg));
                        }
                        else if ((m = transparentRE.Match(p)).Success)
                        {
                            transparent = (char)int.Parse(m.Groups[1].Value);
                            WriteDebug(string.Format("transparent={0}", (int)transparent));
                        }
                        else if ((m = translateRE.Match(p)).Success)
                        {
                            char k = char.Parse(m.Groups[1].Value);
                            char v = (char)int.Parse(m.Groups[2].Value);
                            translations.Add(k, v);
                            translationSeq.Add(k);
                            WriteDebug(string.Format("translation from {0} to {1}", (int)k, (int)v));
                        }
                        else if (commentRE.IsMatch(p))
                        {
                            // nada
                        }
                        else if (endRE.IsMatch(p))
                        {
                            if (id != null)
                            {
                                WriteDebug(string.Format("end image {0}", id));
                                BufferCell[,] cells = Host.UI.RawUI.NewBufferCellArray(lines.ToArray(), fg, bg);
                                images.Add(id, new Image(cells, transparent));
                                id = null;
                            }
                            else
                            {
                                WriteWarning("Unexpected #end token");
                            }
                        }
                        else
                        {
                            WriteWarning(string.Format("Unknown/incomlete token line: {0}", p));
                        }
                    }
                    else // not a # token
                    {
                        if (id != null)
                        {
                            string l = p;
                            foreach (char k in translationSeq)
                            {
                                l = l.Replace(k, translations[k]);
                            }
                            lines.Add(l);
                        }
                    }
                }
                catch (Exception e)
                {
                    WriteWarning(e.ToString());
                }
            }
        }
        protected override void EndProcessing()
        {
            WriteObject(images, false);
        }
    }


}
