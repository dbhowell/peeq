
namespace Peeq.Widgets {
	public class Welcome : Granite.Widgets.Welcome {
		public signal void new_connection ();

		public Welcome () {
			base(_("Peeq"), _("The Postgresql GUI client."));

			activated.connect (on_activated);

			init_layout ();
		}

		private void init_layout () {
			append ("document-new", _("Add..."), _("Add a new Postgresql server."));
		}

		private void on_activated (int index) {
			if (index == 0) {
				new_connection ();
			}
		}
	}
}