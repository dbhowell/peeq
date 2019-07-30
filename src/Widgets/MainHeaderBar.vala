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
  public class MainHeaderBar : Gtk.HeaderBar {
    public signal void preferences_clicked ();

    Gtk.Spinner spinner;
    Gtk.Button preferences;

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

      preferences = new Gtk.Button ();
      preferences.image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
      preferences.tooltip_text = _("Menu");
      preferences.clicked.connect (() => {
        preferences_clicked ();
      });

      pack_end (preferences);
      pack_end (spinner);
    }
  }
}