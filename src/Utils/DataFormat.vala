using Gtk;
using Peeq.Services;

namespace Peeq.Utils {
  public class DataFormat {
    public static const string DELIMITER = ";";
    public static const string QUOTE = "'";
    public static const string NEW_LINE = "\n";

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
  }
}