-- Circlo database
-- Recommended: MySQL 8.0+ / MariaDB 10.4+
-- Import this file using phpMyAdmin or the MySQL command line.

CREATE DATABASE IF NOT EXISTS circlo_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE circlo_db;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS activity_logs;
DROP TABLE IF EXISTS donation_offers;
DROP TABLE IF EXISTS assistance_needs;
DROP TABLE IF EXISTS assistance_requests;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS item_requests;
DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS disaster_incidents;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users (
    user_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(190) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(30) NULL,
    barangay VARCHAR(120) NULL,
    city VARCHAR(120) NULL,
    province VARCHAR(120) NULL,
    role ENUM('member', 'admin') NOT NULL DEFAULT 'member',
    account_status ENUM('active', 'suspended') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_users_role_status (role, account_status)
) ENGINE=InnoDB;

CREATE TABLE categories (
    category_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255) NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE disaster_incidents (
    incident_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(180) NOT NULL,
    disaster_type ENUM('fire', 'flood', 'typhoon', 'earthquake', 'landslide', 'other') NOT NULL,
    description TEXT NOT NULL,
    barangay VARCHAR(120) NOT NULL,
    city VARCHAR(120) NOT NULL,
    province VARCHAR(120) NOT NULL,
    incident_date DATE NOT NULL,
    incident_status ENUM('reported', 'verified', 'active', 'resolved', 'rejected') NOT NULL DEFAULT 'reported',
    reported_by BIGINT UNSIGNED NOT NULL,
    verified_by BIGINT UNSIGNED NULL,
    verified_at DATETIME NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_incidents_reporter FOREIGN KEY (reported_by) REFERENCES users(user_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_incidents_verifier FOREIGN KEY (verified_by) REFERENCES users(user_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    INDEX idx_incidents_status_type (incident_status, disaster_type),
    INDEX idx_incidents_location (province, city, barangay),
    INDEX idx_incidents_date (incident_date)
) ENGINE=InnoDB;

CREATE TABLE items (
    item_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    owner_id BIGINT UNSIGNED NOT NULL,
    category_id INT UNSIGNED NOT NULL,
    incident_id BIGINT UNSIGNED NULL,
    title VARCHAR(160) NOT NULL,
    description TEXT NOT NULL,
    listing_type ENUM('sale', 'donation', 'exchange', 'disaster_donation') NOT NULL,
    item_condition ENUM('new', 'like_new', 'good', 'fair', 'for_repair') NOT NULL,
    price DECIMAL(10,2) NULL,
    quantity INT UNSIGNED NOT NULL DEFAULT 1,
    image_path VARCHAR(255) NULL,
    barangay VARCHAR(120) NULL,
    city VARCHAR(120) NULL,
    province VARCHAR(120) NULL,
    listing_status ENUM('available', 'reserved', 'completed', 'hidden', 'rejected') NOT NULL DEFAULT 'available',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_items_owner FOREIGN KEY (owner_id) REFERENCES users(user_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_items_category FOREIGN KEY (category_id) REFERENCES categories(category_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_items_incident FOREIGN KEY (incident_id) REFERENCES disaster_incidents(incident_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    INDEX idx_items_search (listing_status, listing_type, category_id),
    INDEX idx_items_owner (owner_id),
    INDEX idx_items_location (province, city, barangay),
    INDEX idx_items_created (created_at)
) ENGINE=InnoDB;

CREATE TABLE item_requests (
    item_request_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    item_id BIGINT UNSIGNED NOT NULL,
    requester_id BIGINT UNSIGNED NOT NULL,
    message VARCHAR(1000) NULL,
    request_status ENUM('pending', 'accepted', 'declined', 'cancelled', 'completed') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_item_requests_item FOREIGN KEY (item_id) REFERENCES items(item_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_item_requests_requester FOREIGN KEY (requester_id) REFERENCES users(user_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_item_requests_item_status (item_id, request_status),
    INDEX idx_item_requests_requester (requester_id),
    INDEX idx_item_requests_created (created_at)
) ENGINE=InnoDB;

CREATE TABLE transactions (
    transaction_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    item_request_id BIGINT UNSIGNED NOT NULL UNIQUE,
    item_id BIGINT UNSIGNED NOT NULL,
    provider_id BIGINT UNSIGNED NOT NULL,
    recipient_id BIGINT UNSIGNED NOT NULL,
    transaction_type ENUM('sale', 'donation', 'exchange', 'disaster_donation') NOT NULL,
    amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    transaction_status ENUM('pending_handover', 'completed', 'cancelled') NOT NULL DEFAULT 'pending_handover',
    completed_at DATETIME NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_transactions_request FOREIGN KEY (item_request_id) REFERENCES item_requests(item_request_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_transactions_item FOREIGN KEY (item_id) REFERENCES items(item_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_transactions_provider FOREIGN KEY (provider_id) REFERENCES users(user_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_transactions_recipient FOREIGN KEY (recipient_id) REFERENCES users(user_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_transactions_status (transaction_status),
    INDEX idx_transactions_created (created_at)
) ENGINE=InnoDB;

CREATE TABLE assistance_requests (
    assistance_request_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    incident_id BIGINT UNSIGNED NOT NULL,
    requester_id BIGINT UNSIGNED NOT NULL,
    people_affected SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    situation_description TEXT NOT NULL,
    urgency ENUM('critical', 'high', 'normal') NOT NULL DEFAULT 'normal',
    privacy_note VARCHAR(500) NULL,
    request_status ENUM('pending', 'verified', 'matched', 'partially_fulfilled', 'fulfilled', 'rejected') NOT NULL DEFAULT 'pending',
    reviewed_by BIGINT UNSIGNED NULL,
    reviewed_at DATETIME NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_assistance_incident FOREIGN KEY (incident_id) REFERENCES disaster_incidents(incident_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_assistance_requester FOREIGN KEY (requester_id) REFERENCES users(user_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_assistance_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(user_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    INDEX idx_assistance_status_urgency (request_status, urgency),
    INDEX idx_assistance_requester (requester_id),
    INDEX idx_assistance_incident (incident_id)
) ENGINE=InnoDB;

CREATE TABLE assistance_needs (
    need_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    assistance_request_id BIGINT UNSIGNED NOT NULL,
    category_id INT UNSIGNED NULL,
    item_name VARCHAR(140) NOT NULL,
    quantity_needed INT UNSIGNED NOT NULL,
    quantity_fulfilled INT UNSIGNED NOT NULL DEFAULT 0,
    notes VARCHAR(500) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_needs_assistance FOREIGN KEY (assistance_request_id) REFERENCES assistance_requests(assistance_request_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_needs_category FOREIGN KEY (category_id) REFERENCES categories(category_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    INDEX idx_needs_assistance (assistance_request_id)
) ENGINE=InnoDB;

CREATE TABLE donation_offers (
    donation_offer_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    assistance_request_id BIGINT UNSIGNED NOT NULL,
    donor_id BIGINT UNSIGNED NOT NULL,
    item_id BIGINT UNSIGNED NULL,
    offered_item_name VARCHAR(140) NOT NULL,
    quantity INT UNSIGNED NOT NULL DEFAULT 1,
    donor_message VARCHAR(1000) NULL,
    offer_status ENUM('offered', 'accepted', 'declined', 'ready_for_pickup', 'completed', 'cancelled') NOT NULL DEFAULT 'offered',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_offers_assistance FOREIGN KEY (assistance_request_id) REFERENCES assistance_requests(assistance_request_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_offers_donor FOREIGN KEY (donor_id) REFERENCES users(user_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_offers_item FOREIGN KEY (item_id) REFERENCES items(item_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    INDEX idx_offers_assistance_status (assistance_request_id, offer_status),
    INDEX idx_offers_donor (donor_id)
) ENGINE=InnoDB;

CREATE TABLE activity_logs (
    activity_log_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    actor_id BIGINT UNSIGNED NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(80) NOT NULL,
    entity_id BIGINT UNSIGNED NULL,
    details TEXT NULL,
    ip_address VARCHAR(45) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_activity_actor FOREIGN KEY (actor_id) REFERENCES users(user_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    INDEX idx_activity_actor (actor_id),
    INDEX idx_activity_entity (entity_type, entity_id),
    INDEX idx_activity_created (created_at)
) ENGINE=InnoDB;

INSERT INTO categories (category_name, description) VALUES
('Clothing and Footwear', 'Clothes, shoes, bags, and wearable items'),
('Food and Water', 'Packaged food, drinking water, and basic food supplies'),
('Furniture', 'Tables, chairs, beds, cabinets, and other furniture'),
('Appliances and Electronics', 'Working household appliances and electronic devices'),
('School and Office Supplies', 'Books, notebooks, pens, and learning materials'),
('Hygiene and Personal Care', 'Soap, hygiene kits, and personal care supplies'),
('Cleaning and Repair Supplies', 'Cleaning tools and basic repair materials'),
('Other', 'Useful items not covered by other categories');

-- No default administrator password is inserted.
-- Register a normal account first, then promote it using the safe procedure
-- described in README.md. Never use a publicly known default admin password.
