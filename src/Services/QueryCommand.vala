
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