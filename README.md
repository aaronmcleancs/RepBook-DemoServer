Full Stack iOS Fitness Tracking Application (Objective-C, Node.js, Express, PostresSQL) 

Good template for basic user auth and multiview

<table style="border-collapse: separate; border-spacing: 10px;">
  <tr>
    <td style="text-align: center; vertical-align: top; width: 200px;">
      <img src="https://github.com/user-attachments/assets/5ba9fb6a-a443-4630-a410-58f050833e32" width="200" height="400" />
    </td>
    <td style="text-align: center; vertical-align: top; width: 200px;">
      <img src="https://github.com/user-attachments/assets/fd344156-c0f8-4005-a561-59f4ff8404c2" width="200" height="400" />
    </td>
    <td style="text-align: center; vertical-align: top; width: 200px;">
      <img src="https://github.com/user-attachments/assets/0aa57b5b-f10f-408f-888f-5286a79993cd" width="200" height="400" />
    </td>
  </tr>
</table>



===============================================

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
