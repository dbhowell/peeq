using Peeq.Services;

namespace Peeq.Widgets {
	public class ServerList : Gtk.ListBox {
		public signal void show_no_items (bool show);

		construct {
			selection_mode = Gtk.SelectionMode.SINGLE;
			activate_on_single_click = false;

			bool show = (get_children ().length () > 0);
			show_no_items (!show);

		}

		public void add_server_to_list (ServerPage page) {
			ServerListItem item = new ServerListItem.with_server (page);

			add (item);
			show_all ();
		}
	}
}