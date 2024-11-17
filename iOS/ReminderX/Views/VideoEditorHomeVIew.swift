import SwiftUI
import UIKit

struct WorkoutView: View {
    @State private var showActionSheet = false
    @State private var gradientRotation: Double = 0
    @State private var showingWorkoutBuilder = false
    @State private var workouts: [Workout] = []
    @State private var selectedWorkout: Workout? {
        didSet {
            if let selectedWorkout = selectedWorkout {
                fetchExercises(for: selectedWorkout)
            }
        }
    }
    @State private var exercises: [Exercise] = []
    @State private var isLoading: Bool = false
    @State private var showDeletionErrorAlert: Bool = false

    let gradientColors = [ColorSchemeManager.shared.currentColorScheme.light, ColorSchemeManager.shared.currentColorScheme.dark]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(
                    AngularGradient(
                        gradient: Gradient(colors: gradientColors),
                        center: .center,
                        startAngle: .degrees(gradientRotation),
                        endAngle: .degrees(gradientRotation + 360)
                    )
                )
                .blur(radius: 70)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                if let selectedWorkout = selectedWorkout {
                    WorkoutPlanCardView(workout: selectedWorkout, exercises: exercises)
                }
                workoutListSection
            }
            .padding(.horizontal)
            .padding(.bottom, 76)
            if isLoading {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                ProgressView("Deleting...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding()
                    .background(Color.gray.opacity(0.8))
                    .cornerRadius(10)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .sheet(isPresented: $showingWorkoutBuilder) {
            WorkoutBuilderView(isPresented: self.$showingWorkoutBuilder)
        }
        .alert(isPresented: $showDeletionErrorAlert) {
            Alert(
                title: Text("Deletion Failed"),
                message: Text("Unable to delete the workout. Please try again."),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            fetchWorkouts()
            withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: false)) {
                gradientRotation = 360
            }
        }
    }

    private var workoutListSection: some View {
        VStack {
            header
            workoutCards
        }
        .background(RoundedRectangle(cornerRadius: 30).fill(Color.white))
        .shadow(color: .gray.opacity(0.2), radius: 10, x: 5, y: 5)
    }

    private var header: some View {
        HStack {
            Text("Workouts")
                .font(.title)
                .bold()
                .foregroundColor(.black.opacity(0.9))
            
            Spacer()
            Button(action: {
                self.showingWorkoutBuilder = true
            }) {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .padding(13)
                    .foregroundColor(ColorSchemeManager.shared.currentColorScheme.med.opacity(0.4))
                    .background(Color.white)
                    .cornerRadius(15)
            }
            Button(action: {
            }) {
                HStack {
                    Image(systemName: "sparkle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                    Text("Generate")
                        .frame(alignment: .center)
                        .bold()
                }
                .padding(13)
                .foregroundColor(Color.white)
                .background(ColorSchemeManager.shared.currentColorScheme.med.opacity(0.5))
                .cornerRadius(15)
            }
        }
        .padding([.top, .horizontal])
    }

    private var workoutCards: some View {
        ScrollView {
            VStack {
                ForEach(workouts, id: \.workoutId) { workout in
                    WorkoutCardView(workout: workout, onDelete: { workoutToDelete in
                        deleteWorkout(workoutToDelete)
                    })
                    .onTapGesture {
                        self.selectedWorkout = workout
                    }
                }
            }
        }
    }

    private func fetchWorkouts() {
        guard let memberIdData = KeychainManager.load(service: "YourAppService", account: "userId"),
              let memberIdString = String(data: memberIdData, encoding: .utf8),
              let memberId = Int(memberIdString),
              let authKeyData = KeychainManager.load(service: "YourAppService", account: "authKey"),
              let authKey = String(data: authKeyData, encoding: .utf8) else {
            print("Unable to retrieve member ID and/or auth key from Keychain")
            return
        }

        NetworkManager.fetchWorkoutsForMember(memberId: memberId, authKey: authKey) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedWorkouts):
                    self.workouts = fetchedWorkouts
                    if self.selectedWorkout == nil, let firstWorkout = fetchedWorkouts.first {
                        self.selectedWorkout = firstWorkout
                    }
                case .failure(let error):
                    print("Error fetching workouts: \(error)")
                }
            }
        }
    }

    private func fetchExercises(for workout: Workout) {
        guard let memberIdData = KeychainManager.load(service: "YourAppService", account: "userId"),
              let memberIdString = String(data: memberIdData, encoding: .utf8),
              let memberId = Int(memberIdString),
              let authKeyData = KeychainManager.load(service: "YourAppService", account: "authKey"),
              let authKey = String(data: authKeyData, encoding: .utf8) else {
            print("Unable to retrieve member ID and/or auth key from Keychain")
            return
        }

        NetworkManager.fetchExercisesForWorkout(workoutId: workout.workoutId, authKey: authKey) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let loadedExercises):
                    self.exercises = loadedExercises
                case .failure(let error):
                    print("Error fetching exercises: \(error)")
                }
            }
        }
    }

    private func deleteWorkout(_ workout: Workout) {
        guard let authKeyData = KeychainManager.load(service: "YourAppService", account: "authKey"),
              let authKey = String(data: authKeyData, encoding: .utf8) else {
            print("Unable to retrieve auth key from Keychain")
            return
        }

        isLoading = true

        NetworkManager.deleteWorkout(workoutId: workout.workoutId, authKey: authKey) { success in
            DispatchQueue.main.async {
                isLoading = false
                if success {
                    if let index = workouts.firstIndex(where: { $0.workoutId == workout.workoutId }) {
                        workouts.remove(at: index)
                        if selectedWorkout?.workoutId == workout.workoutId {
                            selectedWorkout = workouts.first
                        }
                    }
                } else {
                    showDeletionErrorAlert = true
                }
            }
        }
    }
}

struct WorkoutCardView: View {
    var workout: Workout
    @State private var showDeleteConfirmation = false
    var onDelete: (Workout) -> Void

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(workout.workoutName)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("(\(workout.exerciseIds.count)) exercises")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding([.top, .bottom, .leading])

                Spacer()

                Menu {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    Button {
                        renameWorkout()
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .imageScale(.large)
                        .foregroundColor(.black)
                        .padding(10)
                }
                .contentShape(Rectangle())
                .padding([.top, .trailing])
            }
            .background(Color.gray.opacity(0.05))
            .cornerRadius(20)
        }
        .shadow(color: Color.black.opacity(0.03), radius: 1, x: 2, y: 3)
        .padding(.horizontal)
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Workout"),
                message: Text("Are you sure you want to delete this workout? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    onDelete(workout)
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func renameWorkout() {
    }
}


struct WorkoutPlanCardView: View {
    let workout: Workout
    let exercises: [Exercise]
    @State private var isShowingDetail = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(workout.workoutName)
                        .font(.title)
                        .fontWeight(.bold)
                }
                Spacer()
                VStack {
                    Text("\(exercises.count) Exercises")
                        .fontWeight(.semibold)
                }
            }
            .padding(.top)
            .padding(.horizontal)
            
            HStack {
                WorkoutPreviewScrollView(exercises: exercises)
                
                Button(action: {
                    isShowingDetail = true
                }) {
                    Label("Start", systemImage: "play.circle.fill")
                        .font(.subheadline)
                        .padding()
                        .foregroundColor(.black)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                }
                .padding()
                .fullScreenCover(isPresented: $isShowingDetail) {
                    WorkoutDetailView(workout: workout, exercises: exercises)
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 30).fill(Color.white))
        .shadow(color: .gray.opacity(0.2), radius: 10, x: 5, y: 5)
    }
}

struct WorkoutPreviewScrollView: View {
    let exercises: [Exercise]
    @State private var currentIndex: Int = 0
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    let gradientColors = [ColorSchemeManager.shared.currentColorScheme.med, ColorSchemeManager.shared.currentColorScheme.light]

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(exercises.indices, id: \.self) { index in
                VStack(alignment: .leading, spacing: 10) {
                    Text(exercises[index].title)
                        .font(.headline)
                        .fontWeight(.medium)
                    HStack(spacing: 10) {
                        GradientTag(text:"\(exercises[index].equipment)", gradientColors: gradientColors)
                        GradientTag(text:"\(exercises[index].difficulty)", gradientColors: gradientColors)
                    }
                }
                .padding()
                .tag(index)
            }
        }
        .frame(height: 110)
        .tabViewStyle(PageTabViewStyle())
        .onReceive(timer) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % exercises.count
            }
        }
    }
}

struct GradientTag: View {
    let text: String
    let gradientColors: [Color]

    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(gradientColors[0])
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(.white)
            )
            .overlay(
                Capsule()
                    .stroke(gradientColors[0], lineWidth: 1)
            )
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView()
    }
}
