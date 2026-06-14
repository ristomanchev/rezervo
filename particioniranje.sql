DROP TABLE IF EXISTS time_slot_partitioned CASCADE;

DROP TABLE IF EXISTS time_slot_partitioned CASCADE;

CREATE TABLE time_slot_partitioned (
                                       slot_id BIGINT NOT NULL,
                                       employee_id INT NOT NULL,
                                       business_id INT NOT NULL,
                                       date DATE NOT NULL,
                                       start_time TIME NOT NULL,
                                       end_time TIME NOT NULL,
                                       is_available BOOLEAN NOT NULL,
                                       PRIMARY KEY (slot_id, date)
) PARTITION BY RANGE (date);


CREATE TABLE time_slot_2026_04 PARTITION OF time_slot_partitioned
    FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');

CREATE TABLE time_slot_2026_05 PARTITION OF time_slot_partitioned
    FOR VALUES FROM ('2026-05-01') TO ('2026-06-01');

CREATE TABLE time_slot_2026_06 PARTITION OF time_slot_partitioned
    FOR VALUES FROM ('2026-06-01') TO ('2026-07-01');

CREATE TABLE time_slot_2026_07 PARTITION OF time_slot_partitioned
    FOR VALUES FROM ('2026-07-01') TO ('2026-08-01');

CREATE TABLE time_slot_2026_08 PARTITION OF time_slot_partitioned
    FOR VALUES FROM ('2026-08-01') TO ('2026-09-01');

CREATE TABLE time_slot_2026_09 PARTITION OF time_slot_partitioned
    FOR VALUES FROM ('2026-09-01') TO ('2026-10-01');

CREATE TABLE time_slot_2026_10 PARTITION OF time_slot_partitioned
    FOR VALUES FROM ('2026-10-01') TO ('2026-11-01');

CREATE TABLE time_slot_2026_11 PARTITION OF time_slot_partitioned
    FOR VALUES FROM ('2026-11-01') TO ('2026-12-01');

CREATE TABLE time_slot_2026_12 PARTITION OF time_slot_partitioned
    FOR VALUES FROM ('2026-12-01') TO ('2027-01-01');

CREATE TABLE time_slot_2027_01 PARTITION OF time_slot_partitioned
    FOR VALUES FROM ('2027-01-01') TO ('2027-02-01');

CREATE TABLE time_slot_2027_02 PARTITION OF time_slot_partitioned
    FOR VALUES FROM ('2027-02-01') TO ('2027-03-01');

CREATE TABLE time_slot_2027_03 PARTITION OF time_slot_partitioned
    FOR VALUES FROM ('2027-03-01') TO ('2027-04-01');

CREATE TABLE time_slot_2027_04 PARTITION OF time_slot_partitioned
    FOR VALUES FROM ('2027-04-01') TO ('2027-05-01');

CREATE TABLE time_slot_2027_05 PARTITION OF time_slot_partitioned
    FOR VALUES FROM ('2027-05-01') TO ('2027-06-01');

CREATE TABLE time_slot_2027_06 PARTITION OF time_slot_partitioned
    FOR VALUES FROM ('2027-06-01') TO ('2027-07-01');

INSERT INTO time_slot_partitioned (
    slot_id,
    employee_id,
    business_id,
    date,
    start_time,
    end_time,
    is_available
)
SELECT
    slot_id,
    employee_id,
    business_id,
    date,
    start_time,
    end_time,
    is_available
FROM time_slot
WHERE date >= '2026-04-01'
  AND date < '2027-07-01';

select count(*)
from time_slot_partitioned;

EXPLAIN ANALYZE
SELECT *
FROM time_slot_partitioned
WHERE business_id = 1
  AND date = '2026-05-20'
  AND is_available = TRUE;



CREATE TABLE appointment_partitioned (
                                         appointment_id BIGINT NOT NULL,
                                         customer_id INT NOT NULL,
                                         employee_id INT NOT NULL,
                                         business_id INT NOT NULL,
                                         service_id INT NOT NULL,
                                         slot_id BIGINT NOT NULL,
                                         status VARCHAR NOT NULL,
                                         created_at TIMESTAMP NOT NULL,
                                         PRIMARY KEY (appointment_id, customer_id)
) PARTITION BY HASH (customer_id);

CREATE TABLE appointment_p0 PARTITION OF appointment_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 0);

CREATE TABLE appointment_p1 PARTITION OF appointment_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 1);

CREATE TABLE appointment_p2 PARTITION OF appointment_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 2);

CREATE TABLE appointment_p3 PARTITION OF appointment_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 3);

CREATE TABLE appointment_p4 PARTITION OF appointment_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 4);

CREATE TABLE appointment_p5 PARTITION OF appointment_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 5);

CREATE TABLE appointment_p6 PARTITION OF appointment_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 6);

CREATE TABLE appointment_p7 PARTITION OF appointment_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 7);


INSERT INTO appointment_partitioned (
    appointment_id,
    customer_id,
    employee_id,
    business_id,
    service_id,
    slot_id,
    status,
    created_at
)
SELECT
    appointment_id,
    customer_id,
    employee_id,
    business_id,
    service_id,
    slot_id,
    status,
    created_at
FROM appointment;


SELECT 'appointment_p0' AS partition_name, COUNT(*) FROM appointment_p0
UNION ALL
SELECT 'appointment_p1', COUNT(*) FROM appointment_p1
UNION ALL
SELECT 'appointment_p2', COUNT(*) FROM appointment_p2
UNION ALL
SELECT 'appointment_p3', COUNT(*) FROM appointment_p3
UNION ALL
SELECT 'appointment_p4', COUNT(*) FROM appointment_p4
UNION ALL
SELECT 'appointment_p5', COUNT(*) FROM appointment_p5
UNION ALL
SELECT 'appointment_p6', COUNT(*) FROM appointment_p6
UNION ALL
SELECT 'appointment_p7', COUNT(*) FROM appointment_p7;


SELECT 'time_slot_2026_04' AS partition_name, COUNT(*) FROM time_slot_2026_04
UNION ALL
SELECT 'time_slot_2026_05', COUNT(*) FROM time_slot_2026_05
UNION ALL
SELECT 'time_slot_2026_06', COUNT(*) FROM time_slot_2026_06
UNION ALL
SELECT 'time_slot_2026_07', COUNT(*) FROM time_slot_2026_07
UNION ALL
SELECT 'time_slot_2026_08', COUNT(*) FROM time_slot_2026_08
UNION ALL
SELECT 'time_slot_2026_09', COUNT(*) FROM time_slot_2026_09
UNION ALL
SELECT 'time_slot_2026_10', COUNT(*) FROM time_slot_2026_10
UNION ALL
SELECT 'time_slot_2026_11', COUNT(*) FROM time_slot_2026_11
UNION ALL
SELECT 'time_slot_2026_12', COUNT(*) FROM time_slot_2026_12
UNION ALL
SELECT 'time_slot_2027_01', COUNT(*) FROM time_slot_2027_01
UNION ALL
SELECT 'time_slot_2027_02', COUNT(*) FROM time_slot_2027_02
UNION ALL
SELECT 'time_slot_2027_03', COUNT(*) FROM time_slot_2027_03
UNION ALL
SELECT 'time_slot_2027_04', COUNT(*) FROM time_slot_2027_04
UNION ALL
SELECT 'time_slot_2027_05', COUNT(*) FROM time_slot_2027_05
UNION ALL
SELECT 'time_slot_2027_06', COUNT(*) FROM time_slot_2027_06;

EXPLAIN ANALYZE
SELECT *
FROM appointment_partitioned
WHERE customer_id = 100;