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

    public QueryCommand query_command;

    Gtk.Paned paned;
    SQLSourceView sql_source_view;
    ResultView result_view;
    ClipboardManager clipboard_manager;
    ActionBar action_bar;
    Label status_label;
    Label time_label;
    GLib.Timer timer;
    uint timeout_id;

    public QueryPaned.with_conninfo (string conninfo) {
      this.query_command = new QueryCommand.with_conninfo (conninfo);

      this.query_command.error.connect ((message) => {
        //print(@"$(message)\n");
      });

      this.query_command.complete.connect ((result) => {
        Source.remove (timeout_id);
        timer.stop ();

        status_label.label = _(@"$(result.rows.size) Records found.");
        time_label.label = format_duration ();

        set_result (result);
      });

      init_layout ();
    }

    void init_layout () {
      timer = new GLib.Timer ();
      orientation = Orientation.VERTICAL;
      clipboard_manager = new ClipboardManager ();
      sql_source_view = new SQLSourceView ();
      result_view = new ResultView ();
      result_view.on_copy.connect ((fields, rows, is_json) => {
        clipboard_manager.set_text (
          is_json ?
            Utils.JsonFormat.fromRows(fields, rows) :
            Utils.DataFormat.fromRows(fields, rows)
        );
      });

      paned = new Gtk.Paned(
        Gtk.Orientation.VERTICAL
      );

      paned.position = 200;
      paned.pack1(sql_source_view, false, false);
      paned.pack2(result_view, false, true);

      status_label = new Label ("");
      status_label.margin = 12;

      time_label = new Label ("");
      time_label.margin = 12;

      action_bar = new Gtk.ActionBar ();
      action_bar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
      action_bar.pack_end (status_label);
      action_bar.pack_start (time_label);

      add (paned);
      add (action_bar);
    }

    void set_result (QueryResult result) {
      result_view.set_result (result);
    }

    public void execute_query () {
      status_label.label = _(@"Running...");
      timer.reset ();
      timer.start ();
      timeout_id = GLib.Timeout.add (50, on_timeout, GLib.Priority.DEFAULT);

      query_command.execute (sql_source_view.get_sql ());
    }

    private bool on_timeout () {
      if (timer.elapsed (null) > 1.0f) {
        Source.remove (timeout_id);
        timeout_id = GLib.Timeout.add (500, on_timeout, GLib.Priority.DEFAULT);
      }

      time_label.label = @"$(format_duration ())..";

      return true;
    }

    public void cancel_query () {
      query_command.cancel ();
    }

    public void set_text (string text) {
      sql_source_view.set_text (text);
    }

    public string get_text () {
      return sql_source_view.get_text ();
    }

    public QueryResult get_result () {
      return result_view.get_result ();

    }

    public string get_result_csv () {
      var result = result_view.get_result ();
      return Utils.DataFormat.fromRows(result.fields, result.rows);
    }

    private string format_duration () {
      double elapsed = timer.elapsed (null);
      int s = (int)(elapsed);
      int ms = (int)(elapsed * 100.0f);

      if (elapsed < 1.0f) {
        return @"$(ms) ms.";
      }

      return @"$(s) seconds.";
    }
  }
}
