-- =====================================================
-- TRIGGERS FOR REZERVO PROJECT
-- =====================================================


-- =====================================================
-- 1. Trigger: Automatically set created_at on appointment
-- =====================================================

-- CREATE OR REPLACE FUNCTION trg_set_appointment_created_at()
--     RETURNS TRIGGER
--     LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     IF NEW.created_at IS NULL THEN
--         NEW.created_at := CURRENT_TIMESTAMP;
--     END IF;
--
--     RETURN NEW;
-- END;
-- $$;

-- DROP TRIGGER IF EXISTS set_appointment_created_at ON appointment;
--
-- CREATE TRIGGER set_appointment_created_at
--     BEFORE INSERT ON appointment
--     FOR EACH ROW
-- EXECUTE FUNCTION trg_set_appointment_created_at();



-- =====================================================
-- 2. Trigger: Prevent booking unavailable slot
-- =====================================================

CREATE OR REPLACE FUNCTION trg_prevent_unavailable_slot_booking()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.status <> 'cancelled' THEN
        IF NOT EXISTS (
            SELECT 1
            FROM time_slot
            WHERE slot_id = NEW.slot_id
              AND is_available = TRUE
        ) THEN
            RAISE EXCEPTION 'Slot % is not available for booking', NEW.slot_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS prevent_unavailable_slot_booking ON appointment;

CREATE TRIGGER prevent_unavailable_slot_booking
    BEFORE INSERT ON appointment
    FOR EACH ROW
EXECUTE FUNCTION trg_prevent_unavailable_slot_booking();



-- =====================================================
-- 3. Trigger: Prevent double booking of same slot
-- =====================================================

CREATE OR REPLACE FUNCTION trg_prevent_double_booking()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.status <> 'cancelled' THEN
        IF EXISTS (
            SELECT 1
            FROM appointment a
            WHERE a.slot_id = NEW.slot_id
              AND a.status <> 'cancelled'
              AND (
                TG_OP = 'INSERT'
                    OR a.appointment_id <> NEW.appointment_id
                )
        ) THEN
            RAISE EXCEPTION 'Slot % is already booked', NEW.slot_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS prevent_double_booking ON appointment;

CREATE TRIGGER prevent_double_booking
    BEFORE INSERT OR UPDATE OF slot_id, status ON appointment
    FOR EACH ROW
EXECUTE FUNCTION trg_prevent_double_booking();



-- =====================================================
-- 4. Trigger: Mark slot as unavailable after appointment insert
-- =====================================================

CREATE OR REPLACE FUNCTION trg_mark_slot_unavailable_after_booking()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.status <> 'cancelled' THEN
        UPDATE time_slot
        SET is_available = FALSE
        WHERE slot_id = NEW.slot_id;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS mark_slot_unavailable_after_booking ON appointment;

CREATE TRIGGER mark_slot_unavailable_after_booking
    AFTER INSERT ON appointment
    FOR EACH ROW
EXECUTE FUNCTION trg_mark_slot_unavailable_after_booking();



-- =====================================================
-- 5. Trigger: Free slot when appointment is cancelled
-- =====================================================

CREATE OR REPLACE FUNCTION trg_free_slot_after_cancellation()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.status <> 'cancelled'
        AND NEW.status = 'cancelled' THEN

        UPDATE time_slot
        SET is_available = TRUE
        WHERE slot_id = OLD.slot_id;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS free_slot_after_cancellation ON appointment;

CREATE TRIGGER free_slot_after_cancellation
    AFTER UPDATE OF status ON appointment
    FOR EACH ROW
EXECUTE FUNCTION trg_free_slot_after_cancellation();



-- =====================================================
-- 6. Trigger: Validate review rating
-- =====================================================

-- CREATE OR REPLACE FUNCTION trg_validate_review_rating()
--     RETURNS TRIGGER
--     LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     IF NEW.rating < 1 OR NEW.rating > 5 THEN
--         RAISE EXCEPTION 'Rating must be between 1 and 5';
--     END IF;
--
--     RETURN NEW;
-- END;
-- $$;
--
-- DROP TRIGGER IF EXISTS validate_review_rating ON review;
--
-- CREATE TRIGGER validate_review_rating
--     BEFORE INSERT OR UPDATE OF rating ON review
--     FOR EACH ROW
-- EXECUTE FUNCTION trg_validate_review_rating();



-- =====================================================
-- 7. Trigger: Prevent duplicate review for same appointment
-- =====================================================

CREATE OR REPLACE FUNCTION trg_prevent_duplicate_review()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM review r
        WHERE r.appointment_id = NEW.appointment_id
          AND (
            TG_OP = 'INSERT'
                OR r.review_id <> NEW.review_id
            )
    ) THEN
        RAISE EXCEPTION 'Appointment % already has a review', NEW.appointment_id;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS prevent_duplicate_review ON review;

CREATE TRIGGER prevent_duplicate_review
    BEFORE INSERT OR UPDATE OF appointment_id ON review
    FOR EACH ROW
EXECUTE FUNCTION trg_prevent_duplicate_review();



-- =====================================================
-- 8. Trigger: Automatically set review created_at
-- =====================================================

-- CREATE OR REPLACE FUNCTION trg_set_review_created_at()
--     RETURNS TRIGGER
--     LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     IF NEW.created_at IS NULL THEN
--         NEW.created_at := CURRENT_TIMESTAMP;
--     END IF;
--
--     RETURN NEW;
-- END;
-- $$;
--
-- DROP TRIGGER IF EXISTS set_review_created_at ON review;
--
-- CREATE TRIGGER set_review_created_at
--     BEFORE INSERT ON review
--     FOR EACH ROW
-- EXECUTE FUNCTION trg_set_review_created_at();



-- =====================================================
-- 9. Trigger: Validate new slot in reschedule request
-- =====================================================

-- CREATE OR REPLACE FUNCTION trg_validate_reschedule_new_slot()
--     RETURNS TRIGGER
--     LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     IF NEW.status = 'pending' THEN
--         IF NOT EXISTS (
--             SELECT 1
--             FROM time_slot
--             WHERE slot_id = NEW.new_slot_id
--               AND is_available = TRUE
--         ) THEN
--             RAISE EXCEPTION 'New slot % is not available for rescheduling', NEW.new_slot_id;
--         END IF;
--     END IF;
--
--     RETURN NEW;
-- END;
-- $$;
--
-- DROP TRIGGER IF EXISTS validate_reschedule_new_slot ON reschedule_request;
--
-- CREATE TRIGGER validate_reschedule_new_slot
--     BEFORE INSERT OR UPDATE OF new_slot_id, status ON reschedule_request
--     FOR EACH ROW
-- EXECUTE FUNCTION trg_validate_reschedule_new_slot();



-- =====================================================
-- 10. Trigger: Automatically set reschedule request created_at
-- =====================================================

-- CREATE OR REPLACE FUNCTION trg_set_reschedule_created_at()
--     RETURNS TRIGGER
--     LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     IF NEW.created_at IS NULL THEN
--         NEW.created_at := CURRENT_TIMESTAMP;
--     END IF;
--
--     RETURN NEW;
-- END;
-- $$;
--
-- DROP TRIGGER IF EXISTS set_reschedule_created_at ON reschedule_request;
--
-- CREATE TRIGGER set_reschedule_created_at
--     BEFORE INSERT ON reschedule_request
--     FOR EACH ROW
-- EXECUTE FUNCTION trg_set_reschedule_created_at();



-- =====================================================
-- 11. Trigger: Validate cancellation created_at
-- =====================================================

-- CREATE OR REPLACE FUNCTION trg_set_cancellation_created_at()
--     RETURNS TRIGGER
--     LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     IF NEW.created_at IS NULL THEN
--         NEW.created_at := CURRENT_TIMESTAMP;
--     END IF;
--
--     RETURN NEW;
-- END;
-- $$;
--
-- DROP TRIGGER IF EXISTS set_cancellation_created_at ON cancellation;
--
-- CREATE TRIGGER set_cancellation_created_at
--     BEFORE INSERT ON cancellation
--     FOR EACH ROW
-- EXECUTE FUNCTION trg_set_cancellation_created_at();