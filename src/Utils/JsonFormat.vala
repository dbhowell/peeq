using Gtk;
using Peeq.Services;

namespace Peeq.Utils {
  public class JsonFormat {
    public const string DELIMITER = ",";
    public const string QUOTE = "'";
    public const string NEW_LINE = "\n";
    public const string TAB = "  ";

    public static string fromValue (QueryResult.Field field, string value) {
      return @"\"$(field.name)\": $(DataFormat.formatValue(field, value))";
    }

    public static string fromRow (Gee.ArrayList<QueryResult.Field> fields, QueryResult.Row row) {
      var builder = new StringBuilder ();

      builder.append (TAB);
      builder.append("{\n");
      for (var i=0; i < row.values.size; i++) {
        builder.append (TAB);
        builder.append (TAB);
        builder.append (JsonFormat.fromValue(fields[i], row.values[i]));

        if (i < row.values.size - 1) {
          builder.append (",");
        }

        builder.append (NEW_LINE);
      }
      builder.append (TAB);
      builder.append("}");

      return builder.str;
    }

    public static string fromRows (Gee.ArrayList<QueryResult.Field> fields, Gee.ArrayList<QueryResult.Row> rows) {
      var builder = new StringBuilder ();

      builder.append("[\n");
      for (var i=0; i < rows.size; i++) {
        builder.append (JsonFormat.fromRow(fields, rows[i]));
      
        if (i < rows.size - 1) {
          builder.append (",");
        }
        builder.append (NEW_LINE);
      }
      builder.append("]\n");

      return builder.str;
    }
  }
}