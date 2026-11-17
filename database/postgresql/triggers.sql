-- ============================================
-- DIGITAL TWIN - SMART BUILDINGS
-- PostgreSQL Triggers
-- ============================================

-- ============================================
-- AUDIT TABLE: Tracks all changes to facilities
-- ============================================

CREATE TABLE IF NOT EXISTS facility_audit (
    audit_id SERIAL PRIMARY KEY,
    facility_id INTEGER NOT NULL,
    action VARCHAR(50) NOT NULL,
    old_facility_name VARCHAR(100),
    new_facility_name VARCHAR(100),
    changed_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- TRIGGER FUNCTION: Log facility insert/update/delete changes
-- ============================================

CREATE OR REPLACE FUNCTION log_facility_changes()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO facility_audit (facility_id, action, old_facility_name, new_facility_name)
    VALUES (
        COALESCE(NEW.facility_id, OLD.facility_id),
        TG_OP,
        COALESCE(OLD.facility_name, ''),
        NEW.facility_name
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRIGGER: Audit facility on INSERT
-- ============================================

CREATE OR REPLACE TRIGGER trg_facility_audit_insert
    AFTER INSERT ON facilities
    FOR EACH ROW
    EXECUTE FUNCTION log_facility_changes();

-- ============================================
-- TRIGGER: Audit facility on UPDATE
-- ============================================

CREATE OR REPLACE TRIGGER trg_facility_audit_update
    AFTER UPDATE ON facilities
    FOR EACH ROW
    EXECUTE FUNCTION log_facility_changes();

-- ============================================
-- TRIGGER: Audit facility on DELETE
-- ============================================

CREATE OR REPLACE TRIGGER trg_facility_audit_delete
    AFTER DELETE ON facilities
    FOR EACH ROW
    EXECUTE FUNCTION log_facility_changes();

-- ============================================
-- VALIDATION TRIGGER: Check facility quantity and status before insert/update
-- ============================================

CREATE OR REPLACE FUNCTION validate_facility_quantity()
RETURNS TRIGGER AS $$
BEGIN
    -- Validate quantity is positive
    IF NEW.quantity < 1 THEN
        RAISE EXCEPTION 'Facility quantity must be at least 1';
    END IF;

    -- Validate status is a valid value
    IF NEW.status NOT IN ('Available', 'Maintenance', 'Out of Service') THEN
        RAISE EXCEPTION 'Invalid facility status. Must be Available, Maintenance, or Out of Service';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_validate_facility_quantity
    BEFORE INSERT OR UPDATE ON facilities
    FOR EACH ROW
    EXECUTE FUNCTION validate_facility_quantity();