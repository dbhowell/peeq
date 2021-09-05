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
using Peeq.Widgets;
using Peeq.Services;

namespace Peeq { 
  public class QueryWindow : Gtk.Window {
    Widgets.QueryHeaderBar headerbar;
    Services.Connection connection;
    DynamicNotebook notebook;
    
    Services.QueryCommand tables_command;
    Services.QueryCommand views_command;
    Services.QueryCommand functions_command;
    Services.QueryCommand columns_command;
    Schemas.SchemaCommand schemas_command;
    Schemas.ExtensionCommand extensions_command;
    Schemas.SequenceCommand sequences_command;

    Granite.Widgets.SourceList.ExpandableItem database_item;
    Granite.Widgets.SourceList.ExpandableItem extensions_category = new Granite.Widgets.SourceList.ExpandableItem ("Extensions");
    Granite.Widgets.SourceList.ExpandableItem functions_category = new Granite.Widgets.SourceList.ExpandableItem ("Functions");
    Granite.Widgets.SourceList.ExpandableItem schemas_category = new Granite.Widgets.SourceList.ExpandableItem ("Schemas");
    Granite.Widgets.SourceList.ExpandableItem sequences_category = new Granite.Widgets.SourceList.ExpandableItem ("Sequences");
    Granite.Widgets.SourceList.ExpandableItem tables_category = new Granite.Widgets.SourceList.ExpandableItem ("Tables");
    Granite.Widgets.SourceList.ExpandableItem views_category = new Granite.Widgets.SourceList.ExpandableItem ("Views");

    Widgets.PostgresListItem selected_item;

    public string conninfo { get; set; }

    public QueryWindow (Peeq.Application application) {
      Object (
        application: application,
        icon_name: "com.github.dbhowell.peeq"
      );
    }

    ~QueryWindow () {
      connection.cancel ();
    }

    public QueryWindow.with_conninfo (Peeq.Application application, string conninfo) {
      this.application = application;
      this.conninfo = conninfo;

      connection = new Services.Connection ();
      connection.conninfo = conninfo;
      
      init_layout ();

      connection.connect_start ();
    }

    construct {
      
    }

    void init_layout () {
      functions_command = new Services.QueryCommand.with_connection (connection);
      tables_command = new Services.QueryCommand.with_connection (connection);
      views_command = new Services.QueryCommand.with_connection (connection);
      columns_command = new Services.QueryCommand.with_connection (connection);
      schemas_command = new Schemas.SchemaCommand.with_connection (connection);
      extensions_command = new Schemas.ExtensionCommand.with_connection (connection);
      sequences_command = new Schemas.SequenceCommand.with_connection (connection);
      
      connection.busy.connect (on_busy);
      connection.ready.connect (() => {
        this.set_title (@"$(connection.host)/$(connection.name)");
        
        extensions_command.run ();
      });

      this.tables_command.error.connect ((message) => {
        print(@"$(message)\n");
      });

      this.extensions_command.complete.connect(this.on_extensions_complete);
      this.sequences_command.complete.connect(this.on_sequences_complete);
      this.schemas_command.complete.connect(this.on_schemas_complete);
      this.tables_command.complete.connect (this.on_tables_complete);
      this.views_command.complete.connect (this.on_views_complete);
      this.functions_command.complete.connect (this.on_functions_complete);
      this.columns_command.complete.connect (this.on_columns_complete);
      
      headerbar = new Widgets.QueryHeaderBar ();
      add_accel_group (headerbar.accel_group);
      headerbar.execute_query.connect (on_execute_query);
      headerbar.cancel_query.connect (on_cancel_query);
      headerbar.open_file.connect (on_open_file);
      headerbar.save_file.connect (on_save_file);

      set_titlebar (headerbar);

      notebook = new DynamicNotebook ();
      notebook.new_tab_requested.connect (on_new_tab_requested);
      notebook.tab_removed.connect (on_tab_removed);
      notebook.tab_switched.connect (on_tab_switched);
      notebook.insert_tab (create_tab (null), 0);
      notebook.show ();

      var listbox = new Gtk.ListBox ();
      listbox.activate_on_single_click = true;
      listbox.expand = true;
      listbox.selection_mode = Gtk.SelectionMode.SINGLE;

      var scrolledwindow = new Gtk.ScrolledWindow (null, null);
      scrolledwindow.add (listbox);

      var source_list = new Granite.Widgets.SourceList ();
      source_list.set_size_request (240, -1);

      source_list.item_selected.connect ((item) => {
        selected_item = item as Widgets.PostgresListItem;
        if (selected_item == null) {
          return;
        }

        if (selected_item.postgres_object == PostgresObject.TABLE) {
          columns_command.execute (@"SELECT column_name, data_type FROM information_schema.columns WHERE table_schema='$(selected_item.schema)' AND table_name='$(selected_item.name)' ORDER BY column_name");
        }

        if (selected_item.postgres_object == PostgresObject.VIEW) {
          columns_command.execute (@"SELECT column_name, data_type FROM information_schema.columns WHERE table_schema='$(selected_item.schema)' AND table_name='$(selected_item.name)' ORDER BY column_name");
        }

        if (
          selected_item.postgres_object == PostgresObject.FUNCTION ||
          selected_item.postgres_object == PostgresObject.VIEW
        ) {
          var tab = create_tab (selected_item.definition);
          notebook.insert_tab (tab, -1);
          notebook.current = tab;
        }
      });

      database_item = new Granite.Widgets.SourceList.ExpandableItem ("Database");
      
      source_list.root.add(database_item);
      
      tables_category.activatable = new ThemedIcon ("view-refresh-symbolic");
      tables_category.action_activated.connect (() => {
        tables_command.execute (Services.TABLES_SQL);
      });

      database_item.add (extensions_category);
      database_item.add (schemas_category);
      database_item.add (functions_category);
      database_item.add (sequences_category);
      database_item.add (tables_category);
      database_item.add (views_category);

      var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
      paned.pack1 (source_list, false, true);
      paned.pack2 (notebook, true, false);

      add (paned);

      resize (800, 600);
      database_item.expanded = true;
    }     

    void on_busy (bool working) {
      headerbar.working = working || active_pane_working ();
    }

    bool active_pane_working () {
      var pane = get_active_pane ();
    
      if (pane != null) {
        return pane.query_command.connection.working;
      }

      return false;
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

    Widgets.QueryPaned get_pane (Tab tab) {
      return tab.page as Widgets.QueryPaned;
    }

    void on_tab_switched (Tab? old_tab, Tab new_tab) {
      Widgets.QueryPaned pane = new_tab.page as Widgets.QueryPaned;

      if (old_tab != null) {
        get_pane (old_tab).query_command.connection.busy.disconnect (on_busy);
      }

      get_pane (new_tab).query_command.connection.busy.connect (on_busy);
      headerbar.working = pane.query_command.connection.working;
    }

    Widgets.QueryPaned get_active_pane () {
      return notebook.current.page as Widgets.QueryPaned;
    }

    Tab create_tab (string? content) {
      var query_pane = new Widgets.QueryPaned.with_conninfo (this.conninfo);
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
      get_active_pane ().execute_query ();
    }

    void on_cancel_query () {
      get_active_pane ().cancel_query ();
    }

    void on_open_file () {
      Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog (
        _("Open SQL file"), this, Gtk.FileChooserAction.OPEN,
        _("_Cancel"),
        Gtk.ResponseType.CANCEL,
        _("_Open"),
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
          tab.label = GLib.Path.get_basename (chooser.get_filename ());
          
          notebook.insert_tab (tab, -1);
          notebook.current = tab;

          chooser.close ();
        } catch (GLib.FileError e) {
          print ("A FileError occurred.");
        }
      } else {
        chooser.close ();
      }

    }

    void on_save_file () {
      Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog (
        _("Save SQL file"), this, Gtk.FileChooserAction.SAVE,
        _("_Cancel"),
        Gtk.ResponseType.CANCEL,
        _("_Save"),
        Gtk.ResponseType.ACCEPT);

      chooser.select_multiple = false;

      Gtk.FileFilter filter = new Gtk.FileFilter ();
      chooser.set_filter (filter);
      filter.add_mime_type ("application/sql");
      filter.add_mime_type ("text/sql");
      filter.add_mime_type ("text/x-sql");
      filter.add_mime_type ("text/plain");
      
      if (chooser.run () == Gtk.ResponseType.ACCEPT) {
        try {
          FileUtils.set_contents (chooser.get_filename (), get_active_pane ().get_text ());

          chooser.close ();
        } catch (GLib.FileError e) {
          print ("A FileError occurred.");
        }
      } else {
        chooser.close ();
      }

    }

    private void on_extensions_complete (Services.QueryResult result) {
      schemas_command.run ();

      extensions_category.clear ();
      foreach (var row in result.rows) {
        var item = new PostgresListItem (PostgresObject.EXTENSION, row.values[1], row.values[2], "");

        extensions_category.add (item);
      }

      extensions_category.badge = @"$(result.rows.size)";      
    }

    private void on_sequences_complete (Services.QueryResult result) {
      tables_command.execute (Services.TABLES_SQL);

      sequences_category.clear ();
      foreach (var row in result.rows) {
        var item = new PostgresListItem (PostgresObject.SEQUENCE, row.values[0], row.values[1], "");

        sequences_category.add (item);
      }

      sequences_category.badge = @"$(result.rows.size)";
    }

    private void on_tables_complete (Services.QueryResult result) {
      views_command.execute (Services.VIEWS_SQL);

      tables_category.clear ();
      foreach (var row in result.rows) {
        var item = new PostgresListItem (PostgresObject.TABLE, row.values[0], row.values[1], "");

        tables_category.add (item);
      }

      tables_category.badge = @"$(result.rows.size)";      
    }

    private void on_schemas_complete (Services.QueryResult result) {
      sequences_command.run ();

      schemas_category.clear ();
      foreach (var row in result.rows) {
        var item = new PostgresListItem (PostgresObject.SCHEMA, row.values[0], row.values[1], "");

        schemas_category.add (item);
      }

      schemas_category.badge = @"$(result.rows.size)";
    }

    private void on_views_complete (Services.QueryResult result) {
      functions_command.execute (Services.FUNCTIONS_SQL);

      views_category.clear ();
      foreach (var row in result.rows) {
        var item = new PostgresListItem (PostgresObject.VIEW, row.values[0], row.values[1], row.values[2]);
        
        views_category.add (item);
      }

      views_category.name = @"Views";
      views_category.badge = @"$(result.rows.size)";
      views_category.expanded = false;
    }

    private void on_functions_complete (Services.QueryResult result) {
      functions_category.clear ();

      foreach (var row in result.rows) {
        var item = new PostgresListItem (PostgresObject.FUNCTION, row.values[0], row.values[1], row.values[2]);

        functions_category.add (item);
      }

      functions_category.name = @"Functions";
      functions_category.badge = @"$(result.rows.size)";
      functions_category.expanded = false;
    }

    private void on_columns_complete (Services.QueryResult result) {
      selected_item.clear ();

      foreach (var row in result.rows) {
        var item = new PostgresListItem(PostgresObject.COLUMN, row.values[0], row.values[1], "");
      
        selected_item.add (item);
      }

      selected_item.expanded = true;
    }
  }
}