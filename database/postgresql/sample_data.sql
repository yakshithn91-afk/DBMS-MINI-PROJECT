-- ============================================
-- DIGITAL TWIN - SMART BUILDINGS
-- PostgreSQL Sample Data
-- ============================================

-- ============================================
-- BUILDINGS
-- ============================================

INSERT INTO buildings
(building_name, building_code, location, total_floors, description)
VALUES
('Main Academic Block', 'MAB', 'PES University Campus', 5,
 'Main academic building containing classrooms and laboratories'),

('Computer Science Block', 'CSB', 'PES University Campus', 4,
 'Building dedicated to computer science and engineering departments'),

('Innovation and Research Block', 'IRB', 'PES University Campus', 3,
 'Building containing research laboratories and innovation spaces');


-- ============================================
-- FLOORS
-- ============================================

INSERT INTO floors
(building_id, floor_number, floor_name)
VALUES
(1, 0, 'Ground Floor'),
(1, 1, 'First Floor'),
(1, 2, 'Second Floor'),

(2, 0, 'Ground Floor'),
(2, 1, 'First Floor'),
(2, 2, 'Second Floor'),

(3, 0, 'Ground Floor'),
(3, 1, 'First Floor');


-- ============================================
-- ROOMS
-- ============================================

INSERT INTO rooms
(floor_id, room_number, room_name, room_type, capacity, area_sqft, description)
VALUES

-- Main Academic Block
(1, 'MAB-G01', 'Seminar Hall', 'Seminar Hall', 120, 2200,
 'Large seminar hall used for presentations and academic events'),

(1, 'MAB-G02', 'Classroom 1', 'Classroom', 60, 1200,
 'Standard smart classroom'),

(2, 'MAB-101', 'Classroom 2', 'Classroom', 60, 1200,
 'Standard classroom with smart teaching facilities'),

(2, 'MAB-102', 'Classroom 3', 'Classroom', 50, 1000,
 'Standard classroom'),

(3, 'MAB-201', 'Computer Lab 1', 'Computer Lab', 60, 1800,
 'Computer laboratory used for programming and practical sessions'),


-- Computer Science Block
(4, 'CSB-G01', 'CSE Lab 1', 'Computer Lab', 60, 1800,
 'Computer laboratory for CSE students'),

(4, 'CSB-G02', 'Project Lab', 'Laboratory', 40, 1500,
 'Project development and demonstration laboratory'),

(5, 'CSB-101', 'CSE Classroom 1', 'Classroom', 60, 1200,
 'Smart classroom for CSE courses'),

(5, 'CSB-102', 'CSE Classroom 2', 'Classroom', 60, 1200,
 'Smart classroom for CSE courses'),

(6, 'CSB-201', 'AI and ML Lab', 'Computer Lab', 50, 1700,
 'Laboratory for artificial intelligence and machine learning'),

(6, 'CSB-202', 'Data Science Lab', 'Computer Lab', 50, 1700,
 'Laboratory for data science and analytics'),


-- Innovation and Research Block
(7, 'IRB-G01', 'Innovation Lab', 'Research Lab', 40, 1600,
 'Laboratory for innovation and prototype development'),

(7, 'IRB-G02', 'Research Lab 1', 'Research Lab', 30, 1400,
 'Research and experimentation laboratory'),

(8, 'IRB-101', 'Research Lab 2', 'Research Lab', 30, 1400,
 'Advanced research laboratory');


-- ============================================
-- FACILITIES
-- ============================================

INSERT INTO facilities
(room_id, facility_name, quantity, status)
VALUES

-- MAB-G01
(1, 'Projector', 2, 'Available'),
(1, 'Air Conditioner', 4, 'Available'),
(1, 'Smart Display', 1, 'Available'),
(1, 'Wi-Fi Access Point', 2, 'Available'),

-- MAB-G02
(2, 'Projector', 1, 'Available'),
(2, 'Air Conditioner', 2, 'Available'),
(2, 'Smart Board', 1, 'Available'),
(2, 'Wi-Fi Access Point', 1, 'Available'),

-- MAB-101
(3, 'Projector', 1, 'Available'),
(3, 'Air Conditioner', 2, 'Available'),
(3, 'Smart Board', 1, 'Available'),

-- MAB-102
(4, 'Projector', 1, 'Available'),
(4, 'Air Conditioner', 2, 'Available'),
(4, 'Wi-Fi Access Point', 1, 'Available'),

-- MAB-201
(5, 'Computer', 60, 'Available'),
(5, 'Air Conditioner', 3, 'Available'),
(5, 'Projector', 1, 'Available'),
(5, 'Wi-Fi Access Point', 2, 'Available'),

-- CSB-G01
(6, 'Computer', 60, 'Available'),
(6, 'Air Conditioner', 3, 'Available'),
(6, 'Projector', 1, 'Available'),
(6, 'Wi-Fi Access Point', 2, 'Available'),

-- CSB-G02
(7, 'Computer', 40, 'Available'),
(7, 'Air Conditioner', 2, 'Available'),
(7, 'Projector', 1, 'Available'),

-- CSB-101
(8, 'Projector', 1, 'Available'),
(8, 'Air Conditioner', 2, 'Available'),
(8, 'Smart Board', 1, 'Available'),
(8, 'Wi-Fi Access Point', 1, 'Available'),

-- CSB-102
(9, 'Projector', 1, 'Available'),
(9, 'Air Conditioner', 2, 'Available'),
(9, 'Smart Board', 1, 'Available'),

-- CSB-201
(10, 'Computer', 50, 'Available'),
(10, 'Air Conditioner', 3, 'Available'),
(10, 'Projector', 1, 'Available'),
(10, 'Wi-Fi Access Point', 2, 'Available'),

-- CSB-202
(11, 'Computer', 50, 'Available'),
(11, 'Air Conditioner', 3, 'Available'),
(11, 'Projector', 1, 'Available'),

-- IRB-G01
(12, 'Computer', 20, 'Available'),
(12, 'Air Conditioner', 2, 'Available'),
(12, 'Projector', 1, 'Available'),

-- IRB-G02
(13, 'Computer', 15, 'Available'),
(13, 'Air Conditioner', 2, 'Available'),
(13, 'Projector', 1, 'Available'),

-- IRB-101
(14, 'Computer', 15, 'Available'),
(14, 'Air Conditioner', 2, 'Available'),
(14, 'Wi-Fi Access Point', 1, 'Available');