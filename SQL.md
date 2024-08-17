-- Table: public.admin_staff
CREATE TABLE admin (
    member_id INTEGER PRIMARY KEY REFERENCES members(member_id),
    hire_date DATE NOT NULL,
    salary NUMERIC
);

-- Table: public.exercises
CREATE TABLE exercises (
    id                INTEGER PRIMARY KEY,
    name              CHARACTER VARYING(255) NOT NULL,
    muscle_group      CHARACTER VARYING(255),
    difficulty        CHARACTER VARYING(255),
    duration          INTEGER,
    equipment_needed  BOOLEAN,
    workout_type      CHARACTER VARYING(255),
    description       TEXT
);

-- Table: public.fitness_achievements
CREATE TABLE fitness_achievements (
    member_id                 INTEGER PRIMARY KEY REFERENCES members(member_id),
    achievement_strength      BOOLEAN,
    achievement_endurance     BOOLEAN,
    achievement_flexibility   BOOLEAN,
    achievement_date          DATE NOT NULL
);

-- Table: public.gym_memberships
CREATE TABLE gym_memberships (
    member_id      INTEGER PRIMARY KEY REFERENCES members(member_id),
    gym            CHARACTER VARYING(255) NOT NULL,
    address        CHARACTER VARYING(255) NOT NULL
);


CREATE TABLE members (
    member_id       INTEGER PRIMARY KEY,
    first_name      CHARACTER VARYING(255) NOT NULL,
    last_name       CHARACTER VARYING(255) NOT NULL,
    date_of_birth   DATE NOT NULL,
    email           CHARACTER VARYING(255) UNIQUE NOT NULL,
    password        CHARACTER VARYING(255) NOT NULL,
    time_created    TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Table: public.members_metrics
CREATE TABLE members_metrics (
    member_id             INTEGER PRIMARY KEY REFERENCES members(member_id),
    height_cm             INTEGER NOT NULL,
    weight_kg             NUMERIC NOT NULL,
    gender                CHARACTER VARYING(255) NOT NULL,
    workout_frequency     INTEGER NOT NULL
);

CREATE TABLE nutrition_plans (
    member_id          INTEGER PRIMARY KEY REFERENCES members(member_id),
    daily_calories     INTEGER NOT NULL,
    protein_target     NUMERIC NOT NULL,
    carbs_target       NUMERIC NOT NULL,
    fats_target        NUMERIC NOT NULL,
    meal_timing        TEXT,
    start_date         DATE NOT NULL,
    end_date           DATE,
    notes              TEXT
);

-- Table: public.pr_tracker
CREATE TABLE pr_tracker (
    member_id       INTEGER PRIMARY KEY REFERENCES members(member_id),
    bench_max       INTEGER NOT NULL,
    squat_max       INTEGER NOT NULL,
    deadlift_max    INTEGER NOT NULL,
    recorded_at     TIMESTAMP WITHOUT TIME ZONE NOT NULL
);


-- Table: public.user_workout_plans
CREATE TABLE user_workout_plans (
    member_id              INTEGER PRIMARY KEY REFERENCES members(member_id),
    plan_name              CHARACTER VARYING(255) NOT NULL,
    preference_intensity   CHARACTER VARYING(255) NOT NULL,
    preference_duration    INTEGER NOT NULL,
    focus_area             CHARACTER VARYING(255),
    frequency_per_week     INTEGER NOT NULL,
    created_at             TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    updated_at             TIMESTAMP WITHOUT TIME ZONE NOT NULL
);


-- Table: public.workouts
CREATE TABLE workouts (
    workout_id      INTEGER PRIMARY KEY,
    workout_name    CHARACTER VARYING(255) NOT NULL
);

-- Junction Table: public.workout_exercises
CREATE TABLE workout_exercises (
    workout_id      INTEGER REFERENCES workouts(workout_id),
    exercise_id     INTEGER REFERENCES exercises(id),
    PRIMARY KEY (workout_id, exercise_id)
);
