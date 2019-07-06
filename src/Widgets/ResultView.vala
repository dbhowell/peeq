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

using Gee;
using Peeq.Services;

namespace Peeq.Widgets {
  public class ResultView : Gtk.Box {
    public signal void on_row_selected (ArrayList<QueryResult.Field> fields, QueryResult.Row row);
    public signal void on_copy (ArrayList<QueryResult.Field> fields, ArrayList<QueryResult.Row> rows, bool is_json);

    Gtk.Notebook notebook;
    RowsView rows_view;
    MessagesView messages_view;

    public ResultView () {
      init_layout ();
    }

    void init_layout () {
      rows_view = new RowsView ();

      messages_view = new MessagesView ();

      notebook = new Gtk.Notebook ();

      notebook.append_page (rows_view, new Gtk.Label (_("Query Results")));
      notebook.append_page (messages_view, new Gtk.Label (_("Messages")));

      add (notebook);
    }

    public void set_result (QueryResult result) {
      rows_view.set_result (result);
      messages_view.set_result (result);

      rows_view.on_row_selected.connect((fields, row) => {
        on_row_selected (fields, row);
      });

      rows_view.on_copy.connect((fields, rows, is_json) => {
        on_copy (fields, rows, is_json);
      });

      if (result.has_error) {
        notebook.set_current_page (1);
      } else {
        notebook.set_current_page (0);
      }
    }

  } 
  
}