import Foundation
import SwiftUI
import Combine

enum NetworkError: Error {
    case invalidURL
    case serverError
    case unexpectedResponse
}

struct SafeDataResponse: Decodable {
    let firstName: String
    let dateOfBirth: String
    let workouts: [WorkoutDetail]
}

struct WorkoutDetail: Decodable {
    let workoutName: String
    let exerciseTitles: [String]
}

struct MemberMetric: Codable {
    let memberId: Int
    let heightCm: Int
    let weightKg: Float
    let gender: String
    let workoutFrequency: Int
    let bodyFatPercentage: Float?
    let goalType: String?
    let activityLevel: String?
    let restingHeartRate: Int?
    let bmrCalories: Float?

    enum CodingKeys: String, CodingKey {
        case memberId = "member_id"
        case heightCm = "height_cm"
        case weightKg = "weight_kg"
        case gender
        case workoutFrequency = "workout_frequency"
        case bodyFatPercentage = "body_fat_percentage"
        case goalType = "goal_type"
        case activityLevel = "activity_level"
        case restingHeartRate = "resting_heart_rate"
        case bmrCalories = "bmr_calories"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        memberId = try container.decode(Int.self, forKey: .memberId)
        heightCm = try container.decode(Int.self, forKey: .heightCm)
        gender = try container.decode(String.self, forKey: .gender)
        workoutFrequency = try container.decode(Int.self, forKey: .workoutFrequency)
        
        if let weightFloat = try? container.decode(Float.self, forKey: .weightKg) {
            weightKg = weightFloat
        } else if let weightString = try? container.decode(String.self, forKey: .weightKg),
                  let weightFloat = Float(weightString) {
            weightKg = weightFloat
        } else {
            throw DecodingError.typeMismatch(
                Float.self,
                DecodingError.Context(
                    codingPath: [CodingKeys.weightKg],
                    debugDescription: "Expected Float or String convertible to Float for weightKg"
                )
            )
        }
        
        bodyFatPercentage = try? container.decode(Float.self, forKey: .bodyFatPercentage)
        goalType = try? container.decode(String.self, forKey: .goalType)
        activityLevel = try? container.decode(String.self, forKey: .activityLevel)
        restingHeartRate = try? container.decode(Int.self, forKey: .restingHeartRate)
        bmrCalories = try? container.decode(Float.self, forKey: .bmrCalories)
    }
}
struct DetailedWorkout: Codable {
    let workoutId: Int
    let memberId: Int
    let workoutName: String
    let exercises: [ExerciseDetails]

    enum CodingKeys: String, CodingKey {
        case workoutId = "workout_id"
        case memberId = "member_id"
        case workoutName = "workout_name"
        case exercises
    }
}

struct ExerciseDetails: Codable, Identifiable {
    let id: Int
    let title: String
    let equipment: String
    let difficulty: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case equipment
        case difficulty
    }
}

struct Achievement: Identifiable {
    let id: Int
    let image: String
    let title: String
    let subtitle: String
}

struct UserInfo: Decodable {
    var firstName: String
    var lastName: String
    var dateOfBirth: String
    var username: String
    var email: String

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case dateOfBirth = "date_of_birth"
        case username
        case email
    }
}

struct Workout: Codable {
    let workoutId: Int
    let memberId: Int
    let workoutName: String
    let exerciseIds: [Int]

    enum CodingKeys: String, CodingKey {
        case workoutId = "workout_id"
        case memberId = "member_id"
        case workoutName = "workout_name"
        case exerciseIds = "exercise_ids"
    }
}

struct Exercise: Identifiable, Decodable {
    let id: Int
    let title: String
    let equipment: String
    let difficulty: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case equipment
        case difficulty
    }
}

struct WorkoutLog: Codable {
    let memberId: Int
    let workoutId: Int
    let time: Int
}

enum WeightUnit: String, CaseIterable {
    case lbs = "lbs"
    case kg = "kg"
}

struct SignupResponse: Decodable {
    let memberId: Int
    let authKey: String
}

struct LoginResponse: Decodable {
    let memberId: Int
    let authKey: String

    enum CodingKeys: String, CodingKey {
        case memberId = "member_id"
        case authKey = "auth_key"
    }
}

class AppViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
}

struct TagView: View {
    var text: String
    var color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(5)
            .background(RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.04)))
            .foregroundColor(color)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color, lineWidth: 1)
            )
    }
}

struct CodableColor: Codable {
    var color: Color

    enum CodingKeys: String, CodingKey {
        case color
    }

    init(color: Color) {
        self.color = color
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let colorData = try container.decode(String.self, forKey: .color)
        self.color = Color(hex: colorData) ?? Color.white
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
    }
}

struct Reminder: Identifiable, Codable {
    var id = UUID()
    var title: String
    var dueDate: Date
}
