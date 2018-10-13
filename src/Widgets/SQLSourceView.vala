namespace Peeq.Widgets { 
  public class SQLSourceView : Gtk.Box {
    Gtk.SourceBuffer buffer;
    Gtk.SourceView source_view;

    public SQLSourceView () {
      init_layout ();
    }

    void init_layout () {
      var manager = Gtk.SourceLanguageManager.get_default ();

      buffer = new Gtk.SourceBuffer (null);
      buffer.language = manager.get_language ("sql");

      source_view = new Gtk.SourceView.with_buffer (buffer);
      source_view.show_line_numbers = true;
      source_view.highlight_current_line = true;
      source_view.show_right_margin = false;
      source_view.wrap_mode = Gtk.WrapMode.NONE;
      source_view.smart_home_end = Gtk.SourceSmartHomeEndType.AFTER;
      source_view.expand = true;

      var scroll = new Gtk.ScrolledWindow (null, null);
      scroll.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
      scroll.add (source_view);
      
      add (scroll);
    }

    public string get_text () {
      return buffer.text.strip ();
    }
  }
} 