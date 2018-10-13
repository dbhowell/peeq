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
  public class QueryPaned : Gtk.Box {
    public signal void is_working (bool working);

    Granite.Widgets.CollapsiblePaned paned;
    SQLSourceView sql_source_view;
    ResultView result_view;
    QueryCommand query_command;

    public QueryPaned.with_query_command (QueryCommand query_command) {
      this.query_command = query_command;
      
      this.query_command.error.connect ((message) => {
        print(@"$(message)\n");
      });

      this.query_command.complete.connect ((result) => {
        set_result (result);
      });

      init_layout ();
    }

    void init_layout () {
      sql_source_view = new SQLSourceView ();
      result_view = new ResultView ();

      paned = new Granite.Widgets.CollapsiblePaned(
        Gtk.Orientation.VERTICAL
      );

      paned.position = 200;
      paned.pack1(sql_source_view, false, false);
      paned.pack2(result_view, false, true);

      add (paned);
    }

    void set_result (QueryResult result) {
      result_view.set_result (result);
    }

    public void execute_query () {
      query_command.execute (sql_source_view.get_text ());
    }

    public void set_text (string text) {
      sql_source_view.set_text (text);
    }
  }
}