/*
* Copyright (c) 2018 David Howell <david@dynamicmethods.com.au>
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

namespace Peeq.Services {
  public enum PostgresObject {
    EXTENSION,
    TABLE,
    FUNCTION,
    VIEW,
    TRIGGER,
    COLUMN,
    SCHEMA,
    SEQUENCE
  }

  public const string TABLES_SQL = """
    SELECT 
    table_schema, table_name 
    FROM  information_schema.tables 
    WHERE table_type = 'BASE TABLE' AND table_schema NOT IN ('pg_catalog', 'information_schema')
    ORDER BY table_schema, table_name;
  """;

  public const string VIEWS_SQL = """
    SELECT 
    table_schema, table_name, view_definition
    FROM  information_schema.views 
    WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
    ORDER BY table_schema, table_name;
  """;

  public const string FUNCTIONS_SQL = """
    SELECT
    routine_schema, routine_name, routine_definition
    FROM information_schema.routines 
    WHERE routine_type = 'FUNCTION'
    AND routine_schema NOT IN ('pg_catalog', 'information_schema')
    AND external_name IS NULL
    ORDER BY routine_name;
  """;

  public const string DATABASE_LIST = """
    SELECT
      datname AS db_name,
      CASE 
        WHEN pg_catalog.has_database_privilege(datname, 'CONNECT')
        THEN pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(datname))
        ELSE 'N/A'
      END AS db_size
    FROM pg_catalog.pg_database ORDER BY db_name
  """;
}