public class Peeq.Widgets.ParameterListBox : Gtk.ScrolledWindow {

    Gtk.TreeView view;
    Gtk.ListStore list_store;

    public ParameterListBox () {
        list_store = new Gtk.ListStore (3, typeof (string), typeof (string), typeof (string));

        view = new Gtk.TreeView.with_model (list_store);

        var item_cellrenderer = new Gtk.CellRendererText ();
        item_cellrenderer.ellipsize_set = true;
        item_cellrenderer.width_chars = 50;
        item_cellrenderer.wrap_mode = Pango.WrapMode.WORD_CHAR;
        item_cellrenderer.ellipsize = Pango.EllipsizeMode.END;
        view.insert_column_with_attributes (-1, null, item_cellrenderer, "text", 0);
        view.insert_column_with_attributes (-1, null, item_cellrenderer, "text", 1);
        view.insert_column_with_attributes (-1, null, item_cellrenderer, "text", 2);

        add (view);
        set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);

        show_all ();
    }

    public void load (Services.QueryResult result) {
        list_store.clear ();

        Gtk.TreeIter iter;
        foreach (var r in result.rows) {
            list_store.append (out iter);
            list_store.set (iter, 0, r.values[0], 1, r.values[1], 2, r.values[2]);    
        }
    }
}