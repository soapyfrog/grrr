using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
{
    public class Tilemap
    {
        private int width, height;
        public int Width { get { return width; } set { width = value; } }
        public int Height { get { return height; } set { height = value; } }
    }

    [Cmdlet("Create", "Tilemap")]
    public class CreateTilemapCmdlet : PSCmdlet
    {

    }


    [Cmdlet("Draw", "Tilemap")]
    public class DrawTilemapCmdlet : PSCmdlet
    {
    }


    /// <summary>
    /// Get a Tilemap from an input stream (eg a file).
    /// </summary>
    [Cmdlet("Get", "Tilemap")]
    public class GetTilemapCmdlet : PSCmdlet
    {

    }

    // TODO can add handlers, hit testing and so on in here too.

}
