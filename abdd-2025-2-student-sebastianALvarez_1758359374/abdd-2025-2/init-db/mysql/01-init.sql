-- ============================================
-- GlobalShop - MySQL Database (Europa)
-- ============================================

-- Configurar timezone y charset
SET time_zone = '+00:00';
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- ============================================
-- Tabla: products (Catálogo de Productos)
-- ============================================
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category VARCHAR(100) NOT NULL,
    base_price DECIMAL(10,2) NOT NULL CHECK (base_price >= 0),
    description TEXT,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: inventory (Control de Inventario)
-- ============================================
CREATE TABLE inventory (
    inventory_id VARCHAR(50) PRIMARY KEY,
    product_id VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL CHECK (region IN ('AMERICA', 'EUROPE')),
    quantity INT NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    warehouse_code VARCHAR(50) NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_product (product_id),
    INDEX idx_region (region)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: customers (Clientes Globales)
-- ============================================
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    email VARCHAR(200) UNIQUE NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    country VARCHAR(100) NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_premium TINYINT(1) DEFAULT 0,
    last_purchase_date TIMESTAMP NULL,
    INDEX idx_email (email),
    INDEX idx_country (country)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
    is_active TINYINT(1) DEFAULT 1,
    CHECK (end_date >= start_date),
    INDEX idx_dates (start_date, end_date),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Índices adicionales para mejorar rendimiento
-- ============================================
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_active ON products(is_active);

-- ============================================
-- DATOS INICIALES - REGIÓN EUROPA
-- ============================================

-- Insertar productos iniciales (región Europa)
INSERT INTO products (product_id, product_name, category, base_price, description, is_active) VALUES
('PROD-EUR-001', 'Samsung Galaxy S24 Ultra', 'Electronics', 1199.99, 'Flagship Android smartphone', 1),
('PROD-EUR-002', 'Adidas Predator Elite', 'Footwear', 249.99, 'Professional football boots', 1),
('PROD-EUR-003', 'LG OLED 77" TV', 'Electronics', 2499.99, 'Premium OLED television', 1),
('PROD-EUR-004', 'Bose QuietComfort Ultra', 'Electronics', 429.99, 'Premium noise cancelling headphones', 1),
('PROD-EUR-005', 'Zara Premium Wool Coat', 'Clothing', 199.99, 'Winter coat from Spanish brand', 1),
('PROD-EUR-006', 'Bosch Serie 8 Coffee Machine', 'Home & Kitchen', 899.99, 'Fully automatic espresso machine', 1),
('PROD-EUR-007', 'Moncler Down Jacket', 'Clothing', 1299.99, 'Luxury winter jacket', 1),
('PROD-EUR-008', 'Miele Complete C3 Vacuum', 'Home & Kitchen', 799.99, 'Premium vacuum cleaner', 1),
('PROD-EUR-009', 'Garmin Fenix 7X', 'Electronics', 899.99, 'Premium multisport GPS watch', 1),
('PROD-EUR-010', 'Puma Future Ultimate', 'Footwear', 219.99, 'High-tech football boots', 1);

-- Insertar inventario para región Europa
INSERT INTO inventory (inventory_id, product_id, region, quantity, warehouse_code) VALUES
('INV-EUR-001', 'PROD-EUR-001', 'EUROPE', 200, 'WH-MADRID-01'),
('INV-EUR-002', 'PROD-EUR-002', 'EUROPE', 350, 'WH-MADRID-01'),
('INV-EUR-003', 'PROD-EUR-003', 'EUROPE', 65, 'WH-MADRID-02'),
('INV-EUR-004', 'PROD-EUR-004', 'EUROPE', 180, 'WH-MADRID-01'),
('INV-EUR-005', 'PROD-EUR-005', 'EUROPE', 420, 'WH-MADRID-03'),
('INV-EUR-006', 'PROD-EUR-006', 'EUROPE', 90, 'WH-MADRID-02'),
('INV-EUR-007', 'PROD-EUR-007', 'EUROPE', 110, 'WH-MADRID-03'),
('INV-EUR-008', 'PROD-EUR-008', 'EUROPE', 75, 'WH-MADRID-02'),
('INV-EUR-009', 'PROD-EUR-009', 'EUROPE', 140, 'WH-MADRID-01'),
('INV-EUR-010', 'PROD-EUR-010', 'EUROPE', 290, 'WH-MADRID-03');

-- Insertar clientes (región Europa)
INSERT INTO customers (customer_id, email, full_name, country, is_premium, last_purchase_date) VALUES
('CUST-EUR-001', 'pierre.dubois@email.fr', 'Pierre Dubois', 'France', 1, '2026-01-16 10:20:00'),
('CUST-EUR-002', 'maria.rossi@email.it', 'Maria Rossi', 'Italy', 0, '2026-01-21 14:35:00'),
('CUST-EUR-003', 'hans.mueller@email.de', 'Hans Mueller', 'Germany', 1, '2026-01-17 12:50:00'),
('CUST-EUR-004', 'sofia.lopez@email.es', 'Sofia Lopez', 'Spain', 1, '2026-01-23 16:15:00'),
('CUST-EUR-005', 'james.taylor@email.uk', 'James Taylor', 'United Kingdom', 0, '2026-01-26 11:40:00'),
('CUST-EUR-006', 'anna.kowalski@email.pl', 'Anna Kowalski', 'Poland', 0, '2026-01-19 09:25:00'),
('CUST-EUR-007', 'carlos.santos@email.pt', 'Carlos Santos', 'Portugal', 1, '2026-01-27 15:55:00');

-- Insertar promociones (región Europa)
INSERT INTO promotions (promotion_id, promotion_name, discount_percentage, start_date, end_date, applicable_regions, is_active) VALUES
('PROMO-EUR-001', 'Winter Clearance', 35.00, '2026-01-15', '2026-02-15', 'EUROPE', 1),
('PROMO-EUR-002', 'Tech Tuesday', 20.00, '2026-01-20', '2026-02-28', 'EUROPE', 1),
('PROMO-EUR-003', 'Summer Preview', 25.00, '2026-05-01', '2026-05-31', 'GLOBAL', 0),
('PROMO-EUR-004', 'Back to School', 30.00, '2026-08-15', '2026-09-15', 'EUROPE', 0);

-- ============================================
-- Información de resumen
-- ============================================
SELECT 
    '=================================================' AS '';
SELECT 
    'GlobalShop MySQL Database - Initialized' AS '';
SELECT 
    '=================================================' AS '';
SELECT 
    CONCAT('Products: ', COUNT(*), ' records') AS ''
FROM products;
SELECT 
    CONCAT('Inventory: ', COUNT(*), ' records') AS ''
FROM inventory;
SELECT 
    CONCAT('Customers: ', COUNT(*), ' records') AS ''
FROM customers;
SELECT 
    CONCAT('Promotions: ', COUNT(*), ' records') AS ''
FROM promotions;
SELECT 
    '=================================================' AS '';
SELECT 
    'Database is ready for SymmetricDS replication' AS '';
SELECT 
    '=================================================' AS '';
