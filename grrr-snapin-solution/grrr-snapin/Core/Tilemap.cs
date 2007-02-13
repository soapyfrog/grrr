using System;
using System.Collections;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr.Core
{
    public class Tilemap
    {
        private int tileWidth, tileHeight;
        private int mapWidth, mapHeight;
        private string[] lines;
        private IDictionary imagemap;

        public IDictionary ImageMap { get { return imagemap; } }
        public string[] Lines { get { return lines; } }
        public int TileWidth { get { return tileWidth; } }
        public int TileHeight { get { return tileHeight; } }
        public int MapWidth { get { return mapWidth; } }
        public int MapHeight { get { return mapHeight; } }

        protected internal Tilemap(string[] lines, IDictionary imagemap)
        {
            this.lines = lines;
            this.imagemap = imagemap;
            foreach (object o in imagemap)
            {
                DictionaryEntry de = (DictionaryEntry)o;
                Image first = (Image)de.Value;
                tileWidth = first.Width;
                tileHeight = first.Height;
                mapWidth = lines[0].Length;
                mapHeight = lines.Length;
                break;
            }

        }
    }


}
