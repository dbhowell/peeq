using Gtk;
using Peeq.Services;

namespace Peeq.Utils {
  public class StyleManager {

    public static Gtk.CssProvider get_mono_style () {
      var settings = new Services.Settings ();
      var style = new Gtk.CssProvider ();

      try {
        var data = @"* {font-family: $(settings.mono_space_font); font-size: $(settings.mono_space_font_size); }";
        style.load_from_data (data, -1);

      } catch (GLib.Error e) {
        print (e.message);
        print ("get_mono_style (): An error occurred.");
      }

      return style;
    }
  }
}