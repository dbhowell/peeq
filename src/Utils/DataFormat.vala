using Gtk;
using Peeq.Services;

namespace Peeq.Utils {
  public class DataFormat {
    public const string DELIMITER = ";";
    public const string QUOTE = "'";
    public const string NEW_LINE = "\n";

    public const uint PG_TYPE_JSON = 114;
    public const uint PG_TYPE_BOOL = 16;
    public const uint PG_TYPE_TIMESTAMP = 1184;
    
    public static string formatValue (QueryResult.Field field, string value) {
      var format = (uint)field.ftype;

      if (format == PG_TYPE_BOOL) {
        return value == "t" ? "true" : "false";
      }

      if (format == PG_TYPE_TIMESTAMP && value == "") {
        return "null";
      }

      if (format == PG_TYPE_BOOL && value == "") {
        return "null";
      }

      if (format == PG_TYPE_JSON) {
        Json.Node? json_value = Json.from_string (value);
        
        if (json_value == null) {
          return "null";
        }

        return Json.to_string(json_value, true);
      }

      return @"\"$(value)\"";
    }

    public static string formatRow (Gee.ArrayList<QueryResult.Field> fields, QueryResult.Row row) {
      var builder = new StringBuilder ();

      for (var i=0; i < row.values.size; i++) {
        builder.append (QUOTE);
        builder.append (row.values[i]);
        builder.append (QUOTE);

        if (i < row.values.size - 1) {
          builder.append (DELIMITER);
        }
      }

      builder.append (NEW_LINE);

      return builder.str;
    }

    public static string fromRows (Gee.ArrayList<QueryResult.Field> fields, Gee.ArrayList<QueryResult.Row> rows) {
      var builder = new StringBuilder ();

      for (var i=0; i < rows.size; i++) {
        builder.append (DataFormat.formatRow(fields, rows[i]));
      }

      return builder.str;
    }
  }
}