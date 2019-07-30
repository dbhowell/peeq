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
  public class QueryHeaderBar : Gtk.HeaderBar {
    public signal void execute_query ();
    public signal void cancel_query ();
    public signal void open_file ();

    Gtk.Spinner spinner;
    Gtk.MenuButton app_menu;
    Gtk.Button execute_button;
    Gtk.Button cancel_button;
    Gtk.Button open_button;
    Gtk.Button save_button;
    Gtk.Button save_as_button;
    
    public Gtk.AccelGroup accel_group;

    public bool working {
      set {
        if (value) {
          spinner.start ();
          execute_button.set_sensitive (false);
          cancel_button.set_sensitive (true);
        } else {
          spinner.stop ();
          execute_button.set_sensitive (true);
          cancel_button.set_sensitive (false);
        }
      }
    }

    public QueryHeaderBar () {
      build_ui ();
    }

    void build_ui () {
      set_show_close_button (true);

      accel_group = new Gtk.AccelGroup ();

      spinner = new Gtk.Spinner ();

      app_menu = new Gtk.MenuButton ();
      app_menu.image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
      app_menu.tooltip_text = _("Menu");

      open_button = new Gtk.Button ();
      open_button.image = new Gtk.Image.from_icon_name ("document-open", Gtk.IconSize.LARGE_TOOLBAR);
      open_button.tooltip_text = _("Open");
      open_button.clicked.connect (() => {
        open_file ();
      });

      save_button = new Gtk.Button ();
      save_button.image = new Gtk.Image.from_icon_name ("document-save", Gtk.IconSize.LARGE_TOOLBAR);
      save_button.tooltip_text = _("Save");

      save_as_button = new Gtk.Button ();
      save_as_button.image = new Gtk.Image.from_icon_name ("document-save-as", Gtk.IconSize.LARGE_TOOLBAR);
      save_as_button.tooltip_text = _("Save As...");

      execute_button = new Gtk.Button ();
      execute_button.image = new Gtk.Image.from_icon_name ("media-playback-start", Gtk.IconSize.LARGE_TOOLBAR);
      execute_button.tooltip_text = _("Execute");
      execute_button.add_accelerator ("activate", accel_group, Gdk.keyval_from_name("F5"), 0, Gtk.AccelFlags.VISIBLE);
      execute_button.clicked.connect (() => {
        execute_query ();
      });

      cancel_button = new Gtk.Button ();
      cancel_button.image = new Gtk.Image.from_icon_name ("media-playback-stop", Gtk.IconSize.LARGE_TOOLBAR);
      cancel_button.tooltip_text = _("Cancel");
      cancel_button.set_sensitive (false);
      cancel_button.clicked.connect (() => {
        cancel_query();
      });

      pack_start (open_button);
      pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
      pack_start (execute_button);
      pack_start (cancel_button);
      pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
//      pack_start (save_button);
//      pack_start (save_as_button);

//      pack_end (app_menu);
      pack_end (spinner);
    }
  }
}
