# project name and programming language
project('com.github.dbhowell.peeq', 'vala', 'c', version: '0.3.4')

# Include the translations module
i18n = import('i18n')

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

subdir('src')

#Translate and install our .desktop file
i18n.merge_file(
  input: join_paths('data', meson.project_name() + '.desktop.in'),
  output: meson.project_name() + '.desktop',
  po_dir: join_paths(meson.source_root(), 'po'),
  type: 'desktop',
  install: true,
  install_dir: join_paths(get_option('datadir'), 'applications')
)

#Translate and install our .appdata file
i18n.merge_file(
  input: join_paths('data', meson.project_name() + '.appdata.xml.in'),
  output: meson.project_name() + '.appdata.xml',
  po_dir: join_paths(meson.source_root(), 'po'),
  install: true,
  install_dir: join_paths(get_option('datadir'), 'metainfo')
)

subdir('po')
subdir('data')

meson.add_install_script('meson/post_install.py')

