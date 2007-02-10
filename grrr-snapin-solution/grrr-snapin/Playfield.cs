using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
{
    public class Playfield
    {
        private int width, height;
        public int Width { get { return width; } set { width = value; } }
        public int Height { get { return height   ; } set { height = value; } }
    }

    [Cmdlet("Create", "Playfield")]
    public class CreatePlayfieldCmdlet : PSCmdlet
    {

    }


    [Cmdlet("Flush", "Playfield")]
    public class FlushPlayfieldCmdlet : PSCmdlet
    {

    }



    [Cmdlet("Clear", "Playfield")]
    public class ClearPlayfieldCmdlet : PSCmdlet
    {

    }
}
