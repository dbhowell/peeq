namespace Peeq.Widgets {
    public class ListFooter : Gtk.ActionBar {
        private Gtk.Button button_add;
        private Gtk.Button button_remove;

        public signal void add_server ();
        public signal void remove_server ();

        construct {
            button_add = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            button_add.sensitive = true;
            button_add.tooltip_text = _("Add server");

            button_remove = new Gtk.Button.from_icon_name ("list-remove-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            button_remove.sensitive = true;
            button_remove.tooltip_text = _("Remove server");

            get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
            add (button_add);
            add (button_remove);

            button_add.clicked.connect (() => {
                add_server ();
            });

            button_remove.clicked.connect (() => {
                remove_server ();
            });
        }
    }
}
