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
	public class ServerConnection : GLib.Object {
		public signal void ready (string[] databases);
		public signal void error (string message);
		public signal void busy (bool working);

		public bool connected { get; set; }
		public string version { get; set; }
		public Utils.ConnectionString connection_string { get; set; }
		public unowned string server_name { owned get {
			return connection_string.get("server_name");
			}
		}

		private Connection connection;
		private QueryCommand query_command;
		private QueryCommand version_command;

		public ServerConnection () {
			base ();

			connection = new Connection ();
			connection.ready.connect (on_connection_ready);
			connection.error.connect (on_connection_error);
			connection.busy.connect (on_connection_busy);
			
			query_command = new QueryCommand.with_connection (connection);
			query_command.complete.connect (on_query_complete);
			query_command.error.connect (on_query_error);
		
			version_command = new QueryCommand.with_connection (connection);
			version_command.complete.connect (on_version_complete);
		}

		public ServerConnection.with_connection_string (Utils.ConnectionString connection_string) {
			base ();

			this.connection_string = connection_string;

			connection = new Connection ();
			connection.ready.connect (on_connection_ready);
			connection.error.connect (on_connection_error);
			connection.busy.connect (on_connection_busy);
			
			query_command = new QueryCommand.with_connection (connection);
			query_command.complete.connect (on_query_complete);
			query_command.error.connect (on_query_error);
		
			version_command = new QueryCommand.with_connection (connection);
			version_command.complete.connect (on_version_complete);
		}

		public string conninfo (string database) {
			return connection_string.get_conninfo (database);
		}

		public void start_connect () {
			if (connected) {
				on_connection_ready ();
			} else {
				connection.conninfo = conninfo (connection_string.get("maintenance_db"));
				connection.connect_start ();
			}
		}

		private void on_connection_busy (bool working) {
			busy (working);
		}

		private void on_connection_ready () {
			version_command.execute ("SELECT version();");
		}

		private void on_connection_error (string message) {
			error (message);
		}

		private void on_version_complete (QueryResult result) {
			version = result.rows[0].values[0];
			query_command.execute ("SELECT datname AS db_name, pg_size_pretty(pg_database_size(datname)) AS db_size FROM pg_catalog.pg_database ORDER BY db_name");
		}

		private void on_query_complete (QueryResult result) {
			string[] databases = {};

			foreach (var r in result.rows) {
				databases += r.values[0];
			}

			connected = true;
			ready (databases);
		}

		private void on_query_error (string message) {
			print ("on_query_error ()\n");
			print (@"$(message)\n");
		}
	}
}