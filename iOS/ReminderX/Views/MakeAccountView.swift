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
    
    var body: some View {
        VStack {
            Text("Enter Your Fitness Metrics")
                .font(.title)
                .padding()
            
            formFieldInt(title: "Height in cm", value: $heightCm)
            formFieldInt(title: "Weight in kg", value: $weightKg)
            formFieldText(title: "Gender", text: $gender)
            formFieldInt(title: "Workout Frequency per Week", value: $workoutFrequency)
            
            Button("Complete Sign Up") {
                uploadMemberMetrics()
            }
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding(.horizontal)
        }
    }
    private func formFieldInt(title: String, value: Binding<Int>) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.top)
            TextField("", value: value, format: .number)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 15))
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
                .clipShape(RoundedRectangle(cornerRadius: 15))
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
                "workoutFrequency": workoutFrequency
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
                      } else if !isMetricsInfoCompleted {
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
            if let isAvailable = isUsernameAvailable {
                Image(systemName: isAvailable ? "checkmark.circle" : "xmark.circle")
                    .foregroundColor(isAvailable ? .green : .red)
            }
            DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                .padding()
                .background(Color.white.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.horizontal)
            
            HStack {
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.horizontal)
                    .onChange(of: email) { _ in validateEmail() }
                
                if !isEmailValid {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                        .padding(.trailing, 30)
                }
            }
            
            HStack {
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.horizontal)
                    .onChange(of: password) { _ in validatePassword() }
                
                if !passwordWarning.isEmpty {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                        .padding(.trailing, 30)
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
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding(.horizontal)
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

        if let url = URL(string: "http://192.168.0.146:3000/checkUsername/\(username)") {
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
