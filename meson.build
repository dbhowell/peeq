# project name and programming language
project('com.github.dbhowell.peeq', 'vala', 'c', version: '0.5.0')

# Include the translations module
i18n = import('i18n')

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

subdir('src')

subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')
