CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(200),
    category VARCHAR(100),
    base_price DECIMAL(10,2),
    description TEXT,
    is_active BOOLEAN,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE inventory (
    inventory_id VARCHAR(50) PRIMARY KEY,
    product_id VARCHAR(50) REFERENCES products(product_id),
    region VARCHAR(50),
    quantity INTEGER,
    warehouse_code VARCHAR(50),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    email VARCHAR(200) UNIQUE,
    full_name VARCHAR(200),
    country VARCHAR(100),
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_premium BOOLEAN,
    last_purchase_date TIMESTAMP
);

CREATE TABLE promotions (
    promotion_id VARCHAR(50) PRIMARY KEY,
    promotion_name VARCHAR(200),
    discount_percentage DECIMAL(5,2),
    start_date DATE,
    end_date DATE,
    applicable_regions VARCHAR(100),
    is_active BOOLEAN
);

-- Nodos
INSERT INTO sym_node_group (node_group_id, description) 
VALUES ('america-store', 'America region'), ('europe-store', 'Europe region');

INSERT INTO sym_node_group_link (source_node_group_id, target_node_group_id, data_event_action) 
VALUES ('america-store', 'europe-store', 'W'), ('europe-store', 'america-store', 'W'); -- W es obligatorio [cite: 8, 25]

-- Canales
INSERT INTO sym_channel (channel_id, processing_order, max_batch_size, enabled, description) VALUES 
('products_channel', 10, 1000, 1, 'Canal de productos'),
('inventory_channel', 20, 1000, 1, 'Canal de inventario'),
('customers_channel', 30, 1000, 1, 'Canal de clientes'),
('promotions_channel', 40, 1000, 1, 'Canal de promociones');

-- Triggers
INSERT INTO sym_trigger (trigger_id, source_table_name, channel_id, last_update_time, create_time) VALUES 
('products_trigger', 'products', 'products_channel', current_timestamp, current_timestamp),
('inventory_trigger', 'inventory', 'inventory_channel', current_timestamp, current_timestamp),
('customers_trigger', 'customers', 'customers_channel', current_timestamp, current_timestamp),
('promotions_trigger', 'promotions', 'promotions_channel', current_timestamp, current_timestamp);

-- Routers
INSERT INTO sym_router (router_id, source_node_group_id, target_node_group_id, router_type, create_time, last_update_time) VALUES 
('america_to_europe', 'america-store', 'europe-store', 'default', current_timestamp, current_timestamp),
('europe_to_america', 'europe-store', 'america-store', 'default', current_timestamp, current_timestamp);

-- Asignación de triggers a routers
INSERT INTO sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time) 
VALUES 
('products_trigger', 'america_to_europe', 100, current_timestamp, current_timestamp),
('products_trigger', 'europe_to_america', 105, current_timestamp, current_timestamp),
('inventory_trigger', 'america_to_europe', 200, current_timestamp, current_timestamp),
('inventory_trigger', 'europe_to_america', 205, current_timestamp, current_timestamp),
('customers_trigger', 'america_to_europe', 300, current_timestamp, current_timestamp),
('customers_trigger', 'europe_to_america', 305, current_timestamp, current_timestamp),
('promotions_trigger', 'america_to_europe', 400, current_timestamp, current_timestamp),
('promotions_trigger', 'europe_to_america', 405, current_timestamp, current_timestamp);