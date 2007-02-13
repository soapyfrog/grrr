using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;

namespace Soapyfrog.Grrr
{

    /// <summary>
    /// Delta tuple
    /// </summary>
    internal class Delta
    {
        readonly internal int num, dx, dy;
        internal Delta(int num, int dx, int dy)
        {
            this.dx = dx; this.dy = dy; this.num = num;
        }
    }

    public class MotionPath
    {

        // assorted regexes
        private readonly static Regex splitRegex = new Regex(@"\s+");
        private readonly static Regex cmdRegex = new Regex(@"(\d+)?([a-z]+)(\d+)?", RegexOptions.IgnoreCase);

        // deltas
        private readonly List<Delta> deltas = new List<Delta>();
        private int nextDelta = 0;
        private int nextIter = 0;

        private readonly List<string> errors = new List<string>();

        public /*protected internal*/ MotionPath(string spec)
        {
            // parse the path here
            string[] tokens = splitRegex.Split(spec);

            foreach (string token in tokens)
            {
                Match m = cmdRegex.Match(token);
                int num = 1; int dist = 1;
                if (m.Groups[1].Length > 0) num = int.Parse(m.Groups[1].Value);
                if (m.Groups[3].Length > 0) num = int.Parse(m.Groups[3].Value);
                string cmd = m.Groups[2].Value.ToUpper();
                switch (cmd)
                {
                    case "NE": { deltas.Add(new Delta(num, dist, -dist)); break; }
                    case "SE": { deltas.Add(new Delta(num, dist, dist)); break; }
                    case "SW": { deltas.Add(new Delta(num, -dist, dist)); break; }
                    case "NW": { deltas.Add(new Delta(num, -dist, -dist)); break; }
                    case "N": { deltas.Add(new Delta(num, 0, -dist)); break; }
                    case "S": { deltas.Add(new Delta(num, 0, dist)); break; }
                    case "E": { deltas.Add(new Delta(num, dist, 0)); break; }
                    case "W": { deltas.Add(new Delta(num, -dist, 0)); break; }
                    case "H": { deltas.Add(new Delta(num, 0, 0)); break; } // H is hold
                    default: { errors.Add(string.Format("Unknown cmd '{0}'", token)); break;  }
                }
            }

        }

        public void Step(Sprite s) {
            Delta d = deltas[nextDelta];
            s.X += d.dx;
            s.Y += d.dy;
            if (++nextIter == d.num)
            {
                nextIter = 0;
                nextDelta = (nextDelta + 1) % deltas.Count;
            }
        }

        public List<string> Errors { get { return errors; } }

    }
}
