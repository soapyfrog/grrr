using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;

namespace Soapyfrog.Grrr.Core
{

    /// <summary>
    /// Delta tuple
    /// </summary>
    internal class Step
    {
        internal readonly int num;
        internal readonly Delta delta;

        internal Step(int num, int dx, int dy)
        {
            delta = new Delta(dx, dy, 0);
            this.num = num;
        }
    }

    /// <summary>
    /// Motion path is a string of half logo, half vi motion commands that are
    /// executed by a Sprite in a loop.
    /// 
    /// Commands space-seperated and of the form:
    /// 
    ///    [ repeat count ]  compass direction [ distance ] 
    /// 
    /// Numbers in square brackets are optional and default to one.
    /// 
    /// For example, to move 3 cells east 5 times, then jump 15 cells west 
    /// (returning to the beginning):
    /// 
    ///     5E3 W15
    /// 
    /// A position can be held with H, eg:
    /// 
    ///     10N 5H 10S
    /// 
    /// would move up 10 times, wait 5 then come back.
    /// </summary>
    public class MotionPath 
    {

        // assorted regexes
        private readonly static Regex splitRegex = new Regex(@"\s+");
        private readonly static Regex cmdRegex = new Regex(@"(\d+)?([a-z]+)(\d+)?", RegexOptions.IgnoreCase);

        // steps
        private readonly List<Step> steps = new List<Step>();
        private readonly int repeatcount;

        private readonly List<string> errors = new List<string>();


        protected internal MotionPath(string spec, int repeatcount)
        {
            if (repeatcount < 0) repeatcount = 0;
            this.repeatcount = repeatcount;
            // parse the path here
            string[] tokens = splitRegex.Split(spec);

            foreach (string token in tokens)
            {
                Match m = cmdRegex.Match(token);
                int repeat = 1; 
                int distance = 1;
                if (m.Groups[1].Length > 0) repeat = int.Parse(m.Groups[1].Value);
                if (m.Groups[3].Length > 0) distance = int.Parse(m.Groups[3].Value);
                string cmd = m.Groups[2].Value.ToUpper();
                switch (cmd)
                {
                    // compass directions, [repeat] direction [distance] 
                    case "NE": { steps.Add(new Step(repeat, distance, -distance)); break; }
                    case "SE": { steps.Add(new Step(repeat, distance, distance)); break; }
                    case "SW": { steps.Add(new Step(repeat, -distance, distance)); break; }
                    case "NW": { steps.Add(new Step(repeat, -distance, -distance)); break; }
                    case "N": { steps.Add(new Step(repeat, 0, -distance)); break; }
                    case "S": { steps.Add(new Step(repeat, 0, distance)); break; }
                    case "E": { steps.Add(new Step(repeat, distance, 0)); break; }
                    case "W": { steps.Add(new Step(repeat, -distance, 0)); break; }
                    // hold still, [repeat] H
                    case "H": { steps.Add(new Step(repeat, 0, 0)); break; } // H is hold
                    default: { errors.Add(string.Format("Unknown cmd '{0}'", token)); break;  }
                }
            }

        }


        internal List<string> Errors { get { return errors; } }
        internal List<Step> Deltas { get { return steps; } }

        #region IEnumerable<Delta> Members

        /// <summary>
        /// Return Deltas from the set of steps, potentially infinitely.
        /// </summary>
        /// <returns></returns>
        public IEnumerator<Delta> GetDeltaEnumerator()
        {
            bool infinite = (repeatcount == 0);
            for (int i=0;infinite || i<repeatcount ;i+=1 )
            {
                foreach (Step s in steps)
                {
                    for (int rep = 0; rep < s.num; rep++)
                    {
                        yield return s.delta;
                    }
                }
            }
        }

        #endregion

    }
}
