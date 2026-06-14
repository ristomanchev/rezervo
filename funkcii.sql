-- =====================================================
-- FUNCTIONS FOR REZERVO PROJECT
-- =====================================================


-- =====================================================
-- 1. Get appointments for one customer
-- =====================================================

CREATE OR REPLACE FUNCTION get_customer_appointments(
    p_customer_id INT
)
    RETURNS TABLE (
                      appointment_id INT,
                      status TEXT,
                      created_at TIMESTAMP,
                      customer_id INT,
                      customer_name TEXT,
                      business_id INT,
                      business_name TEXT,
                      service_id INT,
                      service_name TEXT,
                      employee_id INT,
                      employee_name TEXT,
                      appointment_date DATE,
                      start_time TIME,
                      end_time TIME,
                      city TEXT
                  )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT
            cav.appointment_id,
            cav.status::TEXT,
            cav.created_at,
            cav.customer_id,
            cav.customer_name::TEXT,
            cav.business_id,
            cav.business_name::TEXT,
            cav.service_id,
            cav.service_name::TEXT,
            cav.employee_id,
            cav.employee_name::TEXT,
            cav.date,
            cav.start_time,
            cav.end_time,
            cav.city::TEXT
        FROM customer_appointments_view cav
        WHERE cav.customer_id = p_customer_id;
END;
$$;


-- Example:
-- SELECT * FROM get_customer_appointments(100);



-- =====================================================
-- 2. Get available slots for business and date
-- =====================================================

CREATE OR REPLACE FUNCTION get_available_slots(
    p_business_id INT,
    p_date_from DATE,
    p_date_to DATE
)
    RETURNS TABLE (
                      slot_id INT,
                      slot_date DATE,
                      start_time TIME,
                      end_time TIME,
                      business_id INT,
                      business_name TEXT,
                      employee_id INT,
                      employee_name TEXT,
                      service_id INT,
                      service_name TEXT,
                      price NUMERIC,
                      duration_minutes INT
                  )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT
            av.slot_id,
            av.date,
            av.start_time,
            av.end_time,
            av.business_id,
            av.business_name::TEXT,
            av.employee_id,
            av.employee_name::TEXT,
            av.service_id,
            av.service_name::TEXT,
            av.price,
            av.duration_minutes
        FROM available_slots av
        WHERE av.business_id = p_business_id
          AND av.date >= p_date_from
          AND av.date <= p_date_to;
END;
$$;
--
-- EXAMPLE
SELECT *
FROM get_available_slots(1, '2026-05-01', '2026-05-31');



-- =====================================================
-- 3. Get review summary for one business
-- =====================================================

CREATE OR REPLACE FUNCTION get_business_review_summary(
    p_business_id INT
)
    RETURNS TABLE (
                      business_id INT,
                      business_name TEXT,
                      avg_rating NUMERIC,
                      total_reviews BIGINT
                  )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT
            rs.business_id,
            rs.business_name::TEXT,
            rs.avg_rating,
            rs.total_reviews
        FROM review_summary rs
        WHERE rs.business_id = p_business_id;
END;
$$;


-- Example:
-- SELECT * FROM get_business_review_summary(1);



-- =====================================================
-- 4. Get reviews by rating
-- =====================================================

-- CREATE OR REPLACE FUNCTION get_reviews_by_rating(
--     p_rating INT
-- )
--     RETURNS TABLE (
--                       review_id INT,
--                       business_name TEXT,
--                       rating INT,
--                       comment TEXT,
--                       created_at TIMESTAMP
--                   )
--     LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     RETURN QUERY
--         SELECT
--             rd.review_id,
--             rd.business_name::TEXT,
--             rd.rating,
--             rd.comment::TEXT,
--             rd.created_at
--         FROM review_details rd
--         WHERE rd.rating = p_rating;
-- END;
-- $$;


-- Example:
-- SELECT * FROM get_reviews_by_rating(5);



-- =====================================================
-- 5. Get customer profile
-- =====================================================

-- CREATE OR REPLACE FUNCTION get_customer_profile(
--     p_customer_id INT
-- )
--     RETURNS TABLE (
--                       user_id INT,
--                       email TEXT,
--                       customer_id INT,
--                       first_name TEXT,
--                       last_name TEXT,
--                       phone TEXT,
--                       total_appointments BIGINT,
--                       businesses_visited BIGINT,
--                       avg_given_rating NUMERIC,
--                       total_reviews_written BIGINT,
--                       last_appointment_date TIMESTAMP
--                   )
--     LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     RETURN QUERY
--         SELECT
--             cpv.user_id,
--             cpv.email::TEXT,
--             cpv.customer_id,
--             cpv.first_name::TEXT,
--             cpv.last_name::TEXT,
--             cpv.phone::TEXT,
--             cpv.total_appointments,
--             cpv.businesses_visited,
--             cpv.avg_given_rating,
--             cpv.total_reviews_written,
--             cpv.last_appointment_date
--         FROM customer_profile_view cpv
--         WHERE cpv.customer_id = p_customer_id;
-- END;
-- $$;


-- Example:
-- SELECT * FROM get_customer_profile(100);



-- =====================================================
-- 6. Get reschedule requests by status
-- =====================================================

-- CREATE OR REPLACE FUNCTION get_reschedule_requests_by_status(
--     p_status TEXT
-- )
--     RETURNS TABLE (
--                       request_id INT,
--                       status TEXT,
--                       reason TEXT,
--                       old_date DATE,
--                       old_time TIME,
--                       new_date DATE,
--                       new_time TIME
--                   )
--     LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     RETURN QUERY
--         SELECT
--             ro.request_id,
--             ro.status::TEXT,
--             ro.reason::TEXT,
--             ro.old_date,
--             ro.old_time,
--             ro.new_date,
--             ro.new_time
--         FROM reschedule_overview ro
--         WHERE ro.status::TEXT = p_status;
-- END;
-- $$;


-- Example:
-- SELECT * FROM get_reschedule_requests_by_status('pending');