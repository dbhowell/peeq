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

namespace Peeq.Utils {
	public class ConnectionString {
		public Gee.HashMap<string, string> keys;
		private string[] allowed = {
			"host",
			"hostaddr",
			"port",
			"user",
			"password"
		};

		public string get (string key) {
			return keys.get (key);
		}

		public void set (string key, string value) {
			keys.set (key, value);
		}

		public ConnectionString () {
			keys = new Gee.HashMap<string, string>();
		}

		public string get_conninfo (string dbname) {
			string s = "";
			foreach (var i in keys.entries) {
				if (i.key in allowed) {
					string v = escape_value (i.value);
					s = s.concat (i.key, "=", @"'$(v)'", " ");
				}
			}

			s = s.concat ("dbname", "=", @"'$(dbname)' ");

			return s;
		}

		public static ConnectionString parse (string conninfo) {
			ConnectionString result = new ConnectionString ();
			string[] key_values = conninfo.split ("' ");

			GLib.Regex r = new GLib.Regex("^(?P<key>[a-z_]+)='(?P<value>.*)$");
			
			foreach (var kv in key_values) {
				if (kv.length > 0) {
					GLib.MatchInfo info;

					r.match(kv, 0, out info);
					string k = info.fetch_named ("key");
					string v = unescape_value (info.fetch_named ("value"));

					result.keys.set (k, v);
				}
			}

			return result;
		}

		public string to_string () {
			string s = "";
			foreach (var i in keys.entries) {
				string v = escape_value (i.value);
				s = s.concat (i.key, "=", @"'$(v)'", " ");
			}

			return s;
		}

		private static string escape_value (string value) {
			return value.replace ("\\", "\\\\").replace ("'", "\\'");
		}

		private static string unescape_value (string value) {
			return value.replace ("\\'", "'").replace ("\\\\", "\\");
		}
	}
}