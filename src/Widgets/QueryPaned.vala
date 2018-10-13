using Peeq.Services;

namespace Peeq.Widgets { 
  public class QueryPaned : Gtk.Box {
    public signal void is_working (bool working);

    Granite.Widgets.CollapsiblePaned paned;
    SQLSourceView sql_source_view;
    ResultView result_view;
    QueryCommand query_command;

    public QueryPaned.with_query_command (QueryCommand query_command) {
      this.query_command = query_command;
      
      this.query_command.error.connect ((message) => {
        print(@"$(message)\n");
      });

      this.query_command.complete.connect ((result) => {
        set_result (result);
      });

      init_layout ();
    }

    void init_layout () {
      sql_source_view = new SQLSourceView ();
      result_view = new ResultView ();

      paned = new Granite.Widgets.CollapsiblePaned(
        Gtk.Orientation.VERTICAL
      );

      paned.position = 200;
      paned.pack1(sql_source_view, false, false);
      paned.pack2(result_view, false, true);

      add (paned);
    }

    void set_result (QueryResult result) {
      result_view.set_result (result);
    }

    public void execute_query () {
      query_command.execute (sql_source_view.get_text ());
    }
  }
}