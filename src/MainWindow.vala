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
  public class MainWindow : Gtk.ApplicationWindow {
    public weak Peeq.Application app { get; construct; }

    private Widgets.MainHeaderBar headerbar;
    private Widgets.Welcome welcome;
    private Services.Settings settings;
    private Widgets.ServerList server_list;
    private Gtk.Stack content;
    private Gtk.ScrolledWindow scrolled_window;
    private Gee.ArrayList<QueryWindow> query_windows;
    private Widgets.ListFooter footer;
    private Gtk.Dialog? preferences_dialog = null;

    public MainWindow (Peeq.Application peeq_app) {
      Object (
        application: peeq_app,
        app: peeq_app,
        icon_name: Constants.PROJECT_NAME,
        title: _("Peeq")
      );
    }

    construct {
      settings = new Services.Settings ();
      query_windows = new Gee.ArrayList<QueryWindow> ();
      init_layout ();
    }

    private void init_layout () {
      headerbar = new Widgets.MainHeaderBar ();
      set_titlebar (headerbar);

      welcome = new Widgets.Welcome ();

      server_list = new Widgets.ServerList ();

      var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
      paned.width_request = 250;

      content = new Gtk.Stack ();
      content.hexpand = true;

      scrolled_window = new Gtk.ScrolledWindow (null, null);
      scrolled_window.expand = true;
      scrolled_window.hscrollbar_policy = Gtk.PolicyType.NEVER;

      scrolled_window.add (server_list);

      footer = new Widgets.ListFooter ();

      var sidebar = new Gtk.Grid ();
      sidebar.orientation = Gtk.Orientation.VERTICAL;
      sidebar.add (scrolled_window);
      sidebar.add (footer);

      paned.pack1 (sidebar, false, false);
      paned.pack2 (content, true, false);
      paned.set_position (240);

      var main_grid = new Gtk.Grid ();
      main_grid.add (paned);
      main_grid.show_all ();

      content.add (welcome);

      var root_grid = new Gtk.Grid ();
      root_grid.orientation = Gtk.Orientation.VERTICAL;
      root_grid.add (main_grid);

      add (root_grid);

      restore_settings ();

      connect_signals ();
      show_all ();
    }

    private void create_server_item (Utils.ConnectionString connection_string) {
      Widgets.ServerPage page = new Widgets.ServerPage.with_conninfo (connection_string);
      page.database_activated.connect (on_database_activated);
      page.busy.connect (on_page_busy);

      server_list.add_server_to_list (page);
    }

    private void connect_signals () {
      server_list.row_activated.connect (on_server_activated);
      server_list.row_selected.connect (on_server_selected);

      footer.add_server.connect (on_new_connection);
      footer.remove_server.connect (on_remove_connection);

      welcome.new_connection.connect (on_new_connection);

      headerbar.preferences_clicked.connect (action_preferences);

      Unix.signal_add (Posix.Signal.INT, quit_source_func, Priority.HIGH);
      Unix.signal_add (Posix.Signal.TERM, quit_source_func, Priority.HIGH);
    }

    public bool quit_source_func () {
      print("quit_source_func ()\n");
      save_settings ();
      destroy ();

      return false;
    }


    private void on_page_busy (bool working) {
      headerbar.working = working;
    }

    private void on_database_activated (Services.ServerConnection server, string database_name) {
      var conninfo = server.conninfo (database_name);

      foreach (var w in query_windows) {
        if (w.conninfo == conninfo) {
          w.present ();
          return;
        }
      }

      var window = new QueryWindow.with_conninfo (app, server.conninfo (database_name));
      window.destroy.connect (on_query_destroy);

      query_windows.add (window);
      window.show_all ();
    }

    private void on_query_destroy (Gtk.Widget widget) {
      QueryWindow window = (QueryWindow) widget;

      query_windows.remove (window);
    }

    private void on_server_activated (Gtk.ListBoxRow row) {
      var page = ((Widgets.ServerListItem)row).page;

      if (content.get_children ().find (page) == null) {
          content.add (page);
      }

      content.visible_child = page;
      page.start_connect ();
    }

    private void on_server_selected (Gtk.ListBoxRow? row) {
      if (row == null) {
        return;
      }

      var page = ((Widgets.ServerListItem)row).page;

      if (content.get_children ().find (page) == null) {
          content.add (page);
      }

      content.visible_child = page;
    }

    private void on_new_connection () {
      var dialog = new Dialogs.EditServer ((Gtk.Window) this.get_toplevel ());

      dialog.response.connect (on_edit_server_response);
      dialog.show_all ();
    }

    private void on_remove_connection () {
      var dialog = new Granite.MessageDialog.with_image_from_icon_name (
        "Remove Connection",
        "Are you sure you want to remove this connection?",
        "list-remove",
        Gtk.ButtonsType.CLOSE);

      dialog.transient_for = (Gtk.Window) this.get_toplevel ();
      dialog.add_button ("_Remove", Gtk.ResponseType.APPLY);

      dialog.response.connect ((source, response_id) => {
        switch (response_id) {
          case Gtk.ResponseType.CLOSE:
            dialog.destroy ();
            break;
          case Gtk.ResponseType.APPLY:
            remove_connection ();
            dialog.destroy ();
            break;
        }
      });

      dialog.show_all ();
    }

    private void remove_connection () {
      var item = (Widgets.ServerListItem) server_list.get_selected_row ();

      if (item != null) {
        content.remove (item.page);
        server_list.remove (item);

        save_settings ();
      } else {
        GLib.print ("null\n");
      }
    }

    private void on_edit_server_response (Gtk.Dialog source, int response_id) {
      if (response_id == Gtk.ResponseType.OK) {
        Dialogs.EditServer dialog = (Dialogs.EditServer) source;
        Utils.ConnectionString cs = new Utils.ConnectionString ();
        cs.set("server_name", dialog.server_name);
        cs.set("host", dialog.host);
        cs.set("port", dialog.port);
        cs.set("user", dialog.user);
        cs.set("password", dialog.pass);
        cs.set("maintenance_db", dialog.maintenance_db);

        create_server_item (cs);
        save_settings ();
      }

      source.destroy ();
    }

    private void restore_settings () {
      foreach (var s in settings.servers) {
        Utils.ConnectionString cs = Utils.ConnectionString.parse (s);

        if (cs.get("server_name") != null) {
          create_server_item (cs);
        }
      }

      default_width = settings.window_width;
      default_height = settings.window_height;

      switch (settings.window_state) {
        case PeeqWindowState.MAXIMIZED:
          maximize ();
          break;
        case PeeqWindowState.FULLSCREEN:
          fullscreen ();
          break;
        default:
          move (settings.window_x, settings.window_y);
          break;
      }
    }

    private void save_settings () {
      string[] servers = {};

      foreach (var item in server_list.get_children ()) {
        Widgets.ServerListItem server_item = (Widgets.ServerListItem) item;

        servers += @"$(server_item.page.server.connection_string)";
      }

      settings.servers = servers;

      var state = get_window ().get_state ();
      if (Gdk.WindowState.MAXIMIZED in state) {
          settings.window_state = PeeqWindowState.MAXIMIZED;
      } else if (Gdk.WindowState.FULLSCREEN in state) {
          settings.window_state = PeeqWindowState.FULLSCREEN;
      } else {
          settings.window_state = PeeqWindowState.NORMAL;
          // Save window size
          int width, height;
          get_size (out width, out height);

          settings.window_width = width;
          settings.window_height = height;
      }

      int x, y;
      get_position (out x, out y);
      settings.window_x = x;
      settings.window_y = y;

    }

    protected override bool delete_event (Gdk.EventAny event) {
      save_settings ();
      return false;
    }

    private void action_preferences () {
      if (preferences_dialog == null) {
          preferences_dialog = new Dialogs.Preferences (this);
          preferences_dialog.show_all ();

          preferences_dialog.destroy.connect (() => {
              preferences_dialog = null;
          });
      }

      preferences_dialog.present ();
    }
  }
}
