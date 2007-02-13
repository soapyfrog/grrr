using System.Diagnostics;
using System.Management.Automation;
using System.ComponentModel;

namespace Soapyfrog.Grrr.Meta
{
    [RunInstaller(true)]
    public class GrrrSnapin : PSSnapIn
    {
        public GrrrSnapin()
            : base()
        {
        }

        public override string Name
        {
            get
            {
                return "Soapyfrog.Grrr";
            }
        }

        public override string Vendor { get { return "soapyfrog.com"; } }

        public override string VendorResource
        {
            get
            {
                return "GrrrSnapin,Soapyfrog";
            }
        }

        public override string Description
        {
            get
            {
                return "This is a PowerShell snap-in that offers high performance graphics and animation in the console.";
            }
        }

        public override string DescriptionResource
        {
            get
            {
                return "GrrrSnapin,This is a PowerShell snap-in that high performance graphics and animation in the console.";
            }
        }

    }

}
