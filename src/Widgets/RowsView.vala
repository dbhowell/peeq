using Gee;
using Peeq.Services;

namespace Peeq.Widgets {
  public class RowsView : Gtk.Box {
    Gtk.TreeView view;

    public RowsView () {
      init_layout ();
    }

    void init_layout () {
      view = new Gtk.TreeView ();
      view.expand = true;
      view.enable_grid_lines = Gtk.TreeViewGridLines.BOTH;

      var scroll = new Gtk.ScrolledWindow (null, null);
      scroll.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
      scroll.add (view);
      
      add (scroll);  
    }

    void remove_columns () {
      var columns = view.get_columns ();

      foreach (var c in columns) {
        view.remove_column (c);
      }
    }
  
    public void set_result (QueryResult result) {
      remove_columns ();

      if (result.fields.size > 0) {
        set_columns (result.fields);
        fill_data (result);
      }
    }
    
    void set_columns (ArrayList<QueryResult.Field> fields) {
      Gtk.CellRendererText cell = new Gtk.CellRendererText ();

      for (int i=0; i < fields.size; i++) {
        view.insert_column_with_attributes (-1, fields[i].name.replace ("_", "__"), cell, "text", i);
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
        v.set_string (i);
        items[index++] = v;
      }

      return items;
    }

    void fill_data (QueryResult result) {
      Gtk.TreeIter iter;
      Gtk.ListStore store = new Gtk.ListStore.newv (get_types(result.fields));
  
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