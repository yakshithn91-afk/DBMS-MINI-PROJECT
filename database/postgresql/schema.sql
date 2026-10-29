-- ============================================
-- DIGITAL TWIN - SMART BUILDINGS
-- PostgreSQL Database Schema
-- ============================================

-- BUILDINGS
CREATE TABLE buildings (
    building_id SERIAL PRIMARY KEY,
    building_name VARCHAR(100) NOT NULL,
    building_code VARCHAR(20) UNIQUE NOT NULL,
    location VARCHAR(200),
    total_floors INTEGER,
    description TEXT
);

-- FLOORS
CREATE TABLE floors (
    floor_id SERIAL PRIMARY KEY,
    building_id INTEGER NOT NULL,
    floor_number INTEGER NOT NULL,
    floor_name VARCHAR(100),

    CONSTRAINT fk_floor_building
        FOREIGN KEY (building_id)
        REFERENCES buildings(building_id)
        ON DELETE CASCADE,

    CONSTRAINT unique_building_floor
        UNIQUE (building_id, floor_number)
);

-- ROOMS
CREATE TABLE rooms (
    room_id SERIAL PRIMARY KEY,
    floor_id INTEGER NOT NULL,
    room_number VARCHAR(20) NOT NULL,
    room_name VARCHAR(100),
    room_type VARCHAR(50),
    capacity INTEGER,
    area_sqft DECIMAL(10,2),
    description TEXT,

    CONSTRAINT fk_room_floor
        FOREIGN KEY (floor_id)
        REFERENCES floors(floor_id)
        ON DELETE CASCADE,

    CONSTRAINT unique_room_per_floor
        UNIQUE (floor_id, room_number)
);

-- FACILITIES
CREATE TABLE facilities (
    facility_id SERIAL PRIMARY KEY,
    room_id INTEGER NOT NULL,
    facility_name VARCHAR(100) NOT NULL,
    quantity INTEGER DEFAULT 1,
    status VARCHAR(30) DEFAULT 'Available',

    CONSTRAINT fk_facility_room
        FOREIGN KEY (room_id)
        REFERENCES rooms(room_id)
        ON DELETE CASCADE
);