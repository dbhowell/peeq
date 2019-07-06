/*
* Copyright (c) 2018 David Howell <david@dynamicmethods.com.au>
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

namespace Peeq {
	public enum PeeqWindowState {
		  NORMAL = 0,
		  MAXIMIZED = 1,
		  FULLSCREEN = 2
	}

	public class Services.Settings : Granite.Services.Settings {
		public string[] servers { get; set; }

		public int window_width { get; set; }
    public int window_height { get; set; }
    public PeeqWindowState window_state { get; set; }
    public int window_x { get; set; }
		public int window_y { get; set; }
		public string style_scheme { get; set; }
		public string font { get; set; }
		public string font_size { get; set; }
		public bool use_system_font { get; set; }

		public Settings ()  {
      base (Constants.PROJECT_NAME + ".settings");
		}
	}
}
