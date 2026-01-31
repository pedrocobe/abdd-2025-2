-- ============================================
-- GlobalShop - PostgreSQL Database (América)
-- ============================================

-- Crear extensión para UUIDs si es necesaria
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- Tabla: products (Catálogo de Productos)
-- ============================================
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category VARCHAR(100) NOT NULL,
    base_price DECIMAL(10,2) NOT NULL CHECK (base_price >= 0),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- Tabla: inventory (Control de Inventario)
-- ============================================
CREATE TABLE inventory (
    inventory_id VARCHAR(50) PRIMARY KEY,
    product_id VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL CHECK (region IN ('AMERICA', 'EUROPE')),
    quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    warehouse_code VARCHAR(50) NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- ============================================
-- Tabla: customers (Clientes Globales)
-- ============================================
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    email VARCHAR(200) UNIQUE NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    country VARCHAR(100) NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_premium BOOLEAN DEFAULT false,
    last_purchase_date TIMESTAMP
);

-- ============================================
-- Tabla: promotions (Promociones y Descuentos)
-- ============================================
CREATE TABLE promotions (
    promotion_id VARCHAR(50) PRIMARY KEY,
    promotion_name VARCHAR(200) NOT NULL,
    discount_percentage DECIMAL(5,2) NOT NULL CHECK (discount_percentage >= 0 AND discount_percentage <= 100),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    applicable_regions VARCHAR(100) NOT NULL CHECK (applicable_regions IN ('AMERICA', 'EUROPE', 'GLOBAL')),
    is_active BOOLEAN DEFAULT true,
    CHECK (end_date >= start_date)
);

-- ============================================
-- Índices para mejorar rendimiento
-- ============================================
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_active ON products(is_active);
CREATE INDEX idx_inventory_product ON inventory(product_id);
CREATE INDEX idx_inventory_region ON inventory(region);
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_country ON customers(country);
CREATE INDEX idx_promotions_dates ON promotions(start_date, end_date);
CREATE INDEX idx_promotions_active ON promotions(is_active);

-- ============================================
-- Función para actualizar updated_at automáticamente
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para products
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger para inventory
CREATE OR REPLACE FUNCTION update_inventory_last_updated()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_inventory_last_updated BEFORE UPDATE ON inventory
    FOR EACH ROW EXECUTE FUNCTION update_inventory_last_updated();

-- ============================================
-- DATOS INICIALES - REGIÓN AMÉRICA
-- ============================================

-- Insertar productos iniciales
INSERT INTO products (product_id, product_name, category, base_price, description, is_active) VALUES
('PROD-USA-001', 'iPhone 15 Pro', 'Electronics', 999.99, 'Latest Apple smartphone with A17 chip', true),
('PROD-USA-002', 'Nike Air Max 2024', 'Footwear', 189.99, 'Premium running shoes', true),
('PROD-USA-003', 'Samsung 65" QLED TV', 'Electronics', 1299.99, '4K Smart TV with quantum dot technology', true),
('PROD-USA-004', 'Sony WH-1000XM5', 'Electronics', 399.99, 'Noise cancelling headphones', true),
('PROD-USA-005', 'Levi''s 501 Original Jeans', 'Clothing', 89.99, 'Classic straight fit jeans', true),
('PROD-USA-006', 'KitchenAid Stand Mixer', 'Home & Kitchen', 449.99, 'Professional 5-quart mixer', true),
('PROD-USA-007', 'The North Face Jacket', 'Clothing', 299.99, 'Waterproof winter jacket', true),
('PROD-USA-008', 'Dyson V15 Vacuum', 'Home & Kitchen', 649.99, 'Cordless vacuum with laser detection', true),
('PROD-USA-009', 'Apple Watch Series 9', 'Electronics', 429.99, 'Smartwatch with health monitoring', true),
('PROD-USA-010', 'Adidas Ultraboost 23', 'Footwear', 179.99, 'High-performance running shoes', true);

-- Insertar inventario para región América
INSERT INTO inventory (inventory_id, product_id, region, quantity, warehouse_code) VALUES
('INV-USA-001', 'PROD-USA-001', 'AMERICA', 150, 'WH-MIAMI-01'),
('INV-USA-002', 'PROD-USA-002', 'AMERICA', 320, 'WH-MIAMI-01'),
('INV-USA-003', 'PROD-USA-003', 'AMERICA', 85, 'WH-MIAMI-02'),
('INV-USA-004', 'PROD-USA-004', 'AMERICA', 200, 'WH-MIAMI-01'),
('INV-USA-005', 'PROD-USA-005', 'AMERICA', 450, 'WH-MIAMI-03'),
('INV-USA-006', 'PROD-USA-006', 'AMERICA', 120, 'WH-MIAMI-02'),
('INV-USA-007', 'PROD-USA-007', 'AMERICA', 180, 'WH-MIAMI-03'),
('INV-USA-008', 'PROD-USA-008', 'AMERICA', 95, 'WH-MIAMI-02'),
('INV-USA-009', 'PROD-USA-009', 'AMERICA', 175, 'WH-MIAMI-01'),
('INV-USA-010', 'PROD-USA-010', 'AMERICA', 280, 'WH-MIAMI-03');

-- Insertar clientes
INSERT INTO customers (customer_id, email, full_name, country, is_premium, last_purchase_date) VALUES
('CUST-USA-001', 'john.smith@email.com', 'John Smith', 'United States', true, '2026-01-15 14:30:00'),
('CUST-USA-002', 'maria.garcia@email.com', 'Maria Garcia', 'Mexico', false, '2026-01-20 10:15:00'),
('CUST-USA-003', 'robert.johnson@email.com', 'Robert Johnson', 'Canada', true, '2026-01-18 16:45:00'),
('CUST-USA-004', 'ana.silva@email.com', 'Ana Silva', 'Brazil', false, '2026-01-22 11:20:00'),
('CUST-USA-005', 'michael.brown@email.com', 'Michael Brown', 'United States', true, '2026-01-25 09:30:00'),
('CUST-USA-006', 'lucia.martinez@email.com', 'Lucia Martinez', 'Argentina', false, '2026-01-19 15:10:00'),
('CUST-USA-007', 'david.wilson@email.com', 'David Wilson', 'United States', true, '2026-01-24 13:25:00'),
('CUST-USA-008', 'carmen.rodriguez@email.com', 'Carmen Rodriguez', 'Chile', false, NULL);

-- Insertar promociones
INSERT INTO promotions (promotion_id, promotion_name, discount_percentage, start_date, end_date, applicable_regions, is_active) VALUES
('PROMO-USA-001', 'New Year Sale', 25.00, '2026-01-01', '2026-01-31', 'AMERICA', true),
('PROMO-USA-002', 'Electronics Week', 15.00, '2026-01-20', '2026-01-27', 'AMERICA', true),
('PROMO-USA-003', 'Spring Fashion', 30.00, '2026-03-01', '2026-03-31', 'GLOBAL', true),
('PROMO-USA-004', 'Black Friday Preview', 40.00, '2026-11-20', '2026-11-30', 'GLOBAL', false);

-- ============================================
-- Información de resumen
-- ============================================
DO $$
DECLARE
    product_count INTEGER;
    inventory_count INTEGER;
    customer_count INTEGER;
    promotion_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO product_count FROM products;
    SELECT COUNT(*) INTO inventory_count FROM inventory;
    SELECT COUNT(*) INTO customer_count FROM customers;
    SELECT COUNT(*) INTO promotion_count FROM promotions;
    
    RAISE NOTICE '=================================================';
    RAISE NOTICE 'GlobalShop PostgreSQL Database - Initialized';
    RAISE NOTICE '=================================================';
    RAISE NOTICE 'Products: % records', product_count;
    RAISE NOTICE 'Inventory: % records', inventory_count;
    RAISE NOTICE 'Customers: % records', customer_count;
    RAISE NOTICE 'Promotions: % records', promotion_count;
    RAISE NOTICE '=================================================';
    RAISE NOTICE 'Database is ready for SymmetricDS replication';
    RAISE NOTICE '=================================================';
END $$;
