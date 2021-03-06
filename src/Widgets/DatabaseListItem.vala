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

using Peeq.Services;

namespace Peeq.Widgets {
	public class DatabaseListItem : Gtk.ListBoxRow {
		public string title { get; set; default = ""; }
		public string subtitle { get; set; default = "<span font_size='small'>" + _("Disconnected") + "</span>"; }
		public string icon_name { get; set; default = "office-database"; }

		private Gtk.Image status_image;

		public DatabaseListItem (string title, string subtitle, string icon_name = "office-database") {
			Object (
				title: title,
				subtitle: @"<span font_size='small'>$(subtitle)</span>",
				icon_name: icon_name
			);
		}

		construct {
			var overlay = new Gtk.Overlay ();
			overlay.width_request = 38;

			var row_grid = new Gtk.Grid ();
			row_grid.margin = 6;
			row_grid.margin_start = 3;
			row_grid.column_spacing = 3;

			var row_image = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.DND);
			row_image.pixel_size = 32;

			var row_title = new Gtk.Label (title);
      row_title.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
      row_title.ellipsize = Pango.EllipsizeMode.END;
      row_title.halign = Gtk.Align.START;
			row_title.valign = Gtk.Align.START;

			var row_description = new Gtk.Label (subtitle);
      row_description.margin_top = 2;
      row_description.use_markup = true;
      row_description.ellipsize = Pango.EllipsizeMode.END;
      row_description.halign = Gtk.Align.START;
      row_description.valign = Gtk.Align.START;

      var hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
      hbox.pack_start (row_description, false, false, 0);

      status_image = new Gtk.Image.from_icon_name ("user-offline", Gtk.IconSize.MENU);
			status_image.halign = status_image.valign = Gtk.Align.END;
		
			overlay.add (row_image);
      overlay.add_overlay (status_image);

      row_grid.attach (overlay, 0, 0, 1, 2);
      row_grid.attach (row_title, 1, 0, 1, 1);
      row_grid.attach (hbox, 1, 1, 1, 1);

			add (row_grid);

			bind_property ("title", row_title, "label");
      bind_property ("subtitle", row_description, "label");
      bind_property ("icon-name", row_image, "icon-name");

			notify.connect ((s, p) => {
				if (p.name == "subtitle") {
					status_image.icon_name = (this.subtitle == "<span font_size='small'>N/A</span>") ? "user-busy" : "user-offline";
				}
			});

			show_all ();
		}
	}
}