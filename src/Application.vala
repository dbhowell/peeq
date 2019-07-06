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

namespace Peeq {
  public Services.Settings settings;
  public string default_font;

  public class Application : Gtk.Application {
    private static string _app_cmd_name;

    construct {
      application_id = Constants.PROJECT_NAME;
    }

    public Application () {
      Granite.Services.Logger.initialize ("Peeq");

      settings = new Services.Settings ();
      default_font = new GLib.Settings ("org.gnome.desktop.interface").get_string ("monospace-font-name");
    }

    public static Application _instance = null;

    public static Application instance {
      get {
        if (_instance == null) {
          _instance = new Application ();
        }
        return _instance;
      }
    }

    protected override void activate () {
      var window = get_last_window ();
      if (window == null) {
        window = this.new_window ();
        window.show ();
      } else {
        window.present ();
      }
    }

    public MainWindow? get_last_window () {
      unowned List<weak Gtk.Window> windows = get_windows ();
      return windows.length () > 0 ? windows.last ().data as MainWindow : null;
    }

    public MainWindow new_window () {
      return new MainWindow (this);
    }

    public static int main (string[] args) {
      _app_cmd_name = "Peeq";
      Application app = Application.instance;
      return app.run (args);
    }
  }
}