import SwiftUI
import Combine

struct WorkoutDetailView: View {
    let workout: Workout
    let exercises: [Exercise]

    @State private var currentExerciseIndex: Int = 0
    @State private var repCount: Int = 4
    @State private var setCount: Int = 10
    @State private var timerValue: Int = 0
    @State private var timerSubscription: AnyCancellable?
    @Environment(\.dismiss) var dismiss

    let gradientColors = [ColorSchemeManager.shared.currentColorScheme.med, ColorSchemeManager.shared.currentColorScheme.light]

    var body: some View {
        ZStack {
            backgroundView
            VStack(spacing: 16) {
                headerView
                if let exercise = currentExercise() {
                    exerciseDetailView(exercise: exercise)
                    countControls
                }
                Spacer()
                navigationButtons
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
            .shadow(color: .gray.opacity(0.3), radius: 8, x: 2, y: 2)
            .padding()
            .onAppear(perform: startTimer)
            .onDisappear(perform: stopTimer)
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
            .blur(radius: 50)
            .edgesIgnoringSafeArea(.all)
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            Text(workout.workoutName)
                .font(.title)
                .bold()
                .foregroundColor(.primary)
            Text("Time Elapsed: \(timerValue) s")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }

    private func exerciseDetailView(exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(exercise.title)
                .font(.headline)
                .bold()
            HStack(spacing: 8) {
                GradientTag(text: exercise.equipment, gradientColors: gradientColors)
                GradientTag(text: exercise.difficulty, gradientColors: gradientColors)
            }
        }
        .padding(.horizontal)
    }

    private var countControls: some View {
        HStack {
            Spacer()
            CounterView(value: $repCount, label: "Reps")
            Spacer()
            CounterView(value: $setCount, label: "Sets")
            Spacer()
        }
        .padding(.horizontal)
    }

    private var navigationButtons: some View {
        HStack(spacing: 20) {
            Button(action: previousExercise) {
                Text("Previous")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
            }
            .disabled(currentExerciseIndex == 0)
            
            Button(action: endWorkout) {
                Text("Finish")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
            }
            
            Button(action: nextExercise) {
                Text("Next")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
            }
            .disabled(currentExerciseIndex == exercises.count - 1)
        }
        .padding()
    }

    func currentExercise() -> Exercise? {
        guard currentExerciseIndex >= 0 && currentExerciseIndex < exercises.count else { return nil }
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
        dismiss()
    }

    private func startTimer() {
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in timerValue += 1 }
    }

    private func stopTimer() {
        timerSubscription?.cancel()
    }
}

struct CounterView: View {
    @Binding var value: Int
    let label: String

    var body: some View {
        VStack {
            Text(label)
                .font(.subheadline)
            HStack {
                Button(action: { if value > 1 { value -= 1 } }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                }
                Text("\(value)")
                    .font(.title3)
                    .bold()
                    .padding(.horizontal)
                Button(action: { value += 1 }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
    }
}
