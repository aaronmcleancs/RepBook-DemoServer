import Foundation
import SwiftUI

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

extension Color {
    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)
}

struct NeumorphicGraphCardView: View {
    var data: GraphData
    var colorScheme: (dark: Color, med: Color, light: Color)
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(Color.offWhite)
            .frame(width: 350, height: 350)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
            .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
            .overlay(
                LineGraph(data: data, colorScheme: colorScheme)
            )
    }
}

struct WorkoutDetailsView: View {
    var workout: Workout

    var body: some View {
        Text("Detailed Workout Information")
            .padding()
            .background(Color.white)
            .cornerRadius(20)
    }
}

struct WeightEntryView: View {
    @Binding var weight: String
    @Binding var unit: WeightUnit

    var body: some View {
        HStack {
            TextField("Weight", text: $weight)
                .keyboardType(.decimalPad)
                .onChange(of: weight) { newValue in
                    let filtered = newValue.filter { "0123456789.".contains($0) }
                    weight = filtered
                }
                .frame(width: 80)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Picker("Unit", selection: $unit) {
                Text("lb").tag(WeightUnit.lbs)
                Text("kg").tag(WeightUnit.kg)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 100)
        }
    }
}

struct HeightEntryView: View {
    @Binding var heightFeet: String
    @Binding var heightInches: String

    var body: some View {
        HStack {
            TextField("Feet", text: $heightFeet)
                .keyboardType(.numberPad)
                .onChange(of: heightFeet) { newValue in
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if let intValue = Int(filtered), intValue <= 9 {
                        heightFeet = filtered
                    } else {
                        heightFeet = String(filtered.prefix(1))
                    }
                }
                .frame(width: 50)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Text("ft")

            TextField("Inches", text: $heightInches)
                .keyboardType(.numberPad)
                .onChange(of: heightInches) { newValue in
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if let intValue = Int(filtered), intValue <= 12 {
                        heightInches = filtered
                    } else {
                        heightInches = String(filtered.prefix(2))
                    }
                }
                .frame(width: 50)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Text("in")
        }
    }
}


struct WorkoutPlanCardView: View {
    let title: String = "ARM DAY"
    let day: Int = 4
    let streakCount: Int = 14
    let workouts: [String] = ["Push-Ups", "Pull-Ups", "Dumbbell Curls"]

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Day \(day)")
                        .font(.headline)
                        .foregroundColor(.gray)
                }

                Spacer()

                VStack {
                    Text("\(streakCount) Days")
                        .fontWeight(.semibold)
                    Text("Streak")
                        .font(.caption)
                }
                .padding(.trailing)
            }
            WorkoutPreviewScrollView(workouts: workouts)
        }
        .background(Color.white)
        .cornerRadius(25)
    }
}

struct WorkoutPreviewCardView: View {
    @Binding var workoutName: String
    @Binding var selectedExercises: [Exercise]
    let colorScheme = ColorSchemeManager.shared.currentColorScheme
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("Workout Name", text: $workoutName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Text("\(selectedExercises.count) Exercises")
                    .foregroundColor(.gray)
                    .padding(.trailing)
            }
            .padding(5)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(selectedExercises) { exercise in
                        ExerciseCardView(exercise: exercise, onRemove: {
                            if let index = selectedExercises.firstIndex(where: { $0.id == exercise.id }) {
                                selectedExercises.remove(at: index)
                            }
                        })
                    }
                }
            }
        }
        .padding()
    }
}

struct ExerciseCardView: View {
    var exercise: Exercise
    var onRemove: () -> Void
    @State private var reps: Int = 10 
    let colorScheme = ColorSchemeManager.shared.currentColorScheme

    private let cardWidth: CGFloat = 270
    private let cardHeight: CGFloat = 100

    var body: some View {
        VStack(alignment: .leading, spacing: 5) { 
            Text(exercise.title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)

            Text("Equipment: \(exercise.equipment), Difficulty: \(exercise.difficulty)")
                .font(.footnote)
                .foregroundColor(.gray)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer()

            HStack {
                Spacer()
                Button(action: onRemove) {
                    Image(systemName: "trash")
                        .foregroundColor(Color.gray)
                }
            }
        }
        .padding()
        .frame(width: cardWidth, height: cardHeight)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}


struct WorkoutCardView: View {
    var workout: Workout 
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(workout.workoutName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("\(workout.exerciseIds.count) exercises")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding([.top, .bottom, .leading])
                
                Spacer()
                
                Menu {
                    Button("Edit", action: editWorkout)
                    Button("Delete", action: deleteWorkout)
                    Button("Rename", action: renameWorkout)
                } label: {
                    Image(systemName: "ellipsis")
                        .imageScale(.large)
                        .foregroundColor(.black)
                }
                .padding([.top, .trailing])
            }
            .background(Color.gray.opacity(0.05))
            .cornerRadius(20)
            .onTapGesture {
                withAnimation(.easeInOut) {
                    isExpanded.toggle()
                }
            }

            if isExpanded {
                WorkoutDetailsView(workout: workout)
                    .transition(.slide)
            }
        }
        .shadow(color: Color.black.opacity(0.03), radius: 1, x: 2, y: 3)
        .padding(.horizontal)
    }

    private func editWorkout() {
    
    }

    private func deleteWorkout() {
  
    }

    private func renameWorkout() {
 
    }
}

struct WorkoutPreviewScrollView: View {
    let workouts: [String]
    @State private var currentIndex: Int = 0
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(workouts.indices, id: \.self) { index in
                Text(workouts[index])
                    .font(.title2)
                    .fontWeight(.medium)
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(height: 100)
        .onReceive(timer) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % workouts.count
            }
        }
    }
}

struct ExerciseCard: View {
    let exercise: Exercise
    let colorScheme = ColorSchemeManager.shared.currentColorScheme
    var onAdd: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(exercise.title) 
                    .font(.headline)
            }

            Spacer()

            Button(action: onAdd) {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .padding(9)
                    .foregroundColor(.black.opacity(0.7))
                    .cornerRadius(10)
            }
            .padding(.trailing, 10)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.gray.opacity(0.05)))
        .padding(.horizontal)
    }
}


struct CompressedExerciseCard: View {
    let exercise: Exercise

    var body: some View {
        VStack(alignment: .leading) {
            Text(exercise.title)
                .font(.headline)
            Text("Difficulty: \(exercise.difficulty)") 
                .font(.subheadline)
        }
        .padding()
        .frame(width: 150, height: 80)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.05)))
    }
}


struct CustomTabBar: View {
    @Binding var selection: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<4) { index in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        selection = index
                    }
                }) {
                    VStack {
                        Image(systemName: tabImageName(for: index))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: selection == index ? 32 : 24, height: selection == index ? 32 : 24)
                            .foregroundColor(selection == index ? .black.opacity(0.7) : .gray.opacity(0.45))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 60)
        .background(
            VisualEffectBlur(blurStyle: .systemThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 19))
                .padding([.leading, .trailing], 20)
        )
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
    
    func tabImageName(for index: Int) -> String {
        switch index {
        case 0:
            return "calendar.day.timeline.leading"
        case 1:
            return "figure.strengthtraining.traditional"
        case 2:
            return "message.fill"
        case 3:
            return "gearshape.fill"
        default:
            return ""
        }
    }
}
