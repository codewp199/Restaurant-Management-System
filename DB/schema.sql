-- ====================================================
-- Restaurant Management System - Schema
-- Database: restaurant_db
-- Author: Team 7
-- ====================================================

-- Drop tables if re-running (be careful in production!)
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS menu_items CASCADE;
DROP TABLE IF EXISTS menu_categories CASCADE;
DROP TABLE IF EXISTS dining_tables CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS roles CASCADE;

-- =====================
-- 1. Roles (Waiter, Chef, Cashier, Manager)
-- =====================
CREATE TABLE roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL
);

-- =====================
-- 2. Users (Staff accounts)
-- =====================
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(200) NOT NULL, -- hashed in real apps
    role_id INT REFERENCES roles(role_id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =====================
-- 3. Dining Tables
-- =====================
CREATE TABLE dining_tables (
    table_id SERIAL PRIMARY KEY,
    table_number INT UNIQUE NOT NULL,
    is_occupied BOOLEAN DEFAULT FALSE,
    capacity INT NOT NULL
);

-- =====================
-- 4. Menu Categories (Starters, Main Course, Drinks, Desserts)
-- =====================
CREATE TABLE menu_categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE NOT NULL
);

-- =====================
-- 5. Menu Items
-- =====================
CREATE TABLE menu_items (
    item_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    category_id INT REFERENCES menu_categories(category_id) ON DELETE CASCADE,
    is_available BOOLEAN DEFAULT TRUE
);

-- =====================
-- 6. Orders
-- =====================
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    table_id INT REFERENCES dining_tables(table_id) ON DELETE SET NULL,
    waiter_id INT REFERENCES users(user_id) ON DELETE SET NULL,
    order_ref VARCHAR(50) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'NEW' CHECK (status IN ('NEW', 'IN_PROGRESS', 'DONE', 'SETTLED')),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================
-- 7. Order Items
-- =====================
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    menu_item_id INT REFERENCES menu_items(item_id) ON DELETE CASCADE,
    quantity INT NOT NULL CHECK (quantity > 0),
    notes TEXT,
    status VARCHAR(20) DEFAULT 'NEW' CHECK (status IN ('NEW', 'IN_PROGRESS', 'DONE'))
);

-- =====================
-- 8. Payments
-- =====================
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL,
    tax DECIMAL(10,2) DEFAULT 0,
    service_charge DECIMAL(10,2) DEFAULT 0,
    method VARCHAR(20) CHECK (method IN ('CASH', 'CARD', 'UPI')),
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PAID', 'FAILED')),
    paid_at TIMESTAMP
);

-- =====================
-- Indexes for performance
-- =====================
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_items_status ON order_items(status);
CREATE INDEX idx_menu_category ON menu_items(category_id);

-- Done
