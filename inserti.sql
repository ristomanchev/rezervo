
INSERT INTO role (role_id, name) VALUES
                                     (2, 'customer'),
                                     (3, 'employee'),
                                     (4, 'manager');


INSERT INTO "user" (user_id, email, password, is_active, created_at)
SELECT
    gs,
    'user' || gs || '@mail.com',
    'Aa123456!',
    TRUE,
    CURRENT_TIMESTAMP
FROM generate_series(2,1000001) gs;

INSERT INTO user_role (user_id, role_id)
SELECT
    gs,
    ((gs - 2) % 3) + 2
FROM generate_series(2,1000001) gs;

INSERT INTO "user" (user_id, email, password, is_active, created_at)
SELECT
    gs,
    'user' || gs || '@mail.com',
    'Aa123456!',
    TRUE,
    CURRENT_TIMESTAMP
FROM generate_series(2,1001101) gs;

-- customers
INSERT INTO user_role (user_id, role_id)
SELECT gs, 2 FROM generate_series(2,1000001) gs;

-- employees
INSERT INTO user_role (user_id, role_id)
SELECT gs, 3 FROM generate_series(1000002,1001001) gs;

-- managers
INSERT INTO user_role (user_id, role_id)
SELECT gs, 4 FROM generate_series(1001002,1001101) gs;

INSERT INTO customer (customer_id, user_id, first_name, last_name, phone, created_at)
SELECT
    gs,
    gs,
    fnames[(gs % array_length(fnames,1)) + 1],
    lnames[(gs % array_length(lnames,1)) + 1],
    '+3897' || lpad(gs::text,7,'0'),
    CURRENT_TIMESTAMP
FROM generate_series(2,1000001) gs,
     LATERAL (
         SELECT
             ARRAY[
                 'John','David','Michael','Daniel','Marko','Ivan','Petar','Stefan',
                 'Ana','Elena','Maria','Sara','Kristina','Ivana','Teodora','Jovana',
                 'Nikola','Aleksandar','Filip','Boris','Goran','Viktor','Martin','Dimitar',
                 'Oliver','Dejan','Blagoj','Toni','Kiril','Emil','Luka','Matej',
                 'Angela','Biljana','Vesna','Dragana','Marija','Natasa','Simona','Katerina',
                 'Tamara','Valentina','Milena','Irena','Jasmina','Sanja','Monika','Daniela'
                 ] AS fnames,

             ARRAY[
                 'Smith','Johnson','Brown','Williams','Jones','Miller','Davis',
                 'Petrov','Ivanov','Stojanov','Trajkov','Nikolov','Georgiev','Kostov',
                 'Popov','Mitrov','Ristov','Angelov','Velkov','Spasov','Atanasov',
                 'Markov','Iliev','Stefanov','Dimov','Pavlov','Bogdanov','Cvetkov',
                 'Kolev','Petkov','Zdravkov','Todorov','Mihajlov','Stankov','Gligorov'
                 ] AS lnames
         ) t;

INSERT INTO employee (
    employee_id,
    user_id,
    first_name,
    last_name,
    hire_date,
    bio,
    is_active,
    created_at
)
SELECT
    gs,
    gs,
    fnames[(gs % array_length(fnames,1)) + 1],
    lnames[((gs * 5) % array_length(lnames,1)) + 1],
    CURRENT_DATE - (gs % 3650),  -- up to ~10 years back
    'Experienced employee',
    TRUE,
    CURRENT_TIMESTAMP
FROM generate_series(1000002,1001001) gs,
     LATERAL (
         SELECT
             ARRAY[
                 'John','David','Michael','Daniel','Marko','Ivan','Petar','Stefan',
                 'Nikola','Aleksandar','Filip','Boris','Goran','Viktor','Martin','Dimitar',
                 'Oliver','Dejan','Blagoj','Toni','Kiril','Emil','Luka','Matej'
                 ] AS fnames,

             ARRAY[
                 'Smith','Johnson','Brown','Williams','Jones','Miller','Davis',
                 'Petrov','Ivanov','Stojanov','Trajkov','Nikolov','Georgiev','Kostov',
                 'Popov','Mitrov','Ristov','Angelov','Velkov','Spasov'
                 ] AS lnames
         ) t;

