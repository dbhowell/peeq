using Peeq.Services;

namespace Peeq.Widgets {
	public class DatabaseList : Gtk.ListBox {
		public signal void show_no_items (bool show);

		construct {
			selection_mode = Gtk.SelectionMode.SINGLE;
			activate_on_single_click = false;

			bool show = (get_children ().length () > 0);
			show_no_items (!show);
		}

		public void add_database_to_list (string database_name) {
			DatabaseListItem item = new DatabaseListItem (database_name, "Disconnected");

			add (item);
			show_all ();
		}

		public void update_items (string[] items) {
			clear ();

			foreach (var i in items) {
				add (new DatabaseListItem (i, "Disconnected"));
			}
		}

		private void clear () {
			foreach (var r in get_children ()) {
				remove (r);
			}
		}
	}
}