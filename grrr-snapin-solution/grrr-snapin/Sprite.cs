using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
{
    public class Sprite
    {
        private int width, height;
        public int Width { get { return width; } set { width = value; } }
        public int Height { get { return height; } set { height = value; } }
    }

    [Cmdlet("Create", "Sprite")]
    public class CreateSpriteCmdlet : PSCmdlet
    {

    }


    [Cmdlet("Draw", "Sprite")]
    public class DrawSpriteCmdlet : PSCmdlet
    {
    }


    // TODO can add handlers, hit testing and so on in here too.

}
