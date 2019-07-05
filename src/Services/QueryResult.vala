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

namespace Peeq.Services { 
  public class QueryResult {
    public class Row {
      private ArrayList<string> _values = new ArrayList<string> ();

      public ArrayList<string> values {
        get {
          return _values;
        }
      }

      public string to_string () {
        return @"Row( values.size=$(values.size) )";
      }
    }

    public class Field {
      public string name { get; set; }
      public int format { get; set; }
      public int number { get; set; }
      public Postgres.Oid ftype { get; set; }

      public Field (string name, Postgres.Oid ftype, int format, int number) {
        this.name = name;
        this.format = format;
        this.number = number;
        this.ftype = ftype;

        print(@"$(to_string ())\n");
      }

      public string to_string () {
        uint id = (uint)ftype;
        return @"Field ( name='$(name)', type=$(id), format=$(format), number=$(number) )";
      }  
    }

    ArrayList<Row> _rows = new ArrayList<Row> ();
    ArrayList<Field> _fields = new ArrayList<Field> ();
    string? _error_message = "";
    string? _command_status = "";
    string? _command_tuples = "";

    public string error_message {
      get { return _error_message; }
      set { _error_message = value; }
    }

    public bool has_error {
      get {
        return (_error_message != null && _error_message != "");
      }
    }

    public string command_tuples {
      get { return _command_tuples; }
      set { _command_tuples = value; }
    }

    public string command_status {
      get { return _command_status; }
      set { _command_status = value; }
    }

    public ArrayList<Row> rows {
      get {
        return _rows;
      }
    }

    public ArrayList<Field> fields {
      get {
        return _fields;
      }
    }

    public QueryResult () {
      
    }

    public QueryResult.with_fields (ArrayList<Field> fields) {
      _fields = fields;
    }

    public string to_string () {
      return @"QueryResult( error_message = $(error_message), command_status = $(command_status), command_tuples = $(command_tuples), rows.size = $(_rows.size), fields.size = $(_fields.size) )";
    }

    static ArrayList<Field> fill_fields (Postgres.Result result) {
      ArrayList<Field> items = new ArrayList<Field> ();

      for (int i=0; i < result.get_n_fields (); i++) {
        Field f = new Field (result.get_field_name (i), result.get_field_type (i), result.get_field_format (i), i);
        items.add (f);
      }

      return items;
    }

    public static QueryResult from_result (Postgres.Result result) {
      QueryResult item = new QueryResult.with_fields (fill_fields (result));

      item.command_status = result.get_cmd_status ();
      item.error_message = result.get_error_message ();

      for (int i=0; i < result.get_n_tuples (); i++) {
        var row = new Row ();
        
        for (int j=0; j < result.get_n_fields (); j++) {
          row.values.add (result.get_value (i, j));
        }
  
        item.rows.add(row);
      }

      return item;
    }
  }  
}