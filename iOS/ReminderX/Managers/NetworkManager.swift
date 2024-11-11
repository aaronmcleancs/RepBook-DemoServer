import Alamofire
import Network
import Foundation
import Security

class NetworkManager {
    static func createWorkout(memberId: Int, workoutName: String, exerciseIds: [Int], authKey: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "http://192.168.0.154:3000/createWorkout/\(memberId)") else {
            print("Invalid URL")
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(authKey, forHTTPHeaderField: "Auth-Key")
        
        let body: [String: Any] = [
            "workoutName": workoutName,
            "exerciseIds": exerciseIds
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Error encoding request body: \(error)")
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error creating workout: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Unexpected response status code")
                completion(.failure(NetworkError.serverError))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
    static func fetchDetailedWorkoutData(workoutId: Int, authKey: String, completion: @escaping (Result<DetailedWorkout, Error>) -> Void) {
        guard let url = URL(string: "http://192.168.0.154:3000/detailedWorkout/\(workoutId)") else {
            print("Invalid URL")
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(authKey, forHTTPHeaderField: "Auth-Key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching detailed workout data: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                print("Unexpected response status code or no data")
                completion(.failure(NetworkError.unexpectedResponse))
                return
            }
            
            do {
                let detailedWorkout = try JSONDecoder().decode(DetailedWorkout.self, from: data)
                completion(.success(detailedWorkout))
            } catch {
                print("Error decoding detailed workout data: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    static func fetchWorkoutsForMember(memberId: Int, authKey: String, completion: @escaping (Result<[Workout], Error>) -> Void) {
        guard let url = URL(string: "http://192.168.0.154:3000/workouts/\(memberId)") else {
            print("Invalid URL")
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(authKey, forHTTPHeaderField: "Auth-Key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching workouts: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data {
                do {
                    let workouts = try JSONDecoder().decode([Workout].self, from: data)
                    completion(.success(workouts))
                } catch {
                    print("Error decoding workouts: \(error)")
                    completion(.failure(error))
                }
            } else {
                print("Unexpected response status code or no data")
                completion(.failure(NetworkError.unexpectedResponse))
            }
        }.resume()
    }
    static func fetchSafeData(for memberId: Int, authKey: String, completion: @escaping (Result<SafeDataResponse, Error>) -> Void) {
        guard let url = URL(string: "http://192.168.0.154:3000/fetchSafeData/\(memberId)") else {
            print("Invalid URL")
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(authKey, forHTTPHeaderField: "Auth-Key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching safe data: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data {
                do {
                    let safeData = try JSONDecoder().decode(SafeDataResponse.self, from: data)
                    completion(.success(safeData))
                } catch {
                    print("Error decoding safe data: \(error)")
                    completion(.failure(error))
                }
            } else {
                print("Unexpected response status code or no data")
                completion(.failure(NetworkError.unexpectedResponse))
            }
        }.resume()
    }
    static func fetchMemberMetrics(memberId: Int, authKey: String, completion: @escaping (Result<[MemberMetric], Error>) -> Void) {
        guard let url = URL(string: "http://192.168.0.154:3000/membersMetrics/\(memberId)") else {
            print("Invalid URL")
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(authKey, forHTTPHeaderField: "Auth-Key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching member metrics: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                print("Unexpected response status code or no data")
                completion(.failure(NetworkError.unexpectedResponse))
                return
            }
            
            do {
                let memberMetrics = try JSONDecoder().decode([MemberMetric].self, from: data)
                completion(.success(memberMetrics))
            } catch {
                print("Error decoding member metrics: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    static func fetchUserDataAndMetrics(memberId: Int, authKey: String, completion: @escaping (UserInfo?) -> Void) {
        guard let url = URL(string: "http://192.168.0.154:3000/userDataAndMetrics/\(memberId)") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(authKey, forHTTPHeaderField: "Auth-Key")
        
        print("Fetching user data and metrics for memberId: \(memberId) with authKey: \(authKey)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200, let data = data {
                    do {
                        let userData = try JSONDecoder().decode(UserInfo.self, from: data)
                        completion(userData)
                    } catch {
                        print("Error decoding user data: \(error)")
                        completion(nil)
                    }
                } else {
                    print("Unexpected response status code")
                    completion(nil)
                }
            } else {
                print("No HTTP response received")
                completion(nil)
            }
        }.resume()
    }
    static func signUpUser(with data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "http://192.168.0.154:3000/signup") else {
            print("Invalid URL")
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
        } catch {
            print("Error encoding request body: \(error)")
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error during sign up: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                print("Unexpected response status code")
                completion(.failure(NetworkError.serverError))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
    static func fetchExercises(page: Int, completion: @escaping ([Exercise]) -> Void) {
        guard let url = URL(string: "http://192.168.0.154:3000/exercises?page=\(page)") else {
            print("Invalid URL")
            completion([])
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching exercises: \(error.localizedDescription)")
                completion([])
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data {
                do {
                    let exercises = try JSONDecoder().decode([Exercise].self, from: data)
                    completion(exercises)
                } catch {
                    print("Error decoding exercises: \(error)")
                    completion([])
                }
            } else {
                print("Unexpected response status code or no data")
                completion([])
            }
        }.resume()
    }
    static func fetchExercisesForWorkout(workoutId: Int, authKey: String, completion: @escaping (Result<[Exercise], Error>) -> Void) {
        guard let url = URL(string: "http://192.168.0.154:3000/exercises/search?workoutId=\(workoutId)") else {
            print("Invalid URL")
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(authKey, forHTTPHeaderField: "Auth-Key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching exercises: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                print("Unexpected response status code or no data")
                completion(.failure(NetworkError.unexpectedResponse))
                return
            }
            
            do {
                let exercises = try JSONDecoder().decode([Exercise].self, from: data)
                completion(.success(exercises))
            } catch {
                print("Error decoding exercises: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    static func deleteWorkout(workoutId: Int, authKey: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://192.168.0.154:3000/workouts/\(workoutId)") else {
            print("Invalid URL")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue(authKey, forHTTPHeaderField: "Auth-Key")
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Error deleting workout: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode == 200)
            } else {
                completion(false)
            }
        }.resume()
    }
    
    static func renameWorkout(workoutId: Int, newName: String, authKey: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://192.168.0.154:3000/workouts/\(workoutId)") else {
            print("Invalid URL")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(authKey, forHTTPHeaderField: "Auth-Key")
        let params = ["newName": newName]
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Error renaming workout: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode == 200)
            } else {
                completion(false)
            }
        }.resume()
    }
    static func logWorkout(memberId: Int, workoutId: Int, time: Int, authKey: String, completion: @escaping (Result<WorkoutLog, Error>) -> Void) {
           guard let url = URL(string: "http://192.168.0.154:3000/loggedWorkouts") else {
               print("Invalid URL")
               completion(.failure(NetworkError.invalidURL))
               return
           }

           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.addValue("application/json", forHTTPHeaderField: "Content-Type")
           request.addValue(authKey, forHTTPHeaderField: "Auth-Key")
           
           // Create the body data
           let workoutLog = WorkoutLog(memberId: memberId, workoutId: workoutId, time: time)

           do {
               let encoder = JSONEncoder()
               let jsonData = try encoder.encode(workoutLog)
               request.httpBody = jsonData
               print("Request Body: \(String(data: jsonData, encoding: .utf8)!)")
           } catch {
               print("Error encoding workout log: \(error)")
               completion(.failure(error))
               return
           }

           URLSession.shared.dataTask(with: request) { data, response, error in
               if let error = error {
                   print("Error logging workout: \(error.localizedDescription)")
                   completion(.failure(error))
                   return
               }
               
               if let httpResponse = response as? HTTPURLResponse {
                   print("Response Status Code: \(httpResponse.statusCode)")
               }

               if let data = data, let responseDataString = String(data: data, encoding: .utf8) {
                   print("Response Data: \(responseDataString)")
               }

               guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                   print("Unexpected response status code or no data")
                   completion(.failure(NetworkError.unexpectedResponse))
                   return
               }

               do {
                   let loggedWorkout = try JSONDecoder().decode(WorkoutLog.self, from: data)
                   completion(.success(loggedWorkout))
               } catch {
                   print("Error decoding logged workout: \(error)")
                   completion(.failure(error))
               }
           }.resume()
       }
}
