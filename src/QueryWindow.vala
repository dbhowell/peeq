using Granite.Widgets;

namespace Peeq { 
  public class QueryWindow : Gtk.Window {
    Widgets.QueryHeaderBar headerbar;
    Services.Connection connection;
    DynamicNotebook notebook;
    public string conninfo { get; set; }

    public QueryWindow (Peeq.Application application) {
      Object (
        application: application,
        icon_name: "com.github.dbhowell.peeq"
      );
    }

    public QueryWindow.with_conninfo (Peeq.Application application, string conninfo) {
      this.application = application;
      this.conninfo = conninfo;

      connection.conninfo = conninfo;
      connection.connect_start ();
    }

    construct {
      init_layout ();
    }

    void init_layout () {
      connection = new Services.Connection ();
      connection.busy.connect ((working) => {
        headerbar.working = working;
      });
      connection.ready.connect (() => {
        this.set_title (@"$(connection.host)/$(connection.name)");
      });
      
      notebook = new DynamicNotebook ();
      notebook.new_tab_requested.connect (on_new_tab_requested);
      notebook.tab_removed.connect (on_tab_removed);
      notebook.insert_tab (create_tab (), 0);
      notebook.show ();

      add (notebook);

      headerbar = new Widgets.QueryHeaderBar ();
      add_accel_group (headerbar.accel_group);
      headerbar.execute_query.connect (() => {
        Widgets.QueryPaned item = (Widgets.QueryPaned) notebook.current.page;
        item.execute_query ();
      });

      set_titlebar (headerbar);

      resize (800, 600);
    }     

    void on_new_tab_requested () {
      var tab = create_tab ();

      notebook.insert_tab (tab, notebook.n_tabs);
      notebook.current = tab;
    }

    void on_tab_removed (Tab tab) {
      if (notebook.n_tabs == 0 && this.visible) {
        notebook.insert_tab (create_tab (), 0);
      }
    }

    Tab create_tab () {
      return 
        new Tab (
          @"Query $(notebook.n_tabs + 1)",
          null,
          new Widgets.QueryPaned.with_query_command (new Services.QueryCommand.with_connection (connection))
        );
    }
  }
}