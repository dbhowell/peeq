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
  public class DatabaseView : Gtk.Box {
    public QueryCommand query_command;
    
    ListBox database_list;

    public DatabaseView.with_conninfo (string conninfo) {
      this.query_command = new QueryCommand.with_conninfo (conninfo);
      
      this.query_command.error.connect ((message) => {
        //print(@"$(message)\n");
      });

      this.query_command.complete.connect ((result) => {
        status_label.label = _(@"$(result.rows.size) Records found.");
        set_result (result);
      });

      init_layout ();
    }

    void init_layout () {
      database_list = new Gtk.ListBox ();
      database_list.activate_on_single_click = true;
      database_list.expand = true;
      database_list.selection_mode = Gtk.SelectionMode.SINGLE;
      database_list.set_filter_func (filter_function);
      database_list.set_header_func (header_function);
      database_list.set_sort_func (sort_function);

      var scrolledwindow = new Gtk.ScrolledWindow (null, null);
      scrolledwindow.add (database_list);
      add(scrolledwindow);
    }

    void set_result (QueryResult result) {
      result_view.set_result (result);
    }

    public void execute_query () {
      status_label.label = _(@"Running...");
      query_command.execute ("");
    }

    public void cancel_query () {
      query_command.cancel ();
    }
  }
}