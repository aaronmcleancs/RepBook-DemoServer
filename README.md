Full Stack iOS Fitness Tracking Application

<table style="border-collapse: separate; border-spacing: 10px;">
  <tr>
    <td style="text-align: center; vertical-align: top; width: 250px;">
      <strong>Personal Dashboard</strong><br>
      <div style="width: 250px; height: 400px; overflow: hidden;">
        <img src="https://github.com/user-attachments/assets/5ba9fb6a-a443-4630-a410-58f050833e32" style="width: 100%; height: 100%; object-fit: cover; object-position: center;"/>
      </div>
    </td>
    <td style="text-align: center; vertical-align: top; width: 250px;">
      <strong>Workout Builder</strong><br>
      <div style="width: 250px; height: 400px; overflow: hidden;">
        <img src="https://github.com/user-attachments/assets/fd344156-c0f8-4005-a561-59f4ff8404c2" style="width: 100%; height: 100%; object-fit: cover; object-position: center;"/>
      </div>
    </td>
    <td style="text-align: center; vertical-align: top; width: 250px;">
      <strong>AI-Assistant</strong><br>
      <div style="width: 250px; height: 400px; overflow: hidden;">
      <img src="https://github.com/user-attachments/assets/0aa57b5b-f10f-408f-888f-5286a79993cd" style="width: 100%; height: 100%; object-fit: cover; object-position: center;"/>
      </div>
    </td>
    <td style="text-align: center; vertical-align: top; width: 250px;">
      <strong>Personalized</strong><br>
      <div style="width: 250px; height: 400px; overflow: hidden;">
        <img src="https://github.com/user-attachments/assets/50f81a5d-d121-40cb-9623-8f577f37018c" style="width: 100%; height: 100%; object-fit: cover; object-position: center;"/>
      </div>
    </td>
  </tr>
</table>

<img width="1778" alt="RBUML" src="https://github.com/user-attachments/assets/1c27c927-8b97-4d78-ab7f-f7a966dc2a05">

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

### RESTful API Endpoints

| Endpoint                          | Method | Description                  |
|-----------------------------------|--------|------------------------------|
| `/api/signup`                     | POST   | User Signup                  |
| `/api/login`                      | POST   | User Login                   |
| `/api/checkUsername/:username`    | GET    | Check Username Availability  |
| `/api/exercises`                  | POST   | Add Exercises to Workout     |
| `/api/updateUserInfo/:memberId`   | POST   | Update User Information      |
| `/api/userDataAndMetrics/:memberId`| GET   | Fetch User Data and Metrics  |
| `/api/setGymMembership`           | POST   | Set Gym Membership           |
| `/api/workouts/:memberId`         | GET    | Get Workouts                 |
| `/api/membersMetrics/:memberId`   | GET    | Get Member's Metrics         |
| `/api/createWorkout/:memberId`    | POST   | Create Workout               |
| `/api/exercises`                  | GET    | Fetch Exercises              |
