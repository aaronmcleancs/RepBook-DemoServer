import SwiftUI
import UIKit

struct WorkoutView: View {
    @State private var showActionSheet = false
    @State private var gradientRotation: Double = 0
    @State private var showingWorkoutBuilder = false
    let gradientColors = [ColorSchemeManager.shared.currentColorScheme.med, ColorSchemeManager.shared.currentColorScheme.light]
    @State private var workouts: [Workout] = []

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
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white)
                    .overlay(
                        VStack {
                            header
                            workoutCards
                        }
                    )
                    .shadow(color: .gray.opacity(0.2), radius: 10, x: 5, y: 5)
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white)
                    .frame(height: 200)
                    .overlay(
                        WorkoutPlanCardView()
                            .padding()
                    )
            }
            .padding(.horizontal)
            .padding(.bottom, 76)
        }
        .navigationBarTitle("", displayMode: .inline)
                .sheet(isPresented: $showingWorkoutBuilder) {
                    WorkoutBuilderView(isPresented: self.$showingWorkoutBuilder)
                }
        .onAppear {
            fetchWorkouts()
            withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: false)) {
                gradientRotation = 360
            }
        }
    }
    
    private var workoutCards: some View {
        ScrollView {
            VStack {
                ForEach(workouts, id: \.workoutId) { workout in
                    WorkoutCardView(workout: workout)
                }
            }
        }
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
    private func fetchWorkouts() {
        if let memberIdData = KeychainManager.load(service: "YourAppService", account: "userId"),
           let memberIdString = String(data: memberIdData, encoding: .utf8),
           let memberId = Int(memberIdString),
           let authKeyData = KeychainManager.load(service: "YourAppService", account: "authKey"),
           let authKey = String(data: authKeyData, encoding: .utf8) {

            print("Fetching workouts for memberId: \(memberId)")
            NetworkManager.fetchWorkoutsForMember(memberId: memberId, authKey: authKey) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchedWorkouts):
                        print("Successfully fetched workouts: \(fetchedWorkouts)")
                        self.workouts = fetchedWorkouts
                    case .failure(let error):
                        print("Error fetching workouts: \(error)")
                    }
                }
            }
        } else {
            print("Unable to retrieve member ID and/or auth key from Keychain")
        }
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView()
    }
}
