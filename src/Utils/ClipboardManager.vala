using Gtk;
using Peeq.Services;

namespace Peeq.Utils {
  public class ClipboardManager {

    private Gtk.Clipboard clipboard = null;

    public ClipboardManager () {
      clipboard = Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD);
    }

    ~ClipboardManager () {

    }

    public void set_text (string value) {
      clipboard.set_text (value, value.length);
    }
  }
}