using Peeq.Services;

namespace Peeq.Widgets { 
  public class MessagesView : Gtk.Box {
    Gtk.Label label;

    public string message {
      get { return label.label; }
      set { label.label = value; }
    }

    public MessagesView () {
      init_layout ();
    }

    public void set_result (QueryResult result) {
      if (result.has_error) {
        message = result.error_message;
      } else {
        message = "";
      }
    }

    void init_layout () {
      label = new Gtk.Label("");

      add (label);
    }
  }
}