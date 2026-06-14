-- =====================================================
-- PROCEDURES FOR REZERVO PROJECT
-- =====================================================


-- =====================================================
-- 1. Book appointment
-- Inserts appointment and marks selected slot as unavailable
-- =====================================================

CREATE OR REPLACE PROCEDURE book_appointment(
    p_customer_id INT,
    p_employee_id INT,
    p_business_id INT,
    p_service_id INT,
    p_slot_id INT
)
    LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM time_slot
        WHERE slot_id = p_slot_id
          AND is_available = TRUE
    ) THEN
        RAISE EXCEPTION 'Slot % is not available', p_slot_id;
    END IF;

    INSERT INTO appointment (
        customer_id,
        employee_id,
        business_id,
        service_id,
        slot_id,
        status,
        created_at
    )
    VALUES (
               p_customer_id,
               p_employee_id,
               p_business_id,
               p_service_id,
               p_slot_id,
               'confirmed',
               CURRENT_TIMESTAMP
           );

    UPDATE time_slot
    SET is_available = FALSE
    WHERE slot_id = p_slot_id;
END;
$$;


-- Example:
-- CALL book_appointment(100, 1000002, 1, 1, 5);



-- =====================================================
-- 2. Cancel appointment
-- Updates appointment status, frees slot and inserts cancellation
-- =====================================================

CREATE OR REPLACE PROCEDURE cancel_appointment(
    p_appointment_id INT,
    p_cancelled_by TEXT,
    p_reason TEXT,
    p_employee_id INT DEFAULT NULL
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_slot_id INT;
BEGIN
    SELECT slot_id
    INTO v_slot_id
    FROM appointment
    WHERE appointment_id = p_appointment_id;

    IF v_slot_id IS NULL THEN
        RAISE EXCEPTION 'Appointment % does not exist', p_appointment_id;
    END IF;

    UPDATE appointment
    SET status = 'cancelled'
    WHERE appointment_id = p_appointment_id;

    UPDATE time_slot
    SET is_available = TRUE
    WHERE slot_id = v_slot_id;

    INSERT INTO cancellation (
        appointment_id,
        cancelled_by,
        reason,
        refund_amount,
        created_at,
        employee_id
    )
    VALUES (
               p_appointment_id,
               p_cancelled_by,
               p_reason,
               0,
               CURRENT_TIMESTAMP,
               p_employee_id
           );
END;
$$;


-- Example:
-- CALL cancel_appointment(100, 'customer', 'Customer cannot attend', NULL);



-- =====================================================
-- 3. Create review for appointment
-- =====================================================

CREATE OR REPLACE PROCEDURE create_review_for_appointment(
    p_appointment_id INT,
    p_customer_id INT,
    p_employee_id INT,
    p_manager_id INT,
    p_business_id INT,
    p_rating INT,
    p_comment TEXT
)
    LANGUAGE plpgsql
AS $$
BEGIN
    IF p_rating < 1 OR p_rating > 5 THEN
        RAISE EXCEPTION 'Rating must be between 1 and 5';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM appointment
        WHERE appointment_id = p_appointment_id
    ) THEN
        RAISE EXCEPTION 'Appointment % does not exist', p_appointment_id;
    END IF;

    INSERT INTO review (
        appointment_id,
        customer_id,
        employee_id,
        manager_id,
        business_id,
        rating,
        comment,
        created_at
    )
    VALUES (
               p_appointment_id,
               p_customer_id,
               p_employee_id,
               p_manager_id,
               p_business_id,
               p_rating,
               p_comment,
               CURRENT_TIMESTAMP
           );
END;
$$;


-- Example:
-- CALL create_review_for_appointment(100, 100, 1000002, 1, 1, 5, 'Great service');



-- =====================================================
-- 4. Request reschedule
-- Creates pending reschedule request
-- =====================================================

CREATE OR REPLACE PROCEDURE request_reschedule(
    p_appointment_id INT,
    p_old_slot_id INT,
    p_new_slot_id INT,
    p_manager_id INT,
    p_employee_id INT,
    p_reason TEXT
)
    LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM appointment
        WHERE appointment_id = p_appointment_id
    ) THEN
        RAISE EXCEPTION 'Appointment % does not exist', p_appointment_id;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM time_slot
        WHERE slot_id = p_new_slot_id
          AND is_available = TRUE
    ) THEN
        RAISE EXCEPTION 'New slot % is not available', p_new_slot_id;
    END IF;

    INSERT INTO reschedule_request (
        appointment_id,
        old_slot_id,
        new_slot_id,
        manager_id,
        employee_id,
        status,
        reason,
        created_at
    )
    VALUES (
               p_appointment_id,
               p_old_slot_id,
               p_new_slot_id,
               p_manager_id,
               p_employee_id,
               'pending',
               p_reason,
               CURRENT_TIMESTAMP
           );
END;
$$;


-- Example:
-- CALL request_reschedule(100, 5, 6, 1, 1000002, 'Customer requested another time');



-- =====================================================
-- 5. Approve reschedule request
-- Updates appointment slot and request status
-- =====================================================

CREATE OR REPLACE PROCEDURE approve_reschedule_request(
    p_request_id INT
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_appointment_id INT;
    v_old_slot_id INT;
    v_new_slot_id INT;
BEGIN
    SELECT appointment_id, old_slot_id, new_slot_id
    INTO v_appointment_id, v_old_slot_id, v_new_slot_id
    FROM reschedule_request
    WHERE request_id = p_request_id
      AND status = 'pending';

    IF v_appointment_id IS NULL THEN
        RAISE EXCEPTION 'Pending reschedule request % does not exist', p_request_id;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM time_slot
        WHERE slot_id = v_new_slot_id
          AND is_available = TRUE
    ) THEN
        RAISE EXCEPTION 'New slot % is not available', v_new_slot_id;
    END IF;

    UPDATE appointment
    SET slot_id = v_new_slot_id
    WHERE appointment_id = v_appointment_id;

    UPDATE time_slot
    SET is_available = TRUE
    WHERE slot_id = v_old_slot_id;

    UPDATE time_slot
    SET is_available = FALSE
    WHERE slot_id = v_new_slot_id;

    UPDATE reschedule_request
    SET status = 'approved'
    WHERE request_id = p_request_id;
END;
$$;


-- Example:
-- CALL approve_reschedule_request(1);



-- =====================================================
-- 6. Reject reschedule request
-- =====================================================

CREATE OR REPLACE PROCEDURE reject_reschedule_request(
    p_request_id INT
)
    LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE reschedule_request
    SET status = 'rejected'
    WHERE request_id = p_request_id
      AND status = 'pending';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pending reschedule request % does not exist', p_request_id;
    END IF;
END;
$$;


-- Example:
-- CALL reject_reschedule_request(1);

CREATE OR REPLACE PROCEDURE make_employee_slots_unavailable(
    p_employee_id INT,
    p_date_from DATE,
    p_date_to DATE,
    p_reason TEXT DEFAULT 'Employee unavailable',
    p_business_id INT DEFAULT NULL
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_booked_count INT;
    v_updated_count INT;
BEGIN
    IF p_date_from > p_date_to THEN
        RAISE EXCEPTION 'date_from cannot be after date_to';
    END IF;

    SELECT COUNT(*)
    INTO v_booked_count
    FROM time_slot ts
             JOIN appointment a ON a.slot_id = ts.slot_id
    WHERE ts.employee_id = p_employee_id
      AND ts.date BETWEEN p_date_from AND p_date_to
      AND a.status <> 'cancelled'
      AND (
        p_business_id IS NULL
            OR ts.business_id = p_business_id
        );

    IF v_booked_count > 0 THEN
        RAISE EXCEPTION
            'Cannot make slots unavailable. Employee % has % booked slots between % and %.',
            p_employee_id, v_booked_count, p_date_from, p_date_to;
    END IF;

    UPDATE time_slot
    SET is_available = FALSE
    WHERE employee_id = p_employee_id
      AND date BETWEEN p_date_from AND p_date_to
      AND (
        p_business_id IS NULL
            OR business_id = p_business_id
        );

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    RAISE NOTICE
        'Marked % slots as unavailable for employee % between % and %. Reason: %',
        v_updated_count, p_employee_id, p_date_from, p_date_to, p_reason;
END;
$$;

CALL make_employee_slots_unavailable(
        1000002,
        '2026-05-01',
        '2026-05-07',
        'Vacation'
     );

SELECT ts.slot_id, ts.employee_id, ts.date, a.appointment_id, a.status
FROM time_slot ts
         JOIN appointment a ON a.slot_id = ts.slot_id
WHERE ts.employee_id = 1000002
  AND ts.date BETWEEN '2026-05-01' AND '2026-05-07'
  AND a.status <> 'cancelled';