CREATE TABLE locations (
    id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    address TEXT,
    total_units INT NOT NULL CHECK (total_units > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE units (
    id VARCHAR(15) PRIMARY KEY,
    location_id VARCHAR(10) NOT NULL,
    unit_number VARCHAR(10) NOT NULL,
    unit_type VARCHAR(20) NOT NULL CHECK (unit_type IN ('Pod', 'Cabin')),
    floor_number INT,
    status VARCHAR(20) DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive', 'Maintenance')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_unit_location FOREIGN KEY (location_id) REFERENCES locations(id),
    CONSTRAINT uk_location_unit UNIQUE (location_id, unit_number)
);


CREATE TABLE sensors (
    id VARCHAR(20) PRIMARY KEY,
    unit_id VARCHAR(15) NOT NULL,
    sensor_type VARCHAR(30) NOT NULL CHECK (sensor_type IN ('Temperature', 'Humidity', 'Occupancy', 'Air Quality')),
    manufacturer VARCHAR(50),
    model VARCHAR(50),
    status VARCHAR(20) DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive', 'Faulty', 'Maintenance')),
    installation_date DATE NOT NULL,
    last_calibration_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sensor_unit FOREIGN KEY (unit_id) REFERENCES units(id)
);


CREATE TABLE engineers (
    id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    specialization VARCHAR(50),
    status VARCHAR(20) DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive')),
    hire_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE maintenance_records (
    id BIGSERIAL PRIMARY KEY,
    sensor_id VARCHAR(20) NOT NULL,
    engineer_id VARCHAR(10) NOT NULL,
    date DATE NOT NULL,
    type VARCHAR(30) NOT NULL CHECK (type IN ('Routine', 'Repair', 'Calibration', 'Replacement', 'Emergency')),
    description TEXT NOT NULL,
    duration_hours DECIMAL(4,2),
    cost DECIMAL(10,2),
    next_maintenance_date DATE,
    status VARCHAR(20) DEFAULT 'Completed' CHECK (status IN ('Scheduled', 'In Progress', 'Completed', 'Cancelled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_maint_sensor FOREIGN KEY (sensor_id) REFERENCES sensors(id),
    CONSTRAINT fk_maint_engineer FOREIGN KEY (engineer_id) REFERENCES engineers(id)
);


CREATE INDEX idx_units_location ON units(location_id);
CREATE INDEX idx_sensors_unit ON sensors(unit_id);
CREATE INDEX idx_sensors_type ON sensors(sensor_type);
CREATE INDEX idx_sensors_status ON sensors(status);
CREATE INDEX idx_maint_sensor ON maintenance_records(sensor_id);
CREATE INDEX idx_maint_engineer ON maintenance_records(engineer_id);
CREATE INDEX idx_maint_date ON maintenance_records(date);