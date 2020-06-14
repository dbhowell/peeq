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
using Gtk;

namespace Peeq.Widgets {
	public class ServerList : Gtk.ListBox {
		public signal void show_no_items (bool show);

		construct {
			selection_mode = Gtk.SelectionMode.SINGLE;
			activate_on_single_click = false;

			bool show = (get_children ().length () > 0);
			show_no_items (!show);

			set_header_func (title_rows);
			set_sort_func ((row1, row2) => {
				ServerListItem item1 = (ServerListItem)row1;
				ServerListItem item2 = (ServerListItem)row2;

				if (item1.group != item2.group) {
					return item1.group > item2.group ? 1 : -1;
				}

				return item1.title > item2.title ? 1 : -1;
			});
		}

		public void add_server_to_list (ServerPage page) {
			ServerListItem item = new ServerListItem.with_server (page);

			add (item);
			show_all ();
		}

		private Gtk.Label header_label (string group) {
			var label = new Gtk.Label (group);
			label.hexpand = true;
			label.xalign = 0;
			label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
			
			return label;
		}

		private void title_rows (ListBoxRow row, ListBoxRow? before) {
			ServerListItem server = (ServerListItem) row;
			
			if (before != null) {
				ServerListItem server_before = (ServerListItem) before;

				if (server.group != server_before.group) {
					row.set_header (header_label (server.group));
				} else {
					row.set_header (null);
				}
			} else {
				row.set_header (header_label (server.group));
			}
		}
	}
}