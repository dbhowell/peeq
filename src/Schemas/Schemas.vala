namespace Peeq.Schemas {
    public const string SCHEMAS_SQL = """
      SELECT 
        CASE 
          WHEN nspname LIKE E'PG\\\\_temp\\\\_%' THEN 1
          WHEN (nspname LIKE E'pg\\\\_%') THEN 0
          ELSE 3 
        END AS nsptyp,
        nsp.nspname, 
        nsp.oid, 
        pg_get_userbyid(nspowner) AS namespaceowner, 
        nspacl, 
        description,
        has_schema_privilege(nsp.oid, 'CREATE') AS cancreate
      FROM pg_namespace nsp
      LEFT OUTER JOIN pg_description des ON (des.objoid=nsp.oid AND des.classoid='pg_namespace'::regclass)
      ORDER BY 1, nspname;
    """;

    public const string EXTENSIONS_SQL = """
        SELECT 
            x.oid, 
            x.extname, 
            x.extversion,
            pg_get_userbyid(extowner) AS owner, 
            n.nspname, 
            x.extrelocatable,         
            e.comment
        FROM pg_extension x
        JOIN pg_namespace n on x.extnamespace=n.oid
        join pg_available_extensions() e(name, default_version, comment) ON x.extname=e.name
        ORDER BY x.extname;
    """;

    public const string SEQUENCES_SQL = """
        SELECT 
            cl.oid, 
            relname, 
            pg_get_userbyid(relowner) AS seqowner, 
            relacl, 
            description,
            relnamespace,
            (SELECT array_agg(label) FROM pg_seclabels sl1 WHERE sl1.objoid=cl.oid) AS labels,
            (SELECT array_agg(provider) FROM pg_seclabels sl2 WHERE sl2.objoid=cl.oid) AS providers
        FROM pg_class cl
        LEFT OUTER JOIN pg_description des ON (des.objoid=cl.oid AND des.classoid='pg_class'::regclass)
        WHERE relkind = 'S'
        ORDER BY relname;
    """;

    public class SchemaCommand : Peeq.Services.QueryCommand {

        public SchemaCommand.with_connection (Services.Connection connection) {
            base.with_connection (connection);  
        }

        public void run () {
            this.execute (SCHEMAS_SQL);
        }
    }

    public class ExtensionCommand : Peeq.Services.QueryCommand {

        public ExtensionCommand.with_connection (Services.Connection connection) {
            base.with_connection (connection);  
        }

        public void run () {
            this.execute (EXTENSIONS_SQL);
        }
    }

    public class SequenceCommand : Peeq.Services.QueryCommand {

        public SequenceCommand.with_connection (Services.Connection connection) {
            base.with_connection (connection);  
        }

        public void run () {
            this.execute (SEQUENCES_SQL);
        }
    }
}