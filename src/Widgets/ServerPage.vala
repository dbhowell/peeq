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

namespace Peeq.Widgets {
	public class ServerPage : Gtk.Grid {
		public signal void database_activated (Services.ServerConnection server, string database_name);
		public signal void busy (bool working);
		public signal void show_error ();

		public string icon_name { get; set; }
		public string group { get; set; }
		public string title { get; set; }
		public Services.ServerConnection server { get; set; }

		public Gtk.Grid control_box;
		private Gtk.InfoBar infobar_error;
    
    private DatabaseList database_list;
    private Gtk.Image server_img;
    private Gtk.ScrolledWindow scrolled;
		protected Gtk.Label server_label;
		private Gtk.Label version_label;
		private Gtk.Label error_label;
    private Gtk.Stack stack;
    private Gtk.StackSwitcher stack_switcher;

		public ServerPage.with_conninfo (Utils.ConnectionString connection_string) {
			server = new Services.ServerConnection.with_connection_string (connection_string);
			server.ready.connect (on_server_ready);
			server.error.connect (on_server_error);
			server.busy.connect (on_server_busy);

      group = connection_string.get("group");
      
      init_layout ();

			bind_property ("title", server_label, "label", GLib.BindingFlags.SYNC_CREATE);
			bind_property ("icon-name", server_img, "icon-name", GLib.BindingFlags.SYNC_CREATE);

			show_all ();
		}

    private void init_layout () {
      icon_name = "network-server";

      infobar_error = new Gtk.InfoBar ();
      infobar_error.message_type = Gtk.MessageType.ERROR;
      infobar_error.no_show_all = true;

      add (infobar_error);

      error_label = new Gtk.Label ("");
      var error_content = infobar_error.get_content_area ();

      error_content.add (error_label);

      margin = 24;
      orientation = Gtk.Orientation.VERTICAL;
      row_spacing = 24;

      title = server.server_name;

      server_img = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.DIALOG);
      server_img.pixel_size = 48;

      server_label = new Gtk.Label (null);
      server_label.ellipsize = Pango.EllipsizeMode.MIDDLE;
      server_label.get_style_context ().add_class ("h2");
      server_label.hexpand = true;
      server_label.xalign = 0;
      
      control_box = new Gtk.Grid ();
      control_box.column_spacing = 12;
      control_box.add (server_img);
      control_box.add (server_label);

      add (control_box);

      stack = new Gtk.Stack ();
      stack.vexpand = true;
      stack.margin_bottom = 24;
      stack.margin_top = 0;

      stack_switcher = new Gtk.StackSwitcher ();
      stack_switcher.homogeneous = true;
      stack_switcher.halign = Gtk.Align.CENTER;
      stack_switcher.stack = stack;

      add (stack_switcher);
      add (stack);

      init_databases ();
      init_info ();
      init_properties ();

      show_all ();
    }

    private void init_properties () {
      var frame = new Gtk.Frame (null);
      frame.add (new ServerProperties ());

      //stack.add_titled (frame, "Properties", _("Properties"));
    }

    private void init_info () {
      var frame = new Gtk.Frame (null);

      version_label = new Gtk.Label ("");
      frame.add (version_label);

      stack.add_titled (frame, "Info", _("Info"));
    }

    private void init_databases () {
      database_list = new DatabaseList ();
      database_list.row_activated.connect (on_database_activated);
      
      scrolled = new Gtk.ScrolledWindow (null, null);
      scrolled.expand = true;
      scrolled.add (database_list);

      var list_root = new Gtk.Grid ();
      list_root.attach (scrolled, 0, 0, 1, 1);

      var main_frame = new Gtk.Frame (null);
      main_frame.vexpand = true;
      main_frame.add (list_root);
      
      stack.add_titled (main_frame, "Databases", _("Databases"));
    }

		private void on_server_busy (bool working) {
			if (working) {
				//clear_error ();
			}

			busy (working);
		}

		private void on_server_ready (Gee.ArrayList<string>[] databases) {
			database_list.update_items (databases);
			version_label.label = server.version;
		}

		private void on_server_error (string message) {
      set_error (message);
		}

		private void on_database_activated (Gtk.ListBoxRow row) {
			DatabaseListItem item = (DatabaseListItem) row;

			database_activated (server, item.title);
		}

		public void start_connect () {
			clear_error ();
			server.start_connect ();
		}

		private void set_error (string message) {
			infobar_error.no_show_all = false;
      error_label.label = message;
      infobar_error.show_all ();
		}

		private void clear_error () {
			infobar_error.no_show_all = true;
      infobar_error.hide ();
		}
	}
}