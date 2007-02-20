using System;
using System.Collections.Generic;
using System.Text;

namespace Soapyfrog.Grrr.Core
{
    public class Banner
    {
        private static Dictionary<char, string[]> cmap = new Dictionary<char, string[]>();
        private static void parsemap(string[] reslines, ref int index, string codes)
        {
            string comment = reslines[index++]; // skip comment
            int offset = 0; // into the line
            foreach (char code in codes.ToCharArray())
            {
                string[] charlines = new string[5]; // each char is 5 lines deep
                for (int n = 0; n < 5; n++)
                {
                    // extract the part for that char
                    string t = reslines[index + n];
                    charlines[n] = t.Substring(offset, 6);
                }
                cmap[code] = charlines; // stick the 5 line array into the map
                offset += 6; // next char code
            }
            index += 5;
        }
        static Banner()
        {
            string[] reslines = BannerResource.charmap.Split('\n');
            int index = 0;
            parsemap(reslines, ref index, "0123456789");
            parsemap(reslines, ref index, "abcdefghij");
            parsemap(reslines, ref index, "klmnopqrst");
            parsemap(reslines, ref index, "uvwxyz");
            parsemap(reslines, ref index, "!\"#$%&'()*");
            parsemap(reslines, ref index, "+,-./:;<=>");
            parsemap(reslines, ref index, "?@");
            parsemap(reslines, ref index, "{|}~");
            parsemap(reslines, ref index, "[\\]");
            parsemap(reslines, ref index, "^_`");
            parsemap(reslines, ref index, new string(new char[] { (char)0xa3, (char)0xa2, (char)0x20ac, (char)0xa5 }));
            parsemap(reslines, ref index, " ");
        }


        public static string[] Render(string text)
        {
            return Render(text, (char)0x2588, ' ');
        }

        public static string[] Render(string text, char fg,char bg)
        {
            // now write out the text
            string[] output = new string[] { "", "", "", "", "" }; // eugh :-)
            text = text.ToLower();
            foreach (char c in text.ToCharArray())
            {
                string[] clines = cmap[c];
                if (clines == null) { clines = cmap['?']; }
                for (int n = 0; n < 5; n++) output[n] += clines[n];
            }
            for (int n = 0; n < 5; n++)
            {
                // apply foreground and background
                // first move the existing chars out the way in case of clashes
                output[n] = output[n].Replace('@', (char)0xf001).Replace('.', (char)0xf002);
                output[n] = output[n].Replace((char)0xf001, fg).Replace((char)0xf002, bg);
            }
            return output;
        }
    }





}
