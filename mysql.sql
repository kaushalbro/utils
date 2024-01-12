// to select foreign key in table:
                SELECT
                CONSTRAINT_NAME,
                COLUMN_NAME,
                REFERENCED_TABLE_NAME,
                REFERENCED_COLUMN_NAME
              FROM
                INFORMATION_SCHEMA.KEY_COLUMN_USAGE
              WHERE
                TABLE_NAME = 'product_operations' AND
                CONSTRAINT_NAME <> 'PRIMARY' AND
                CONSTRAINT_NAME LIKE '%_foreign';

-- Drop the 'sequence_number' column
ALTER TABLE product_operations DROP COLUMN sequence_number;

-- Add the 'user_id' column
ALTER TABLE product_operations ADD COLUMN user_id INT UNSIGNED NULL;

-- Add foreign key constraint on 'user_id'
ALTER TABLE product_operations ADD CONSTRAINT fk_product_operations_user_id
FOREIGN KEY (user_id) REFERENCES users (id);

-- Add 'created_by', 'updated_by', 'deleted_by' columns
ALTER TABLE product_operations ADD COLUMN created_by INT UNSIGNED NULL;
ALTER TABLE product_operations ADD COLUMN updated_by INT UNSIGNED NULL;
ALTER TABLE product_operations ADD COLUMN deleted_by INT UNSIGNED NULL;

-- Add foreign key constraints on 'created_by', 'updated_by', 'deleted_by'
ALTER TABLE product_operations ADD CONSTRAINT fk_product_operations_created_by
FOREIGN KEY (created_by) REFERENCES users (id);

ALTER TABLE product_operations ADD CONSTRAINT fk_product_operations_updated_by
FOREIGN KEY (updated_by) REFERENCES users (id);

ALTER TABLE product_operations ADD CONSTRAINT fk_product_operations_deleted_by
FOREIGN KEY (deleted_by) REFERENCES users (id);




-- Change the 'purchase_order_id' column to non-nullable
ALTER TABLE goods_ins MODIFY COLUMN purchase_order_id INT UNSIGNED NOT NULL;
