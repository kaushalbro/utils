// to select foreign key in table:
                SELECT
                CONSTRAINT_NAME,
                COLUMN_NAME,
                REFERENCED_TABLE_NAME,
                REFERENCED_COLUMN_NAME
              FROM
                INFORMATION_SCHEMA.KEY_COLUMN_USAGE
              WHERE
                TABLE_NAME = 'manufacture_orders' AND
                CONSTRAINT_NAME <> 'PRIMARY' AND
                CONSTRAINT_NAME LIKE '%_foreign';

