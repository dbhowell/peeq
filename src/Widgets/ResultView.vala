using Peeq.Services;

namespace Peeq.Widgets {
  public class ResultView : Gtk.Box {
    Gtk.Notebook notebook;
    RowsView rows_view;
    MessagesView messages_view;

    public ResultView () {
      init_layout ();
    }

    void init_layout () {
      rows_view = new RowsView ();

      messages_view = new MessagesView ();

      notebook = new Gtk.Notebook ();

      notebook.append_page (rows_view, new Gtk.Label (_("Query Results")));
      notebook.append_page (messages_view, new Gtk.Label (_("Messages")));

      add (notebook);
    }

    public void set_result (QueryResult result) {
      rows_view.set_result (result);
      messages_view.set_result (result);

      if (result.has_error) {
        notebook.set_current_page (1);
      } else {
        notebook.set_current_page (0);
      }
    }

  } 
  
}