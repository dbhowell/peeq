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
using Peeq.Utils;
using Gtk;

namespace Peeq.Widgets { 
  public class QueryPaned : Gtk.Box {
    public signal void is_working (bool working);

    Granite.Widgets.CollapsiblePaned paned;
    SQLSourceView sql_source_view;
    ResultView result_view;
    QueryCommand query_command;
    ClipboardManager clipboard_manager;
    ActionBar action_bar;
    Label status_label;

    public QueryPaned.with_query_command (QueryCommand query_command) {
      this.query_command = query_command;
      
      this.query_command.error.connect ((message) => {
        //print(@"$(message)\n");
      });

      this.query_command.complete.connect ((result) => {
        status_label.label = @"$(result.rows.size) Records found.";
        set_result (result);
      });

      init_layout ();
    }

    void init_layout () {
      orientation = Orientation.VERTICAL;
      clipboard_manager = new ClipboardManager ();
      sql_source_view = new SQLSourceView ();
      result_view = new ResultView ();
      result_view.on_copy.connect ((fields, rows) => {
        clipboard_manager.set_text (Utils.DataFormat.formatRows(fields, rows));
      });

      paned = new Granite.Widgets.CollapsiblePaned(
        Gtk.Orientation.VERTICAL
      );

      paned.position = 200;
      paned.pack1(sql_source_view, false, false);
      paned.pack2(result_view, false, true);

      status_label = new Label ("");
      status_label.margin = 12;
      
      action_bar = new Gtk.ActionBar ();
      action_bar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
      action_bar.pack_end (status_label);

      add (paned);
      add (action_bar);
    }

    void set_result (QueryResult result) {
      result_view.set_result (result);
    }

    public void execute_query () {
      status_label.label = @"Running...";
      query_command.execute (sql_source_view.get_sql ());
    }

    public void set_text (string text) {
      sql_source_view.set_text (text);
    }
  }
}