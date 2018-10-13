
namespace Peeq.Widgets { 
  public class MainHeaderBar : Gtk.HeaderBar {
    public signal void new_connection ();
    public signal void remove_connection ();

    Gtk.Spinner spinner;
    Gtk.Button new_button;
    Gtk.Button remove_button;
    
    public Gtk.AccelGroup accel_group;

    public bool working {
      set {
        if (value) {
          spinner.start ();
        } else {
          spinner.stop ();
        }
      }
    }

    public MainHeaderBar () {
      init_layout ();
    }

    void init_layout () {
      set_show_close_button (true);

      accel_group = new Gtk.AccelGroup ();

      spinner = new Gtk.Spinner ();

      new_button = new Gtk.Button ();
      new_button.image = new Gtk.Image.from_icon_name ("list-add", Gtk.IconSize.LARGE_TOOLBAR);
      new_button.tooltip_text = (_("Add..."));
      new_button.clicked.connect (() => {
        new_connection();
      });

      remove_button = new Gtk.Button ();
      remove_button.image = new Gtk.Image.from_icon_name ("list-remove", Gtk.IconSize.LARGE_TOOLBAR);
      remove_button.tooltip_text = (_("Remove..."));
      remove_button.clicked.connect (() => {
        remove_connection();
      });

      pack_start (new_button);
      pack_start (remove_button);
      pack_end (spinner);
    }
  }
}