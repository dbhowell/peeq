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

namespace Peeq.Dialogs {
	public class EditServer : Gtk.Dialog {
		private Gtk.Label label_name;
		private Gtk.Label label_host;
		private Gtk.Label label_port;
		private Gtk.Label label_user;
		private Gtk.Label label_pass;
		private Gtk.Label label_maintenance_db;
		private Gtk.Label label_colour;
		private Gtk.Label label_group;

		private Gtk.Entry entry_name;
		private Gtk.Entry entry_host;
		private Gtk.Entry entry_port;
		private Gtk.Entry entry_user;
		private Gtk.Entry entry_pass;
		private Gtk.Entry entry_maintenance_db;
		private Gtk.ComboBoxText entry_group;
		private Gtk.ColorButton color_button;

		private Gtk.Button button_save;
		private Gtk.Button button_cancel;

		string[] groups;

		public string server_name {
			get { return entry_name.get_text (); }
			set { entry_name.set_text (value); }
		}

		public string group {
			get { return ((Gtk.Entry)entry_group.get_child ()).get_text (); }
			set { ((Gtk.Entry)entry_group.get_child ()).set_text (value); }
		}

		public string host {
			get { return entry_host.get_text (); }
			set { entry_host.set_text (value); }
		}

		public string port {
			get { return entry_port.get_text (); }
			set { entry_port.set_text (value); }
		}

		public string user {
			get { return entry_user.get_text (); }
			set { entry_user.set_text (value); }
		}

		public string pass {
			get { return entry_pass.get_text (); }
			set { entry_pass.set_text (value); }
		}

		public string maintenance_db {
			get { return entry_maintenance_db.get_text (); }
			set { entry_maintenance_db.set_text (value); }
		}

		public EditServer (Gtk.Window parent, string[]? groups) {
			Object (
				transient_for: parent,
				title: _("Edit Server")
			);

			this.groups = groups;
			init_layout ();
		}

		private void init_layout () {
			Gtk.Grid grid = new Gtk.Grid ();
			grid.margin = 24;
      grid.column_spacing = 12;
			grid.row_spacing = 12;

			label_group = new Gtk.Label (_("Group"));
			label_name = new Gtk.Label (_("Name"));
			label_host = new Gtk.Label (_("Host"));
			label_port = new Gtk.Label (_("Port"));
			label_user = new Gtk.Label (_("Username"));
			label_pass = new Gtk.Label (_("Password"));
			label_maintenance_db = new Gtk.Label (_("Maintenance Database"));
			label_colour = new Gtk.Label (_("Colour"));

			label_group.halign = Gtk.Align.END;
			label_name.halign = Gtk.Align.END;
			label_host.halign = Gtk.Align.END;
			label_port.halign = Gtk.Align.END;
			label_user.halign = Gtk.Align.END;
			label_pass.halign = Gtk.Align.END;
			label_maintenance_db.halign = Gtk.Align.END;
			label_colour.halign = Gtk.Align.END;

			label_group.xalign = 1;
			label_name.xalign = 1;
			label_host.xalign = 1;
			label_port.xalign = 1;
			label_user.xalign = 1;
			label_pass.xalign = 1;
			label_maintenance_db.xalign = 1;
			label_colour.xalign = 1;

/*
			Gtk.ListStore liststore = new Gtk.ListStore (1, typeof (string));

			for (int i = 0; i < groups.length; i++){
				Gtk.TreeIter iter;
				liststore.append (out iter);
				liststore.set (iter, 0, groups[i]);
			}

			entry_group = new Gtk.ComboBox.with_model_and_entry (liststore);
*/
			entry_group = new Gtk.ComboBoxText.with_entry ();
			for (int i = 0; i < groups.length; i++){
				entry_group.append_text (groups[i]);
			}

			((Gtk.Entry)entry_group.get_child ()).set_text ("Servers");

/*
			Gtk.CellRendererText cell = new Gtk.CellRendererText ();
			entry_group.pack_start (cell, false);
			entry_group.set_entry_text_column (0);
			entry_group.set_active (0);
*/		
			entry_name = new Gtk.Entry ();
			entry_host = new Gtk.Entry ();
			entry_port = new Gtk.Entry ();
			entry_user = new Gtk.Entry ();
			entry_pass = new Gtk.Entry ();
			entry_maintenance_db = new Gtk.Entry ();
			color_button = new Gtk.ColorButton ();

			entry_pass.set_visibility (false);
			entry_port.set_text ("5432");
			entry_maintenance_db.set_text ("postgres");

			button_save = new Gtk.Button ();
			button_cancel = new Gtk.Button ();

			grid.attach (label_group, 0, 0, 1, 1);
			grid.attach (entry_group, 1, 0, 1, 1);
			
			grid.attach (label_name, 0, 1, 1, 1);
			grid.attach (entry_name, 1, 1, 1, 1);

			grid.attach (label_host, 0, 2, 1, 1);
			grid.attach (entry_host, 1, 2, 1, 1);
			
			grid.attach (label_user, 0, 3, 1, 1);
			grid.attach (entry_user, 1, 3, 1, 1);
			
			grid.attach (label_pass, 0, 4, 1, 1);
			grid.attach (entry_pass, 1, 4, 1, 1);
			
			grid.attach (label_port, 0, 5, 1, 1);
			grid.attach (entry_port, 1, 5, 1, 1);
			
			grid.attach (label_maintenance_db, 0, 6, 1, 1);
			grid.attach (entry_maintenance_db, 1, 6, 1, 1);

			grid.attach (label_colour, 0, 7, 1, 1);
			grid.attach (color_button, 1, 7, 1, 1);

			get_content_area ().add (grid);

			// add_button ("_Test Connection", Gtk.ResponseType.HELP);
			add_button ("_Close", Gtk.ResponseType.CLOSE);
			add_button ("_Save", Gtk.ResponseType.OK);

			response.connect (on_response);
			show_all ();
			set_modal (true);
		}

		private void on_response (Gtk.Dialog source, int response_id) {
			if (response_id == Gtk.ResponseType.HELP) {
				test_connection ();
			}
		}

		private void test_connection () {

		}

		public void set_values (Utils.ConnectionString connection_string) {
			((Gtk.Entry)entry_group.get_child ()).set_text (connection_string.get("group"));
			entry_name.text = connection_string.get("server_name");
			entry_host.text = connection_string.get("host");
			entry_port.text = connection_string.get("port");
			entry_user.text = connection_string.get("user");
			entry_pass.text = connection_string.get("password");
			entry_maintenance_db.text = connection_string.get("maintenance_db");
		}
	}
}