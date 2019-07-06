using Gtk;
using Peeq.Services;

namespace Peeq.Utils {
  public class StyleManager {

    public static string get_current_font () {
      if (!Peeq.settings.use_system_font) {
        return Peeq.settings.font;
      }

      return Peeq.default_font;
    }

    public static string get_font_size () {
      string font = get_current_font ();
      string font_size = font.substring (font.last_index_of (" ") + 1);
 
      return font_size;
    }

    public static string get_font_family () {
      string font = get_current_font ();
      string font_family = font.substring (0, font.last_index_of (" "));
      
      return font_family;
    }

    public static Gtk.CssProvider get_mono_style () {
      var style = new Gtk.CssProvider ();

      try {
        var data = @"* {font-family: \"$(get_font_family ())\"; font-size: $(get_font_size ())pt; }";
        print(@"$(data)\n");
        style.load_from_data (data, -1);

      } catch (GLib.Error e) {
        print (e.message);
        print ("get_mono_style (): An error occurred.");
      }

      return style;
    }
  }
}