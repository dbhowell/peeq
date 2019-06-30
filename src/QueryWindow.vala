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

using Granite.Widgets;

namespace Peeq { 
  public class QueryWindow : Gtk.Window {
    Widgets.QueryHeaderBar headerbar;
    Services.Connection connection;
    DynamicNotebook notebook;
    public string conninfo { get; set; }

    public QueryWindow (Peeq.Application application) {
      Object (
        application: application,
        icon_name: "com.github.dbhowell.peeq"
      );
    }

    public QueryWindow.with_conninfo (Peeq.Application application, string conninfo) {
      this.application = application;
      this.conninfo = conninfo;

      connection.conninfo = conninfo;
      connection.connect_start ();
    }

    construct {
      init_layout ();
    }

    void init_layout () {
      connection = new Services.Connection ();
      connection.busy.connect ((working) => {
        headerbar.working = working;
      });
      connection.ready.connect (() => {
        this.set_title (@"$(connection.host)/$(connection.name)");
      });
      
      notebook = new DynamicNotebook ();
      notebook.new_tab_requested.connect (on_new_tab_requested);
      notebook.tab_removed.connect (on_tab_removed);
      notebook.insert_tab (create_tab (null), 0);
      notebook.show ();

      add (notebook);

      headerbar = new Widgets.QueryHeaderBar ();
      add_accel_group (headerbar.accel_group);
      headerbar.execute_query.connect (on_execute_query);
      headerbar.open_file.connect (on_open_file);

      set_titlebar (headerbar);

      resize (800, 600);
    }     

    void on_new_tab_requested () {
      var tab = create_tab (null);

      notebook.insert_tab (tab, notebook.n_tabs);
      notebook.current = tab;
    }

    void on_tab_removed (Tab tab) {
      if (notebook.n_tabs == 0 && this.visible) {
        notebook.insert_tab (create_tab (null), 0);
      }
    }

    Tab create_tab (string? content) {
      var query_pane = new Widgets.QueryPaned.with_query_command (new Services.QueryCommand.with_connection (connection));
      if (content != null) {
        query_pane.set_text (content);
      }

      return 
        new Tab (
          @"Query $(notebook.n_tabs + 1)",
          null,
          query_pane
        );
    }

    void on_execute_query () {
      Widgets.QueryPaned item = (Widgets.QueryPaned) notebook.current.page;
      item.execute_query ();
    }

    void on_open_file () {
      Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog (
        "Open SQL file", this, Gtk.FileChooserAction.OPEN,
        "_Cancel",
        Gtk.ResponseType.CANCEL,
        "_Open",
        Gtk.ResponseType.ACCEPT);

      chooser.select_multiple = false;

      Gtk.FileFilter filter = new Gtk.FileFilter ();
      chooser.set_filter (filter);
      filter.add_mime_type ("application/sql");
      filter.add_mime_type ("text/sql");
      filter.add_mime_type ("text/x-sql");
      filter.add_mime_type ("text/plain");
      if (chooser.run () == Gtk.ResponseType.ACCEPT) {
        string sql_text;
        try {
        FileUtils.get_contents (chooser.get_filename (), out sql_text);
        var tab = create_tab (sql_text);
        notebook.insert_tab (tab, -1);
        notebook.current = tab;

        chooser.close ();
        } catch (GLib.FileError e) {
          print ("A FileError occurred.");
        }
      }

    }
  }
}