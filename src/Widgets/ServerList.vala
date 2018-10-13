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

using Peeq.Services;

namespace Peeq.Widgets {
	public class ServerList : Gtk.ListBox {
		public signal void show_no_items (bool show);

		construct {
			selection_mode = Gtk.SelectionMode.SINGLE;
			activate_on_single_click = false;

			bool show = (get_children ().length () > 0);
			show_no_items (!show);

		}

		public void add_server_to_list (ServerPage page) {
			ServerListItem item = new ServerListItem.with_server (page);

			add (item);
			show_all ();
		}
	}
}