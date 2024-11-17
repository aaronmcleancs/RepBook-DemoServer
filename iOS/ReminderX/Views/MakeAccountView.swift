import SwiftUI
import UniformTypeIdentifiers
import CoreGraphics
import Alamofire
import Network
import Foundation
import Security

struct MemberMetricsView: View {
    @Binding var isAuthenticated: Bool
    
    var firstName: String
    var lastName: String
    var dateOfBirth: Date
    var email: String
    var password: String
    var username: String
    
    @State private var heightCm: Int = 0
    @State private var weightKg: Int = 0
    @State private var gender: String = ""
    @State private var workoutFrequency: Int = 0
    @State private var bodyFatPercentage: Float? = nil
    @State private var goalType: String = ""
    @State private var activityLevel: String = ""
    @State private var restingHeartRate: Int? = nil
    @State private var bmrCalories: Float? = nil
    
    @State private var currentTab: Int = 0
    
    var body: some View {
        VStack {
            Text("Enter Your Fitness Metrics")
                .font(.title)
                .padding()
            
            TabView(selection: $currentTab) {
                VStack {
                    formFieldInt(title: "Height in cm", value: $heightCm)
                    formFieldInt(title: "Weight in kg", value: $weightKg)
                    formFieldFloat(title: "Body Fat Percentage", value: $bodyFatPercentage)
                }
                .tag(0)
                .padding()
                
                VStack {
                    formFieldInt(
                        title: "Resting Heart Rate (bpm)",
                        value: Binding(
                            get: { restingHeartRate ?? 0 },
                            set: { restingHeartRate = $0 }
                        )
                    )
                    formFieldFloat(title: "Basal Metabolic Rate (BMR)", value: $bmrCalories)
                }
                .tag(1)
                .padding()
                
                VStack {
                    formFieldText(title: "Gender", text: $gender)
                    formFieldInt(title: "Workout Frequency per Week", value: $workoutFrequency)
                    formFieldText(title: "Fitness Goal (e.g., Weight Loss)", text: $goalType)
                    formFieldText(title: "Activity Level (e.g., Active)", text: $activityLevel)
                }
                .tag(2)
                .padding()
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            
            HStack {
                if currentTab > 0 {
                    Button(action: {
                        withAnimation {
                            currentTab -= 1
                        }
                    }) {
                        Text("Previous")
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                }
                
                Spacer()
                
                if currentTab < 2 {
                    Button(action: {
                        withAnimation {
                            currentTab += 1
                        }
                    }) {
                        Text("Next")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                } else {
                    Button("Complete Sign Up") {
                        uploadMemberMetrics()
                    }
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func formFieldInt(title: String, value: Binding<Int>) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            TextField("", value: value, format: .number)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .accessibility(label: Text(title))
                .accessibility(hint: Text("Enter your \(title.lowercased())"))
        }
        .padding(.horizontal)
    }
    
    private func formFieldFloat(title: String, value: Binding<Float?>) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.top)
            TextField("", value: Binding(
                get: { value.wrappedValue ?? 0.0 },
                set: { value.wrappedValue = $0 }
            ), format: .number)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .accessibility(label: Text(title))
                .accessibility(hint: Text("Enter your \(title.lowercased())"))
        }
        .padding(.horizontal)
    }
    
    private func formFieldText(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.top)
            TextField(title, text: text)
                .padding()
                .background(Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .accessibility(label: Text(title))
                .accessibility(hint: Text("Enter your \(title.lowercased())"))
        }
        .padding(.horizontal)
    }
    
    private func uploadMemberMetrics() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dobString = dateFormatter.string(from: dateOfBirth)
        let accountAndMetricsData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "dateOfBirth": dobString,
            "email": email,
            "password": password,
            "username": username,
            "heightCm": heightCm,
            "weightKg": weightKg,
            "gender": gender,
            "workoutFrequency": workoutFrequency,
            "bodyFatPercentage": bodyFatPercentage ?? 0.0,
            "goalType": goalType,
            "activityLevel": activityLevel,
            "restingHeartRate": restingHeartRate ?? 0,
            "bmrCalories": bmrCalories ?? 0.0
        ]
        
        NetworkManager.signUpUser(with: accountAndMetricsData) { result in
            switch result {
            case .success:
                print("Sign up successful")
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                }
            case .failure(let error):
                print("Error signing up: \(error)")
            }
        }
    }
}

struct MakeAccountView: View {
    @Binding var isAuthenticated: Bool
    @State private var isAccountInfoCompleted = false
    @State private var isMetricsInfoCompleted = false
    @State private var isEmailValid: Bool = true
    @State private var passwordWarning: String = ""
    @State private var username: String = ""
    @State private var isUsernameAvailable: Bool? = nil
    @State private var debounceTimer: Timer?
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var dateOfBirth = Date()
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack {
            Image("login_banner")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300)
                .padding(20)
            
            if !isAccountInfoCompleted {
                accountInfoForm
            } else {
                MemberMetricsView(
                    isAuthenticated: $isAuthenticated,
                    firstName: firstName,
                    lastName: lastName,
                    dateOfBirth: dateOfBirth,
                    email: email,
                    password: password,
                    username: username
                )
            }
            
            Spacer()
        }
        .background(Color.white.opacity(0.5).edgesIgnoringSafeArea(.all))
    }
    
    var accountInfoForm: some View {
        VStack {
            formField(title: "First Name", text: $firstName)
            formField(title: "Last Name", text: $lastName)
            formField(title: "Username", text: $username)
                .onChange(of: username) { _ in
                    debounceUsernameCheck()
                }
            if let isAvailable = isUsernameAvailable {
                Image(systemName: isAvailable ? "checkmark.circle" : "xmark.circle")
                    .foregroundColor(isAvailable ? .green : .red)
            }
            DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                .padding()
                .background(Color.white.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.horizontal)
                .accessibility(label: Text("Date of Birth"))
                .accessibility(hint: Text("Select your date of birth"))
            
            HStack {
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.horizontal)
                    .onChange(of: email) { _ in validateEmail() }
                    .accessibility(label: Text("Email"))
                    .accessibility(hint: Text("Enter your email address"))
                
                if !isEmailValid {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                        .padding(.trailing, 30)
                        .accessibility(label: Text("Invalid email"))
                        .accessibility(hint: Text("Please enter a valid email address"))
                }
            }
            
            HStack {
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white.opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.horizontal)
                    .onChange(of: password) { _ in validatePassword() }
                    .accessibility(label: Text("Password"))
                    .accessibility(hint: Text("Enter your password"))
                
                if !passwordWarning.isEmpty {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                        .padding(.trailing, 30)
                        .accessibility(label: Text("Password warning"))
                        .accessibility(hint: Text(passwordWarning))
                }
            }
            
            if !passwordWarning.isEmpty {
                Text(passwordWarning)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            if allFieldsValid() {
                Button("Sign Up") {
                    isAccountInfoCompleted = true
                }
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.horizontal)
            }
        }
    }
    
    private func formField(title: String, text: Binding<String>) -> some View {
        TextField(title, text: text)
            .padding()
            .background(Color.white.opacity(0.8))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding(.horizontal)
            .accessibility(label: Text(title))
            .accessibility(hint: Text("Enter your \(title.lowercased())"))
    }
    
    private func validatePassword() {
        passwordWarning = ""
        
        if password.count < 8 {
            passwordWarning += "Password must be at least 8 characters. "
        }
        
        if !passwordContainsNumber() {
            passwordWarning += "Password must contain at least one number."
        }
    }
    
    private func passwordContainsNumber() -> Bool {
        let numberRange = password.rangeOfCharacter(from: .decimalDigits)
        return numberRange != nil
    }

    private func debounceUsernameCheck() {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [self] _ in
            self.checkUsernameAvailability()
        }
    }
    
    private func validateEmail() {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        isEmailValid = emailTest.evaluate(with: email)
    }
    
    func checkUsernameAvailability() {
        guard !username.isEmpty else {
            isUsernameAvailable = nil
            return
        }

        if let url = URL(string: "http://192.168.0.139:3000/checkUsername/\(username)") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    if let response = try? JSONDecoder().decode([String: Bool].self, from: data) {
                        DispatchQueue.main.async {
                            self.isUsernameAvailable = response["isAvailable"]
                        }
                    }
                }
            }.resume()
        }
    }
    
    private func allFieldsValid() -> Bool {
        return !firstName.isEmpty && !lastName.isEmpty && isEmailValid && !password.isEmpty
    }
}
