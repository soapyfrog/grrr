using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace Soapyfrog.Grrr
{
    /// <summary>
    /// A play field is rectangular viewport in the visible
    /// part of the console (usually) with a backing buffer
    ///  held in a BufferCell array in memory.
    ///
    /// Drawing is always done in the backing buffer, then
    /// flushed to the visual buffer to give the illusion
    /// of instant rendering.
    ///
    /// See clear-playfield, flush-playfield, etc.
    ///
    /// The console should be set up appropriately before
    /// calling this (ie number of rows/cols, windows size
    /// and position).
    /// </summary>
    public class Playfield
    {
        private Size size;
        private Coordinates coord;
        private ConsoleColor background;

        private BufferCell[,] buffer, erasebuffer;
        private PSHostRawUserInterface ui;

        public int Width { get { return size.Width; } }
        public int Height { get { return size.Height; } }
        public int X { get { return coord.X; } }
        public int Y { get { return coord.Y; } }
        public ConsoleColor Background { get { return background; } }


        public Playfield(PSHostRawUserInterface ui, int w, int h, int x, int y, ConsoleColor c)
        {
            this.ui = ui;
            coord = new Coordinates(x, y);
            size = new Size(w, h);
            background = c;
            erasebuffer = ui.NewBufferCellArray(size, new BufferCell(' ', ConsoleColor.White, background, BufferCellType.Complete));
            buffer = (BufferCell[,])erasebuffer.Clone();
        }

        public void Flush()
        {
            ui.SetBufferContents(coord, buffer);
        }

        public void Clear()
        {
            Array.Copy(erasebuffer, buffer, buffer.Length);
        }

    }

    [Cmdlet("Create", "Playfield")]
    public class CreatePlayfieldCmdlet : PSCmdlet
    {
        private int x, y, w, h;
        private ConsoleColor c;

        [Parameter(Position = 0)]
        [ValidateRange(1, 1000)]
        public int Width { set { w = value; } }
        [Parameter(Position = 1)]
        [ValidateRange(1, 1000)]
        public int Height { set { h = value; } }
        [Parameter(Position = 2)]
        [ValidateRange(0, 1000)]
        public int X { set { x = value; } }
        [Parameter(Position = 3)]
        [ValidateRange(0, 1000)]
        public int Y { set { y = value; } }
        [Parameter(Position = 4)]
        public ConsoleColor Background { set { c = value; } }

        /// <summary>
        /// Put out the created Playfield
        /// </summary>
        protected override void EndProcessing()
        {
            Playfield pf = new Playfield(Host.UI.RawUI, w, h, x, y, c);
            WriteObject(pf, false);
            base.EndProcessing();
        }

    }


    [Cmdlet("Flush", "Playfield")]
    public class FlushPlayfieldCmdlet : PSCmdlet
    {
        private Playfield pf;

        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty]
        public Playfield Playfield { set { pf = value; } }

        protected override void EndProcessing()
        {
            pf.Flush();
            base.EndProcessing();
        }

    }



    [Cmdlet("Clear", "Playfield")]
    public class ClearPlayfieldCmdlet : PSCmdlet
    {
        private Playfield pf;

        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty]
        public Playfield Playfield { set { pf = value; } }

        protected override void EndProcessing()
        {
            pf.Clear();
            base.EndProcessing();
        }
    }
}
