
namespace Peeq.Dialogs {
  public class Preferences : Gtk.Dialog {
      private Gtk.Stack main_stack;
      private Gtk.FontButton select_font;
      private Gtk.Switch use_custom_font;

      public Preferences (Gtk.Window? parent) {
          Object (
              border_width: 5,
              deletable: false,
              resizable: false,
              title: _("Preferences"),
              transient_for: parent
          );
      }

      construct {
          var indent_width = new Gtk.SpinButton.with_range (1, 24, 1);

          var general_grid = new Gtk.Grid ();
          general_grid.column_spacing = 12;
          general_grid.row_spacing = 6;
          general_grid.attach (new Granite.HeaderLabel (_("General")), 0, 0, 2, 1);
          
          main_stack = new Gtk.Stack ();
          main_stack.margin = 6;
          main_stack.margin_bottom = 18;
          main_stack.margin_top = 24;
          //main_stack.add_titled (general_grid, "behavior", _("Behavior"));
          main_stack.add_titled (get_editor_box (), "interface", _("Interface"));

          var main_stackswitcher = new Gtk.StackSwitcher ();
          main_stackswitcher.set_stack (main_stack);
          main_stackswitcher.halign = Gtk.Align.CENTER;

          var main_grid = new Gtk.Grid ();
          main_grid.attach (main_stackswitcher, 0, 0, 1, 1);
          main_grid.attach (main_stack, 0, 1, 1, 1);

          get_content_area ().add (main_grid);

          var close_button = new Gtk.Button.with_label (_("Close"));
          close_button.clicked.connect (() => {
              destroy ();
          });

          add_action_widget (close_button, 0);
      }

      private Gtk.Widget get_editor_box () {
          var content = new Gtk.Grid ();
          content.row_spacing = 6;
          content.column_spacing = 12;

          var editor_header = new Granite.HeaderLabel (_("Editor"));

          var style_label = new SettingsLabel (_("Style:"));
          var style_combo = new Gtk.ComboBoxText ();
          style_combo.append ("classic", _("Classic"));
          style_combo.append ("cobalt", _("Colbalt"));
          style_combo.append ("kate", _("Kate"));
          style_combo.append ("oblivion", _("Oblivion"));
          style_combo.append ("solarized-dark", _("Solarized Dark"));
          style_combo.append ("solarized-light", _("Solarized Light"));
          style_combo.append ("tango", _("Tango"));
          Peeq.settings.schema.bind ("style-scheme", style_combo, "active-id", SettingsBindFlags.DEFAULT);

          var use_custom_font_label = new SettingsLabel (_("Custom font:"));
          use_custom_font = new Gtk.Switch ();
          use_custom_font.halign = Gtk.Align.START;
          Peeq.settings.schema.bind ("use-system-font", use_custom_font, "active", SettingsBindFlags.INVERT_BOOLEAN);

          select_font = new Gtk.FontButton ();
          select_font.hexpand = true;
          Peeq.settings.schema.bind ("font", select_font, "font-name", SettingsBindFlags.DEFAULT);
          Peeq.settings.schema.bind ("use-system-font", select_font, "sensitive", SettingsBindFlags.INVERT_BOOLEAN);


          var general_header = new Granite.HeaderLabel (_("General"));
          var dark_mode_label = new SettingsLabel (_("Dark mode:"));
          var dark_mode_switch = new Granite.ModeSwitch.from_icon_name (
            "display-brightness-symbolic", "weather-clear-night-symbolic"
          );
          dark_mode_switch.notify["active"].connect (() => {
            var gtk_settings = Gtk.Settings.get_default ();
            gtk_settings.gtk_application_prefer_dark_theme = dark_mode_switch.active;      
          });
          Peeq.settings.schema.bind ("prefer-dark-style", dark_mode_switch, "active", GLib.SettingsBindFlags.DEFAULT);

          content.attach (general_header, 0, 1, 3, 1);
          content.attach (dark_mode_label, 0, 2, 1, 1);
          content.attach (dark_mode_switch, 1, 2, 3, 1);
          content.attach (editor_header, 0, 3, 3, 1);
          content.attach (style_label, 0, 4, 1, 1);
          content.attach (style_combo, 1, 4, 2, 1);
          content.attach (use_custom_font_label , 0, 9, 1, 1);
          content.attach (use_custom_font, 1, 9, 1, 1);
          content.attach (select_font, 2, 9, 1, 1);

          return content;
      }

      private class SettingsLabel : Gtk.Label {
          public SettingsLabel (string text) {
              label = text;
              halign = Gtk.Align.END;
              margin_start = 12;
          }
      }

      private class SettingsSwitch : Gtk.Switch {
          public SettingsSwitch (string setting) {
              halign = Gtk.Align.START;
              valign = Gtk.Align.CENTER;
              Peeq.settings.schema.bind (setting, this, "active", SettingsBindFlags.DEFAULT);
          }
      }
  }
}