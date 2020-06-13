/*
* Copyright 2018 elementary, Inc. (https://elementary.io)
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
*
*/

public class Peeq.DatabaseObjectRow : Gtk.ListBoxRow {
  public string name { get; construct; }

  public DatabaseObjectRow (string name) {
      Object (name: name);
  }

  construct {
    Granite.Widgets.Avatar avatar;

    avatar = new Granite.Widgets.Avatar.with_default_icon (32);
    avatar.margin_start = 1;

    var individual_name = new Gtk.Label (name);
    individual_name.ellipsize = Pango.EllipsizeMode.MIDDLE;
    individual_name.use_markup = true;
    individual_name.xalign = 0;

    var grid = new Gtk.Grid ();
    grid.column_spacing = 6;
    grid.margin = 6;
    grid.add (avatar);
    grid.add (individual_name);

    add (grid);
  }
}
