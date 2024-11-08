const express = require('express');
const bodyParser = require('body-parser');
const crypto = require('crypto');
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const app = express();
const port = 3000;
require('dotenv').config({ path: './.gitignore' });

app.use(bodyParser.json());

app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    next();
});

app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    console.log('Headers:', req.headers);
    console.log('Body:', req.body);
    next();
  });

  const pool = new Pool({
    user: process.env.DB_USER || "postgres",
    host: process.env.DB_HOST || "localhost",
    database: process.env.DB_NAME || "",
    password: process.env.DB_PASSWORD || "",
    port: process.env.DB_PORT || 4126,
});
/**
 * @api {post} /signup User Signup
 * @apiDescription Register a new user with account and metrics data.
 * @apiBody {String} firstName User's first name.
 * @apiBody {String} lastName User's last name.
 * @apiBody {Date} dateOfBirth User's date of birth.
 * @apiBody {String} email User's email address.
 * @apiBody {String} password User's password.
 * @apiBody {String} username User's chosen username.
 * @apiBody {Number} heightCm User's height in centimeters.
 * @apiBody {Number} weightKg User's weight in kilograms.
 * @apiBody {String} gender User's gender.
 * @apiBody {String} workoutFrequency User's workout frequency.
 * @apiResponse {JSON} member_id Newly created member's ID.
 * @apiResponse {String} auth_key Authentication key for the user.
 * @apiError 400 Missing required fields.
 * @apiError 500 Internal Server Error.
 */

app.post('/signup', async (req, res) => {
    try {
        const { firstName, lastName, dateOfBirth, email, password, username, heightCm, weightKg, gender, workoutFrequency } = req.body;
        if (!firstName || !lastName || !dateOfBirth || !email || !password || !username) {
            return res.status(400).send('Missing required account fields');
        }
        if (!heightCm || !weightKg || !gender || !workoutFrequency) {
            return res.status(400).send('Missing required metrics fields');
        }
        const hashedPassword = await bcrypt.hash(password, 10);
        const authKey = crypto.randomBytes(20).toString('hex');
        const accountQuery = `
            INSERT INTO members (first_name, last_name, date_of_birth, email, password, username, auth_key, time_created)
            VALUES ($1, $2, $3, $4, $5, $6, $7, CURRENT_TIMESTAMP)
            RETURNING member_id;
        `;
        const accountValues = [firstName, lastName, dateOfBirth, email, hashedPassword, username, authKey];
        const accountResult = await pool.query(accountQuery, accountValues);
        const memberId = accountResult.rows[0].member_id;
        const metricsQuery = `
            INSERT INTO members_metrics (member_id, height_cm, weight_kg, gender, workout_frequency)
            VALUES ($1, $2, $3, $4, $5);
        `;
        const metricsValues = [memberId, heightCm, weightKg, gender, workoutFrequency];
        await pool.query(metricsQuery, metricsValues);
        res.status(201).json({ member_id: memberId, auth_key: authKey });
    } catch (err) {
        console.error(`Error during signup: ${err.message}`);
        res.status(500).send(err.message);
    }
});

/**
 * @api {post} /login User Login
 * @apiDescription Authenticate a user and provide an auth key.
 * @apiBody {String} [email] User's email address (optional, if username is provided).
 * @apiBody {String} [username] User's username (optional, if email is provided).
 * @apiBody {String} password User's password.
 * @apiResponse {JSON} member_id Authenticated member's ID.
 * @apiResponse {String} auth_key Authentication key for the user.
 * @apiError 400 Email or username is required.
 * @apiError 401 Invalid credentials.
 * @apiError 500 Internal Server Error.
 */

app.post('/login', async (req, res) => {
    try {
        const { email, username, password } = req.body;
        let query, values;
        if (email) {
            query = 'SELECT member_id, password, auth_key FROM members WHERE email = $1';
            values = [email];
        } else if (username) {
            query = 'SELECT member_id, password, auth_key FROM members WHERE username = $1';
            values = [username];
        } else {
            return res.status(400).send('Email or username is required');
        }

        const result = await pool.query(query, values);
        if (result.rows.length > 0) {
            const user = result.rows[0];
            const match = await bcrypt.compare(password, user.password);

            if (match) {
                res.json({ member_id: user.member_id, auth_key: user.auth_key });
            } else {
                res.status(401).send('Invalid credentials');
            }
        } else {
            res.status(401).send('Invalid credentials');
        }
    } catch (err) {
        console.error(`Error during login: ${err.message}`);
        res.status(500).send(err.message);
    }
});

/**
 * @api {get} /checkUsername/:username Check Username Availability
 * @apiDescription Check if a username is available for registration.
 * @apiParam {String} username Username to check for availability.
 * @apiResponse {JSON} isAvailable Boolean indicating if the username is available.
 * @apiError 500 Internal Server Error.
 */

app.get('/checkUsername/:username', async (req, res) => {
    try {
        const { username } = req.params;
        const query = 'SELECT COUNT(*) FROM members WHERE username = $1';
        const result = await pool.query(query, [username]);
        const isAvailable = result.rows[0].count === '0';
        res.json({ isAvailable });
    } catch (err) {
        console.error(`Error checking username: ${err.message}`);
        res.status(500).send(err.message);
    }
});

/**
 * @api {post} /exercises Add Exercises to Workout
 * @apiDescription Record a new workout for a user with specified exercises.
 * @apiBody {Number} memberId ID of the member.
 * @apiBody {Array} exerciseIds Array of exercise IDs to be included in the workout.
 * @apiResponse {JSON} workoutId ID of the newly created workout.
 * @apiError 400 Invalid input data.
 * @apiError 500 Internal Server Error.
 */


app.post('/exercises', authenticate, async (req, res) => {
    try {
        const { memberId, exerciseIds } = req.body;

        // Validate input
        if (!memberId || !exerciseIds || !Array.isArray(exerciseIds)) {
            return res.status(400).send('Invalid input data');
        }

        const query = `
            INSERT INTO workouts (member_id, exercise_ids)
            VALUES ($1, $2)
            RETURNING workout_id;
        `;
        const values = [memberId, exerciseIds];

        const result = await pool.query(query, values);
        
        res.status(201).json({ workoutId: result.rows[0].workout_id });
    } catch (err) {
        console.error(`Error during workout creation: ${err.message}`);
        res.status(500).send(err.message);
    }
});

/**
 * @api {post} /updateUserInfo/:memberId Update User Information
 * @apiDescription Update personal information for a specific user.
 * @apiParam {Number} memberId ID of the member whose information is to be updated.
 * @apiBody {String} firstName User's first name.
 * @apiBody {String} lastName User's last name.
 * @apiBody {Date} dateOfBirth User's date of birth.
 * @apiBody {String} email User's email address.
 * @apiBody {String} username User's username.
 * @apiResponse {String} message Success message.
 * @apiError 400 Missing required fields.
 * @apiError 500 Internal Server Error.
 */


app.post('/updateUserInfo/:memberId', authenticate, async (req, res) => {
    try {
        const { memberId } = req.params;
        const { firstName, lastName, dateOfBirth, email, username } = req.body;
        
        if (!firstName || !lastName || !dateOfBirth || !email || !username) {
            return res.status(400).send('Missing required fields');
        }

        const query = `
            UPDATE members
            SET first_name = $1, last_name = $2, date_of_birth = $3, email = $4, username = $5
            WHERE member_id = $6;
        `;
        const values = [firstName, lastName, dateOfBirth, email, username, memberId];

        await pool.query(query, values);
        
        res.send('User information updated successfully');
    } catch (err) {
        console.error(`Error during updating user information: ${err.message}`);
        res.status(500).send(err.message);
    }
});

/**
 * @api {get} /userDataAndMetrics/:memberId Fetch User Data and Metrics
 * @apiDescription Retrieve user data and physical metrics for a specific member.
 * @apiParam {Number} memberId ID of the member.
 * @apiResponse {JSON} userData User's personal and metrics data.
 * @apiError 400 Invalid memberId.
 * @apiError 404 Member not found.
 * @apiError 500 Internal Server Error.
 */


app.get('/userDataAndMetrics/:memberId', authenticate, async (req, res) => {
    try {
      let { memberId } = req.params;
      memberId = parseInt(memberId, 10);
  
      if (isNaN(memberId)) {
        return res.status(400).send('Invalid memberId');
      }
  
      const client = await pool.connect();
      const queryText = 'SELECT first_name, last_name, date_of_birth, email, username FROM members WHERE member_id = $1';
      
      console.log('Executing query:', queryText, 'with memberId:', memberId);
  
      const result = await client.query(queryText, [memberId]);
      client.release();
  
      if (result.rows.length > 0) {
        res.json(result.rows[0]);
      } else {
        res.status(404).send('Member not found');
      }
    } catch (error) {
      console.error('Error fetching user data', error);
      res.status(500).send('Internal Server Error');
    }
  });

/**
 * @api {post} /setGymMembership Set Gym Membership
 * @apiDescription Update or set gym membership details for a user.
 * @apiBody {Number} memberId ID of the member.
 * @apiBody {String} gym Name of the gym.
 * @apiBody {String} address Address of the gym.
 * @apiBody {String} membershipType Type of gym membership.
 * @apiResponse {String} message Success message.
 * @apiError 500 Internal Server Error.
 */


app.post('/setGymMembership', authenticate, async (req, res) => {
    try {
        const { memberId, gym, address, membershipType } = req.body;

        let checkQuery = 'SELECT * FROM gym_memberships WHERE member_id = $1';
        let checkResult = await pool.query(checkQuery, [memberId]);

        let query;
        if (checkResult.rows.length > 0) {
            query = `
                UPDATE gym_memberships
                SET gym = $2, address = $3, membership_type = $4
                WHERE member_id = $1;
            `;
        } else {
            query = `
                INSERT INTO gym_memberships (member_id, gym, address, membership_type)
                VALUES ($1, $2, $3, $4);
                VALUES ($1, $2, $3, $4);
            `;
        }
        
        await pool.query(query, [memberId, gym, address, membershipType]);
        res.send('Gym membership information updated successfully');
    } catch (err) {
        console.error(`Error during setting gym membership: ${err.message}`);
        res.status(500).send(err.message);
    }
});

/**
 * @api {get} /workouts/:memberId Get Workouts
 * @apiDescription Retrieve all workouts for a specific member.
 * @apiParam {Number} memberId ID of the member.
 * @apiResponse {Array} workouts Array of workout records.
 * @apiError 400 Member ID required.
 * @apiError 500 Internal Server Error.
 */

app.get('/workouts/:memberId', authenticate, async (req, res) => {
    try {
        const { memberId } = req.params;
        console.log(`Fetching workouts for memberId: ${memberId}`);

        if (!memberId) {
            console.error('Member ID is required but not provided');
            return res.status(400).send('Member ID is required');
        }
        const query = `
            SELECT * FROM workouts
            WHERE member_id = $1;
        `;
        const values = [memberId];

        console.log(`Executing SQL query: ${query} with memberId: ${memberId}`);
        const result = await pool.query(query, values);

        console.log(`Workouts fetched successfully for memberId: ${memberId}`);
        res.json(result.rows);
    } catch (err) {
        console.error(`Error during fetching workouts for memberId: ${req.params.memberId}, Error: ${err.message}`);
        res.status(500).send(err.message);
    }
});

/**
 * @api {get} /membersMetrics/:memberId Get Member's Metrics
 * @apiDescription Retrieve physical metrics data for a specific member.
 * @apiParam {Number} memberId ID of the member.
 * @apiResponse {Array} metrics Array of metric records.
 * @apiError 400 Member ID required.
 * @apiError 500 Internal Server Error.
 */

app.get('/membersMetrics/:memberId', authenticate, async (req, res) => {
    try {
        const { memberId } = req.params;
        if (!memberId) {
            console.error('Member ID is required but not provided');
            return res.status(400).send('Member ID is required');
        }
        const query = `
            SELECT * FROM members_metrics
            WHERE member_id = $1;
        `;
        const values = [memberId];

        console.log(`Executing SQL query: ${query} with memberId: ${memberId}`);
        const result = await pool.query(query, values);

        console.log(`Metrics fetched successfully for memberId: ${memberId}`);
        res.json(result.rows);
    } catch (err) {
        console.error(`Error during fetching metrics for memberId: ${memberId}, Error: ${err.message}`);
        res.status(500).send(err.message);
    }
});

/**
 * @api {post} /createWorkout/:memberId Create Workout
 * @apiDescription Create a new workout record for a member.
 * @apiParam {Number} memberId ID of the member.
 * @apiBody {String} workoutName Name of the workout.
 * @apiBody {Array} exerciseIds Array of exercise IDs included in the workout.
 * @apiResponse {String} message Success message.
 * @apiError 400 Missing required fields.
 * @apiError 500 Internal Server Error.
 */

app.post('/createWorkout/:memberId', authenticate, async (req, res) => {
    try {
        const { memberId } = req.params;
        const { workoutName, exerciseIds } = req.body;

        console.log(`Received workout creation request for memberId: ${memberId}`);
        console.log(`Workout Name: ${workoutName}, Exercise IDs: ${exerciseIds}`);

        // Validate the input
        if (!workoutName || !Array.isArray(exerciseIds) || exerciseIds.length === 0) {
            console.warn('Validation failed: Missing required fields');
            return res.status(400).send('Missing required fields');
        }

        const query = `
            INSERT INTO workouts (member_id, workout_name, exercise_ids)
            VALUES ($1, $2, $3);
        `;
        const values = [memberId, workoutName, exerciseIds];

        console.log('Executing query to insert new workout:', query);
        console.log('Values:', values);

        await pool.query(query, values);

        console.log('Workout created successfully for memberId:', memberId);
        res.send('Workout created successfully');
    } catch (err) {
        console.error(`Error during workout creation for memberId ${memberId}: ${err.message}`);
        res.status(500).send(err.message);
    }
});

/**
 * @api {get} /exercises Fetch Exercises
 * @apiDescription Retrieve a list of all exercises.
 * @apiResponse {Array} exercises Array of exercise records.
 * @apiError 404 No exercises found.
 * @apiError 500 Internal Server Error.
 */
app.get('/exercises', async (req, res) => {
    const page = parseInt(req.query.page) || 1;
    const limit = 50;
    const offset = (page - 1) * limit;

    try {
        const query = 'SELECT * FROM exercises LIMIT $1 OFFSET $2';
        const result = await pool.query(query, [limit, offset]);

        if (result.rows.length > 0) {
            res.json(result.rows);
        } else {
            res.status(404).send('No exercises found');
        }
    } catch (err) {
        console.error(`Error fetching exercises: ${err.message}`);
        res.status(500).send('Internal Server Error');
    }
});
/**
 * @api {get} /exercises/search?workoutId=:workoutId Get Exercises for Specific Workout
 * @apiDescription Retrieve details of all exercises in a specific workout based on the workout ID.
 * @apiParam {Number} workoutId ID of the workout.
 * @apiResponse {JSON} exercises Array of exercise details (title, equipment, difficulty, and id).
 * @apiError 400 Invalid workoutId.
 * @apiError 404 No exercises found for the workout.
 * @apiError 500 Internal Server Error.
 */
app.get('/exercises/search', async (req, res) => {
    try {
        let workoutId = parseInt(req.query.workoutId, 10);

        if (isNaN(workoutId)) {
            return res.status(400).send('Invalid workoutId');
        }

        const workoutQuery = `
            SELECT exercise_ids
            FROM workouts
            WHERE workout_id = $1;
        `;
        const workoutResult = await pool.query(workoutQuery, [workoutId]);

        if (workoutResult.rows.length === 0) {
            return res.status(404).send('No exercises found for this workout');
        }

        const exerciseIds = workoutResult.rows[0].exercise_ids;
        const exercisesQuery = `
            SELECT id, title, equipment, difficulty
            FROM exercises
            WHERE id = ANY($1::int[]);
        `;
        const exercisesResult = await pool.query(exercisesQuery, [exerciseIds]);

        res.json(exercisesResult.rows);
    } catch (err) {
        console.error(`Error retrieving exercises for workout: ${err.message}`);
        res.status(500).send('Internal Server Error');
    }
});
app.get('/fetchSafeData/:memberId', async (req, res) => {
    try {
        const { memberId } = req.params;
        if (!memberId || isNaN(parseInt(memberId))) {
            return res.status(400).send('Invalid memberId');
        }

        const client = await pool.connect();
        try {
            const memberQuery = `SELECT first_name, date_of_birth FROM members WHERE member_id = $1`;
            const workoutsQuery = `
                SELECT workouts.workout_name, unnest(workouts.exercise_ids) as exercise_id 
                FROM workouts 
                WHERE member_id = $1
            `;
            const exerciseQuery = `
                SELECT id, title FROM exercises WHERE id = ANY($1::int[])
            `;

            const memberResult = await client.query(memberQuery, [memberId]);

            if (memberResult.rows.length === 0) {
                return res.status(404).send('Member not found');
            }

            const workoutsResult = await client.query(workoutsQuery, [memberId]);
            const exerciseIds = [...new Set(workoutsResult.rows.map(row => row.exercise_id))];
            const exerciseResult = await client.query(exerciseQuery, [exerciseIds]);
            const exerciseTitleMap = new Map(exerciseResult.rows.map(row => [row.id, row.title]));

            const workoutDetails = workoutsResult.rows.reduce((acc, row) => {
                const workout = acc.find(w => w.workoutName === row.workout_name);

                if (workout) {
                    workout.exerciseTitles.push(exerciseTitleMap.get(row.exercise_id));
                } else {
                    acc.push({
                        workoutName: row.workout_name,
                        exerciseTitles: [exerciseTitleMap.get(row.exercise_id)],
                    });
                }

                return acc;
            }, []);

            console.log('Workout Details:', workoutDetails);

            const responseData = {
                firstName: memberResult.rows[0].first_name,
                dateOfBirth: memberResult.rows[0].date_of_birth,
                workouts: workoutDetails.map(workout => ({
                    workoutName: workout.workoutName,
                    exerciseTitles: workout.exerciseTitles
                }))
            };

            res.json(responseData);
        } finally {
            client.release();
        }
    } catch (error) {
        console.error('Error fetching safe data', error);
        res.status(500).send('Internal Server Error');
    }
});

app.get('/exercises/search', async (req, res) => {
    const searchQuery = req.query.q;
    const query = 'SELECT * FROM exercises WHERE name ILIKE $1';
    try {
        const result = await pool.query(query, [`%${searchQuery}%`]);
        res.json(result.rows);
    } catch (err) {
        console.error(`Error on search: ${err.message}`);
        res.status(500).send('Internal Server Error');
    }
});

// DELETE endpoint for deleting a workout
app.delete('/workouts/:workoutId', authenticate, async (req, res) => {
    try {
        const { workoutId } = req.params;
        if (!workoutId) {
            return res.status(400).send('Workout ID is required');
        }

        const query = 'DELETE FROM workouts WHERE workout_id = $1;';
        const result = await pool.query(query, [workoutId]);

        if (result.rowCount > 0) {
            res.status(200).send('Workout deleted successfully');
        } else {
            res.status(404).send('Workout not found');
        }
    } catch (err) {
        console.error(`Error deleting workout: ${err.message}`);
        res.status(500).send(err.message);
    }
});

// PUT endpoint for renaming a workout
app.put('/workouts/:workoutId', authenticate, async (req, res) => {
    try {
        const { workoutId } = req.params;
        const { newName } = req.body;

        if (!workoutId || !newName) {
            return res.status(400).send('Workout ID and new name are required');
        }

        const query = 'UPDATE workouts SET workout_name = $1 WHERE workout_id = $2;';
        const result = await pool.query(query, [newName, workoutId]);

        if (result.rowCount > 0) {
            res.status(200).send('Workout renamed successfully');
        } else {
            res.status(404).send('Workout not found');
        }
    } catch (err) {
        console.error(`Error renaming workout: ${err.message}`);
        res.status(500).send(err.message);
    }
});

async function authenticate(req, res, next) {
    try {
        const { memberId } = req.params;
        const authKey = req.header('Auth-Key');

        console.log(`Authenticating memberId: ${memberId} with authKey: ${authKey}`);

        const query = 'SELECT auth_key FROM members WHERE member_id = $1';
        const result = await pool.query(query, [memberId]);

        if (result.rows.length > 0) {
            console.log(`Stored authKey for memberId ${memberId}: ${result.rows[0].auth_key}`);
            if (result.rows[0].auth_key === authKey) {
                next();
            } else {
                res.status(401).send('Unauthorized: Invalid authKey');
            }
        } else {
            res.status(401).send('Unauthorized: memberId not found');
        }
    } catch (error) {
        console.error('Authentication error', error);
        res.status(500).send('Internal Server Error');
    }
}

app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});