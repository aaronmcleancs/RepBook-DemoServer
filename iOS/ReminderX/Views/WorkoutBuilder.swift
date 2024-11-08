import Foundation
import SwiftUI

struct WorkoutBuilderView: View {
    @Binding var isPresented: Bool
    @State private var exercises: [Exercise] = []
    @State private var selectedExercises: [Exercise] = []
    @State private var workoutName: String = "New Workout"
    @State private var searchText: String = ""
    @State private var isLoading = true
    @State private var isEditingWorkoutName = false
    @State private var currentPage = 1
    @State private var isLoadingMore = false
    @State private var hasMoreExercises = true

    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        } else {
            return exercises.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        VStack {
            WorkoutPreviewCardView(workoutName: $workoutName, selectedExercises: $selectedExercises)
            if !selectedExercises.isEmpty {
                Button(action: saveWorkout) {
                    Text("Save Workout")
                        .fontWeight(.bold)
                        .foregroundColor(Color.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(20)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }

            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.05))
                .overlay(
                    VStack {
                        exercisesHeader
                        exercisesList
                    }
                )
                .padding(.horizontal)
        }
        .onAppear(perform: loadExercises)
    }
    
    private var exercisesHeader: some View {
        VStack(alignment: .leading) {
            Text("Exercises")
                .font(.title)
                .bold()
            
            TextField("Search exercises", text: $searchText)
                .padding(10)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(15)
                .onChange(of: searchText) { _ in
                }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private func saveWorkout() {
        if let memberIdData = KeychainManager.load(service: "YourAppService", account: "userId"),
           let memberIdString = String(data: memberIdData, encoding: .utf8),
           let memberId = Int(memberIdString),
           let authKeyData = KeychainManager.load(service: "YourAppService", account: "authKey"),
           let authKey = String(data: authKeyData, encoding: .utf8) {

        let exerciseIds = selectedExercises.map { $0.id }

        NetworkManager.createWorkout(
            memberId: memberId,
            workoutName: workoutName,
            exerciseIds: exerciseIds,
            authKey: authKey) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        print("Workout successfully saved!")
                        isPresented = false
                    case .failure(let error):
                        print("Failed to save workout: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func addExercise(_ exercise: Exercise) {
        if !selectedExercises.contains(where: { $0.id == exercise.id }) {
            selectedExercises.append(exercise)
        }
    }
    
    private func deleteExercise(at offsets: IndexSet) {
        selectedExercises.remove(atOffsets: offsets)
    }
    
    private func moveExercise(from source: IndexSet, to destination: Int) {
        selectedExercises.move(fromOffsets: source, toOffset: destination)
    }
    
    private func loadExercises() {
        isLoadingMore = true
        NetworkManager.fetchExercises(page: currentPage) { newExercises in
            DispatchQueue.main.async {
                if !newExercises.isEmpty {
                    self.exercises.append(contentsOf: newExercises)
                } else {
                    self.hasMoreExercises = false
                }
                self.isLoadingMore = false
            }
        }
    }

    private func loadMoreExercises() {
        guard hasMoreExercises, !isLoadingMore else { return }
        currentPage += 1
        loadExercises()
    }
    
    private var exercisesList: some View {
        ScrollView {
            VStack(spacing: 15) {
                ForEach(filteredExercises) { exercise in
                    ExerciseCard(exercise: exercise, onAdd: { addExercise(exercise) })
                }
                
                if isLoadingMore {
                    ProgressView()
                }
            }
            .padding(.bottom)
            .onReachBottom(perform: loadMoreExercises)
        }
    }
}

struct OnReachBottomModifier: ViewModifier {
    var action: () -> Void

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geometry in
                Color.clear.preference(key: ViewOffsetKey.self, value: geometry.frame(in: .global).maxY)
            }
        )
        .onPreferenceChange(ViewOffsetKey.self) { maxY in
            DispatchQueue.main.async {
                actionIfNeeded(maxY: maxY)
            }
        }
    }

    private func actionIfNeeded(maxY: CGFloat) {
        guard let rootView = UIApplication.shared.windows.first?.rootViewController?.view else { return }
        let rootViewHeight = rootView.frame.size.height
        let threshold = maxY - rootViewHeight

        if threshold < 50 {
            action()
        }
    }
}

struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

extension View {
    func onReachBottom(perform action: @escaping () -> Void) -> some View {
        self.modifier(OnReachBottomModifier(action: action))
    }
}
