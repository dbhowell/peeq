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

using Postgres;

namespace Peeq.Services {
  public class Connection : GLib.Object {
    public signal void connecting ();
    public signal void ready ();
    public signal void query_complete (string? id, QueryResult result);
    public signal void query_error (string? id, string message);
    public signal void error (string message);
    public signal void busy (bool working);

    public bool connected {
      get; set; default = false;
    }

    public string query_id {
      get; set;
    }

    public string conninfo {
      get; set;
    }

    public bool working {
      get; set;
    }

    public string name {
      get {
        return database.get_db ();
      }
    }

    public string host {
      get {
        return database.get_host ();
      }
    }

    public double elapsed {
      get {
        return timer.elapsed ();
      }
    }

    GLib.Timer timer;
    Database database;
    int index = 0;

    public void cancel () {
      int result = database.request_cancel ();
      GLib.print(@"result = $(result)");
    }

    void start_working () {
      timer = new Timer ();
      this.working = true;
      busy (this.working);
    }

    void stop_working () {
      timer.stop ();
      this.working = false;
      busy (this.working);
    }

    public Connection.with_conninfo (string conninfo) {
      this.conninfo = conninfo;
    }

    public void connect_start () {
      if (this.conninfo == null) {
        error ("No connection info provided.");
        return;
      }

      timer = new GLib.Timer ();
      connected = false;
      start_working ();
      this.database = Postgres.connect_start (conninfo);

      connecting ();
      monitor_connect ();
    }

    public void reset () {
      connected = false;
      database.reset ();
    }

    public ConnectionStatus get_status () {
      return database.get_status ();
    }

    public string get_error_message () {
      return database.get_error_message ();
    }

    public bool is_busy () {
      return database.is_busy () == 1;
    }

    public int consume_input () {
      return database.consume_input();
    }

    public string? execute (string query) {
      if (this.working) {
        error (_("Connection is busy."));
        return null;
      }

      start_working ();
      database.send_query (query);

      this.query_id = create_id ();
      monitor_query ();

      return this.query_id;
    }

    void monitor_query () {
      GLib.Timeout.add (1, () => {
        int consume = consume_input ();

        if (consume == 0) {
          stop_working ();
          query_error (this.query_id, get_error_message ());
          return GLib.Source.REMOVE;
        }

        if (is_busy ()) {
          return GLib.Source.CONTINUE;
        } else {
          Postgres.Result[] results = {};
          results += database.get_result ();
          
          while (results[results.length - 1] != null) {
            results += database.get_result ();
          }
 
          stop_working ();
          query_complete (this.query_id, QueryResult.from_result (results[results.length - 2]));

          return GLib.Source.REMOVE;
        }
      });
    }

    void monitor_connect () {
      GLib.Timeout.add (1, () => {
        if (elapsed > 5.0) {
          stop_working ();
          error (_("Connection timed out."));
          return GLib.Source.REMOVE;
        }

        PollingStatus status = database.connect_poll ();

        if (status == PollingStatus.FAILED) {
          stop_working ();
          error (get_error_message ());
          return GLib.Source.REMOVE;
        }
  
        if (status == PollingStatus.OK) {
          connected = true;
          stop_working ();
          ready ();
          return GLib.Source.REMOVE;
        }
  
        return GLib.Source.CONTINUE;
      });
    }

    string create_id () {
      index++;
      return @"$(index)";
    }
  }
}