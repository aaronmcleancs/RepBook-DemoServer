import SwiftUI
import Combine

struct WorkoutDetailView: View {
    let workout: Workout
    let exercises: [Exercise]

    @State private var currentExerciseIndex: Int = 0
    @State private var repCount: Int = 1
    @State private var setCount: Int = 1
    @State private var timerValue: Int = 0 // Start the timer value at 0
    @State private var timerSubscription: AnyCancellable?

    let gradientColors = [ColorSchemeManager.shared.currentColorScheme.med, ColorSchemeManager.shared.currentColorScheme.light]

    var body: some View {
        ZStack {
            backgroundView
            VStack(spacing: 20) {
                headerView
                if let exercise = currentExercise() {
                    exerciseDetailView(exercise: exercise)
                    countControls
                }
                Spacer()
                navigationButtons
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
            .shadow(color: .gray.opacity(0.3), radius: 10, x: 2, y: 2)
            .padding()
            .onAppear(perform: startTimer) // Start timer when view appears
            .onDisappear(perform: stopTimer) // Stop timer when view disappears
        }
    }

    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 0)
            .fill(
                AngularGradient(
                    gradient: Gradient(colors: gradientColors),
                    center: .center,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360)
                )
            )
            .blur(radius: 70)
            .edgesIgnoringSafeArea(.all)
    }

    private var headerView: some View {
        HStack {
            Text(workout.workoutName)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.black.opacity(0.8))
            Spacer()
            Text("Time: \(timerValue)s")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .padding()
    }

    private func exerciseDetailView(exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(exercise.title)
                .font(.title)
                .bold()
            HStack(spacing: 10) {
                GradientTag(text: "\(exercise.equipment)", gradientColors: gradientColors)
                GradientTag(text: "\(exercise.difficulty)", gradientColors: gradientColors)
            }
        }
        .padding()
    }

    private var countControls: some View {
        VStack {
            CounterView(value: $repCount, label: "Reps")
            CounterView(value: $setCount, label: "Sets")
        }
        .padding(.horizontal)
    }

    private var navigationButtons: some View {
        HStack {
            Button(action: previousExercise) {
                Text("Previous Exercise")
                    .foregroundColor(.blue)
            }
            Spacer()
            Button(action: nextExercise) {
                Text("Next Exercise")
                    .foregroundColor(.blue)
            }
            Spacer()
            Button(action: endWorkout) {
                Text("End Workout")
                    .foregroundColor(.red)
            }
        }
        .padding()
    }

    // Utility methods
    func currentExercise() -> Exercise? {
        guard currentExerciseIndex >= 0 && currentExerciseIndex < exercises.count else {
            return nil
        }
        return exercises[currentExerciseIndex]
    }

    func nextExercise() {
        if currentExerciseIndex < exercises.count - 1 {
            currentExerciseIndex += 1
        }
    }

    func previousExercise() {
        if currentExerciseIndex > 0 {
            currentExerciseIndex -= 1
        }
    }

    func endWorkout() {
           if let memberIdData = KeychainManager.load(service: "YourAppService", account: "userId"),
              let memberIdString = String(data: memberIdData, encoding: .utf8),
              let memberId = Int(memberIdString),
              let authKeyData = KeychainManager.load(service: "YourAppService", account: "authKey"),
              let authKey = String(data: authKeyData, encoding: .utf8) {
              
              print("Member ID: \(memberId), Auth Key: \(authKey)")

              NetworkManager.logWorkout(memberId: memberId, workoutId: workout.workoutId, time: timerValue, authKey: authKey) { result in
                  DispatchQueue.main.async {
                      switch result {
                      case .success(let loggedWorkout):
                          print("Workout logged successfully: \(loggedWorkout)")
                      case .failure(let error):
                          print("Failed to log workout: \(error.localizedDescription)")
                      }
                  }
              }
           } else {
               print("Failed to retrieve credentials")
           }
       }
    // Timer methods
    private func startTimer() {
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                timerValue += 1
            }
    }

    private func stopTimer() {
        timerSubscription?.cancel()
    }
}

struct CounterView: View {
    @Binding var value: Int
    let label: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
            Spacer()
            Button(action: { if value > 1 { value -= 1 } }) {
                Image(systemName: "minus.circle.fill")
            }
            .font(.largeTitle)
            Text("\(value)")
                .font(.largeTitle)
                .bold()
                .padding(.horizontal)
            Button(action: { value += 1 }) {
                Image(systemName: "plus.circle.fill")
            }
            .font(.title)
        }
    }
}
