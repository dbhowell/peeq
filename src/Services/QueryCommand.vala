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

namespace Peeq.Services { 
  public class QueryCommand {
    public signal void complete (QueryResult result);
    public signal void error (string message);
    public signal void busy (bool working);
 
    string id;
    Connection connection;

    public QueryCommand.with_connection (Connection connection) {
      this.connection = connection;

      this.connection.query_complete.connect (on_complete);
      this.connection.query_error.connect (on_error);
      this.connection.busy.connect (on_busy);
    }

    ~QueryCommand () {
      this.connection.query_complete.disconnect (on_complete);
      this.connection.query_error.disconnect (on_error);
      this.connection.busy.disconnect (on_busy);
    }

    void on_busy (bool working) {
      busy (working);
    }

    void on_error (string? id, string message) {
      if (this.id == id) {
        error (message);
      }
    }

    void on_complete (string? id, QueryResult result) {
      if (this.id == id) {
        complete (result);
      }
    }

    public void execute (string sql) {
      id = connection.execute (sql);
    }
  }
}