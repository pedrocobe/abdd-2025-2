-- Insertar productos de Europa que faltan
INSERT INTO products (product_id, product_name, category, base_price, description, is_active) VALUES
('PROD-EUR-001', 'Samsung Galaxy S24 Ultra', 'Electronics', 1199.99, 'Flagship Android smartphone', true),
('PROD-EUR-002', 'Adidas Predator Elite', 'Footwear', 249.99, 'Professional football boots', true),
('PROD-EUR-003', 'LG OLED 77 TV', 'Electronics', 2499.99, 'Premium OLED television', true),
('PROD-EUR-004', 'Bose QuietComfort Ultra', 'Electronics', 429.99, 'Premium noise cancelling headphones', true),
('PROD-EUR-005', 'Zara Premium Wool Coat', 'Clothing', 199.99, 'Winter coat from Spanish brand', true),
('PROD-EUR-006', 'Bosch Serie 8 Coffee Machine', 'Home & Kitchen', 899.99, 'Fully automatic espresso machine', true),
('PROD-EUR-007', 'Moncler Down Jacket', 'Clothing', 1299.99, 'Luxury winter jacket', true),
('PROD-EUR-008', 'Miele Complete C3 Vacuum', 'Home & Kitchen', 799.99, 'Premium vacuum cleaner', true),
('PROD-EUR-009', 'Garmin Fenix 7X', 'Electronics', 899.99, 'Premium multisport GPS watch', true),
('PROD-EUR-010', 'Puma Future Ultimate', 'Footwear', 219.99, 'High-tech football boots', true)
ON CONFLICT (product_id) DO NOTHING;

-- Insertar inventario de Europa
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
('INV-EUR-010', 'PROD-EUR-010', 'EUROPE', 290, 'WH-MADRID-03')
ON CONFLICT (inventory_id) DO NOTHING;

-- Insertar clientes de Europa
INSERT INTO customers (customer_id, email, full_name, country, is_premium, last_purchase_date) VALUES
('CUST-EUR-001', 'pierre.dubois@email.fr', 'Pierre Dubois', 'France', true, '2026-01-16 10:20:00'),
('CUST-EUR-002', 'maria.rossi@email.it', 'Maria Rossi', 'Italy', false, '2026-01-21 14:35:00'),
('CUST-EUR-003', 'hans.mueller@email.de', 'Hans Mueller', 'Germany', true, '2026-01-17 12:50:00'),
('CUST-EUR-004', 'sofia.lopez@email.es', 'Sofia Lopez', 'Spain', true, '2026-01-23 16:15:00'),
('CUST-EUR-005', 'james.taylor@email.uk', 'James Taylor', 'United Kingdom', false, '2026-01-26 11:40:00'),
('CUST-EUR-006', 'anna.kowalski@email.pl', 'Anna Kowalski', 'Poland', false, '2026-01-19 09:25:00'),
('CUST-EUR-007', 'carlos.santos@email.pt', 'Carlos Santos', 'Portugal', true, '2026-01-27 15:55:00')
ON CONFLICT (customer_id) DO NOTHING;

-- Insertar promociones de Europa
INSERT INTO promotions (promotion_id, promotion_name, discount_percentage, start_date, end_date, applicable_regions, is_active) VALUES
('PROMO-EUR-001', 'Winter Clearance', 35.00, '2026-01-15', '2026-02-15', 'EUROPE', true),
('PROMO-EUR-002', 'Tech Tuesday', 20.00, '2026-01-20', '2026-02-28', 'EUROPE', true),
('PROMO-EUR-003', 'Summer Preview', 25.00, '2026-05-01', '2026-05-31', 'GLOBAL', false),
('PROMO-EUR-004', 'Back to School', 30.00, '2026-08-15', '2026-09-15', 'EUROPE', false)
ON CONFLICT (promotion_id) DO NOTHING;
