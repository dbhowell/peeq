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

using Peeq.Services;

public class Peeq.Widgets.PostgresListItem : Granite.Widgets.SourceList.ExpandableItem {
  public string schema { get; set; }
  public string definition { get; set; }
  public PostgresObject postgres_object { get; set; }
  public string pg_name { get; set; }

  public PostgresListItem (PostgresObject postgres_object, string schema, string name, string definition) {
    base (@"$(name)");

    this.pg_name = name;
    this.postgres_object = postgres_object;
    this.schema = schema;
    this.definition = definition;

    if (postgres_object == COLUMN) {
      this.name = @"$(this.schema) ($(this.pg_name))";
    }

//    this.icon = new Gtk.Image.from_icon_name ("x-office-spreadsheet", IconSize.DND);
  }
}