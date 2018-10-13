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

      public Field (string name, int format, int number) {
        this.name = name;
        this.format = format;
        this.number = number;
      }

      public string to_string () {
        return @"Field ( name='$(name)', format=$(format), number=$(number) )";
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
        Field f = new Field (result.get_field_name (i), result.get_field_format (i), i);
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