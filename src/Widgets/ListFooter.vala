namespace Peeq.Widgets {
    public class ListFooter : Gtk.ActionBar {
        public Gtk.Button button_add;
        public Gtk.Button button_remove;
        public Gtk.Button button_edit;

        public signal void add_server ();
        public signal void remove_server ();
        public signal void edit_server ();

        construct {
            button_add = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            button_add.sensitive = true;
            button_add.tooltip_text = _("Add server");

            button_remove = new Gtk.Button.from_icon_name ("list-remove-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            button_remove.sensitive = false;
            button_remove.tooltip_text = _("Remove server");

            button_edit = new Gtk.Button.from_icon_name ("preferences-system-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            button_edit.tooltip_text = _("Edit server");
            button_edit.sensitive = false;
            
            get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
            add (button_add);
            add (button_remove);
            add (button_edit);

            button_add.clicked.connect (() => {
                add_server ();
            });

            button_remove.clicked.connect (() => {
                remove_server ();
            });

            button_edit.clicked.connect (() => {
                edit_server ();
            });
        }
    }
}
