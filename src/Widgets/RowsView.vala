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

using Gtk;
using Gee;
using Peeq.Services;

namespace Peeq.Widgets {
  public class RowsView : Gtk.Box {
    public signal void on_row_selected (ArrayList<QueryResult.Field> fields, QueryResult.Row row);
    public signal void on_copy (ArrayList<QueryResult.Field> fields, ArrayList<QueryResult.Row> rows);

    public string default_font { get; set; }

    Gtk.TreeView view;
    Gtk.ListStore store;
    QueryResult result;
    int selected_row_index = -1;

    public RowsView () {
      init_settings ();
      init_layout ();
    }

    void init_settings () {
      var settings = new Services.Settings ();
      default_font = settings.mono_space_font;
    }

    void init_layout () {
      view = new Gtk.TreeView ();
      view.expand = true;
      view.enable_grid_lines = Gtk.TreeViewGridLines.BOTH;
      view.headers_clickable = true;
      view.reorderable = true;
      view.activate_on_single_click = false;
      view.cursor_changed.connect(on_cursor_changed);
      view.row_activated.connect(on_row_activated);
      view.key_press_event.connect(on_view_key_press_event);
      view.get_selection ().set_mode (Gtk.SelectionMode.MULTIPLE);

      var scroll = new Gtk.ScrolledWindow (null, null);
      scroll.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
      scroll.add (view);
      
      add (scroll);  
    }

    void on_cursor_changed () {
      TreePath? path;
      TreeViewColumn? focus_column;

      view.get_cursor (out path, out focus_column);
    }

    void on_row_activated (Gtk.TreePath path, Gtk.TreeViewColumn column) {
      this.selected_row_index = int.parse(path.to_string ());
      on_row_selected (this.result.fields, this.result.rows[this.selected_row_index]);
    }

    protected virtual bool on_view_key_press_event (Gdk.EventKey event) {
      if (event.state == Gdk.ModifierType.CONTROL_MASK && event.keyval == 99 && selected_row_index > -1) {
        TreeModel model;
        GLib.List<TreePath> paths = view.get_selection ().get_selected_rows (out model);
        ArrayList<QueryResult.Row> rows = new ArrayList<QueryResult.Row> ();

        foreach (var p in paths) {
          print(p.to_string ());
          var index = int.parse(p.to_string ());
          rows.add (this.result.rows[index]);
        }

        on_copy (this.result.fields, rows);
      }

      return true;
    }

    void remove_columns () {
      var columns = view.get_columns ();

      foreach (var c in columns) {
        view.remove_column (c);
      }
    }
  
    public void set_result (QueryResult result) {
      this.result = result;
      remove_columns ();

      if (result.fields.size > 0) {
        set_columns (result.fields);
        fill_data (result);
        view.headers_clickable = true;
        view.reorderable = true;
        view.activate_on_single_click = true;  
        view.columns_autosize ();
      }
    }
    
    void set_columns (ArrayList<QueryResult.Field> fields) {
      Utils.ValueCellRenderer cell = new Utils.ValueCellRenderer (this.default_font);
      cell.editable_set = true;
      cell.editable = true;

      for (int i=0; i < fields.size; i++) {
        view.insert_column_with_attributes (-1, fields[i].name.replace ("_", "__"), cell, "text", i);
        var c = view.get_column(i);
        c.resizable = true;
        c.max_width = 320;
      }

      view.model = new Gtk.ListStore.newv (get_types (fields));
    }

    Type[] get_types (ArrayList<QueryResult.Field> fields) {
      var items = new GLib.Type[fields.size];

      for (var i=0; i<items.length; i++) {
        items[i] = typeof (string);
      }

      return items;
    }

    Value[] get_values (QueryResult.Row row) {
      var items = new GLib.Value[row.values.size];
      var index = 0;

      foreach (var i in row.values) {
        var v = Value(typeof (string));
        //if (i.length > 80) {
        //  v.set_string (i.substring(0, 77) + "...");
        //} else {
          v.set_string (i);            
        //}

        items[index++] = v;
      }

      return items;
    }

    void fill_data (QueryResult result) {
      Gtk.TreeIter iter;
      store = new Gtk.ListStore.newv (get_types(result.fields));
  
      foreach (var row in result.rows) {
        var columns = new int[row.values.size];
        for (int i=0; i<row.values.size; i++) {
          columns[i] = i;
        }
        store.append (out iter);
        store.set_valuesv (iter, columns, get_values(row));    
      }

      view.model = store;
    }
  }  
}