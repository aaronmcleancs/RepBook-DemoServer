Full Stack iOS Fitness Tracking Application

===============================================

Table of Contents
-----------------
1. Installation and Setup
2. RESTful API Endpoints

Installation and Setup
-----------------------
git clone https://github.com/AaronM26/RepBook.git
cd RepBook

  Backend Setup
cd /backend
npm install
# Replace OpenAI API Key in configuration
node repbook.js

Server Setup
- Run Demo Server in PostgreSQL

Frontend Setup
- Open `RepBook.xcodeproj` in Xcode
- Replace Server IP with your Postgres server IP
- Run the project in a simulator (iOS 17.x+)

RESTful API Endpoints
---------------------

+-------------------------------------+--------+--------------------------------+
| Endpoint                            | Method | Description                    |
+-------------------------------------+--------+--------------------------------+
| /api/signup                         | POST   | User Signup                    |
| /api/login                          | POST   | User Login                     |
| /api/checkUsername/:username        | GET    | Check Username Availability    |
| /api/exercises                      | POST   | Add Exercises to Workout       |
| /api/updateUserInfo/:memberId       | POST   | Update User Information        |
| /api/userDataAndMetrics/:memberId   | GET    | Fetch User Data and Metrics    |
| /api/setGymMembership               | POST   | Set Gym Membership             |
| /api/workouts/:memberId             | GET    | Get Workouts                   |
| /api/membersMetrics/:memberId       | GET    | Get Member's Metrics           |
| /api/createWorkout/:memberId        | POST   | Create Workout                 |
| /api/exercises                      | GET    | Fetch Exercises                |
+-------------------------------------+--------+--------------------------------+
