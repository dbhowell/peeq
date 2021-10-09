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

namespace Peeq.Services {
	public class ConnectionManager : Gtk.Object {
		private Gee.HashMap<string, Gee.ArrayList<Connection>> connections;

		public Connection get (string conninfo) {
			Gee.ArrayList<Connection> items;

			if (has_pool (conninfo)) {
				items = connections.entries[conninfo];
			} else {
				items = new Gee.ArrayList<Connection> ();

				connections.entries[conninfo] = items;
			}


		}

		private bool has_pool (conninfo) {
			return (connection.has_entry (conninfo));
		}

		private Connection create_connection (conninfo) {
			var c = new Connection.with_conninfo (conninfo);

			return c;
		}

		private Connection? available_connection (Gee.ArrayList<Connection> items) {
			foreach (var i in items) {
				if (!i.working) {
					return i;
				}
			}
		}
	}
}
