
conf_data = configuration_data()
conf_data.set_quoted('PROJECT_NAME', meson.project_name())
conf_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf_data.set_quoted('VERSION', meson.project_version())
conf_data.set_quoted('PREFIX', get_option('prefix'))
conf_data.set_quoted('DATADIR', join_paths (get_option('prefix'), get_option('datadir')))
config_header = configure_file(
  input : 'config.vala.in',
  output : 'config.vala',
  configuration : conf_data
)

executable(
  meson.project_name(),
  'Application.vala',
  'MainWindow.vala',
  'QueryWindow.vala',
  'Dialogs/EditServer.vala',
  'Dialogs/PreferencesDialog.vala',
  'Widgets/MainHeaderBar.vala',
  'Widgets/ServerList.vala',
  'Widgets/ServerListItem.vala',
  'Widgets/Welcome.vala',
  'Widgets/DatabaseList.vala',
  'Widgets/DatabaseListItem.vala',
  'Widgets/ListFooter.vala',
  'Widgets/MessagesView.vala',
  'Widgets/ServerPage.vala',
  'Widgets/ServerProperties.vala',
  'Widgets/SQLSourceView.vala',
  'Widgets/ResultView.vala',
  'Widgets/RowsView.vala',
  'Widgets/QueryPaned.vala',
  'Widgets/QueryHeaderBar.vala',
  'Services/Settings.vala',
  'Services/Connection.vala',
  'Services/QueryCommand.vala',
  'Services/QueryResult.vala',
  'Services/ServerConnection.vala',
  'Dialogs/EditServer.vala',
  'Utils/ClipboardManager.vala',
  'Utils/ConnectionString.vala',
  'Utils/DataFormat.vala',
  'Utils/JsonFormat.vala',
  'Utils/StyleManager.vala',
  'Utils/ValueCellRenderer.vala',
  config_header,
  dependencies: [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gtk+-3.0'),
    dependency('gtksourceview-3.0'),
    dependency('gee-0.8'),
    dependency('libpq'),
    dependency('granite'),
    dependency('json-glib-1.0'),
    meson.get_compiler('vala').find_library('posix')
  ],
  install: true
)
