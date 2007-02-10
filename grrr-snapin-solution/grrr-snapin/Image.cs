using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
{
    public class Image
    {
        private int width, height;
        public int Width { get { return width; } set { width = value; } }
        public int Height { get { return height; } set { height = value; } }
    }

    [Cmdlet("Create", "Image")]
    public class CreateImageCmdlet : PSCmdlet
    {

    }


    [Cmdlet("Draw", "Image")]
    public class DrawImageCmdlet : PSCmdlet
    {

    }


    /// <summary>
    /// 
    /// </summary>
    [Cmdlet("Get", "Image")]
    public class GetImageCmdlet : PSCmdlet
    {

    }

    // TODO: ScanImage
}
