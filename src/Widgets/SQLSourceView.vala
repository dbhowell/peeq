/*
* Copyright (c) 2018 David Howell <david@dynamicmethods.com.au>
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

namespace Peeq.Widgets { 
  public class SQLSourceView : Gtk.Box {
    Gtk.SourceBuffer buffer;
    Gtk.SourceView source_view;

    public string default_font { get; set; }

    public SQLSourceView () {
      init_settings ();
      init_layout ();
    }

    void init_settings () {
      default_font = new GLib.Settings ("org.gnome.desktop.interface").get_string ("monospace-font-name");
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
      source_view.override_font (Pango.FontDescription.from_string (default_font));

      var scroll = new Gtk.ScrolledWindow (null, null);
      scroll.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
      scroll.add (source_view);
      
      add (scroll);
    }

    public string get_text () {
      return buffer.text.strip ();
    }

    public void set_text (string text) {
      buffer.text = text;
    }
  }
} 