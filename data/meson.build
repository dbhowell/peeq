icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
  install_data(
    join_paths('icons', i, meson.project_name() + '.svg'),
    install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps')
  )
  install_data(
    join_paths('icons', i, meson.project_name() + '.svg'),
    install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps')
  )
endforeach

install_data(
  'icons/128/' + meson.project_name() + '.svg',
  install_dir: join_paths(get_option('datadir'), 'icons/hicolor/scalable/apps')
)

install_data(
  'com.github.dbhowell.peeq.gschema.xml',
  install_dir: join_paths(get_option('prefix'), get_option('datadir'), 'glib-2.0', 'schemas')
)