classDiagram
    class ReminderXApp {
        +ContentView contentView
    }

    class ContentView {
        +isAuthenticated: Bool
        +userInfo: UserInfo?
        +userMetrics: [MemberMetric]
        +body(): some View
        +fetchUserDataIfNeeded(): Void
        +fetchUserMetricsIfNeeded(): Void
    }

    class HomeView {
        +ColorSchemeManager colorSchemeManager
        +String greetingText
        +TripleHeightCardView tripleHeightCardView
        +InfoCardView infoCardView
        +NetworkManager networkManager
        +Color color
        +loadData()
        +showLoadingIndicator()
        +hideLoadingIndicator()
        +animateLoadingIndicator()
    }
    class LoginView {
        -String email
        -String password
        -String errorMessage
        +Bool isAuthenticated
        +body() View
        +loginUser()
        +handleSuccessfulLogin(data: Data?)
    }
    class SettingsView {
        -UserInfo userInfo
        -List~MemberMetric~ userMetrics
        -String heightFeet
        -String heightInches
        -String weight
        -WeightUnit weightUnit
        +body() View
        +personalInformationSettings() List~SettingItem<AnyView>~
        +healthMetricsSettings() List~SettingItem<AnyView>~
        +workoutPreferencesSettings() List~SettingItem<AnyView>~
        +nutritionSettings() List~SettingItem<AnyView>~
        +appSettings() List~SettingItem<AnyView>~
        +settingsSection(title: String, settings: List~SettingItem<AnyView>~) View
        +changeName()
        +changeUsername()
        +logOut()
        +settingItemView(iconName: String, title: String) View
    }
    class AiView {
        +@State userMessage: String
        +@State messages: [ChatMessage]
        +@State isWaitingForResponse: Bool
        +@State showMiniCards: Bool
        +@State keyboardHeight: CGFloat
        +@State navbarVisible: Bool
        +@State isTyping: Bool
        +@State typingMessage: String
        +@State aiTypingMessage: String
        +@State lastSentMessageDate: Date
        +@State typingMessages: [(UUID, String)]
        +@State gradientRotation: Double
        +let columns: [GridItem]
        +let gradientColors: [Color]
        +let api: ChatGPTAPI
    }
    class ChatMessage {
        +id: UUID
        +text: String
        +isUser: Bool
    }
    class WorkoutBuilder {
        +Binding<Bool> isPresented
        +[Exercise] exercises
        +[Exercise] selectedExercises
        +String workoutName
        +String searchText
        +Bool isLoading
        +Bool isEditingWorkoutName
        +Int currentPage
        +Bool isLoadingMore
        +Bool hasMoreExercises
        +View body()
        +View exercisesHeader()
        +View exercisesList()
        +saveWorkout()
        +addExercise(Exercise exercise)
        +deleteExercise(IndexSet offsets)
        +moveExercise(IndexSet source, Int destination)
        +loadExercises()
        +loadMoreExercises()
        +onAppear() 
    }

    class Exercise {
        +UUID id
        +String title
    }

    ReminderXApp --> ContentView
    ContentView --> HomeView
    ContentView --> LoginView
    ContentView --> SettingsView
    ContentView --> AiView
    ContentView --> WorkoutBuilder
    WorkoutBuilder --> Exercise
    AiView --> ChatMessage

    class ColorSchemeManager {
        +shared: ColorSchemeManager
        +transitionDuration: Double
        +currentColorScheme: (dark: Color, med: Color, light: Color)
        +updateColorScheme(to newColorScheme: ColorSchemeOption): Void
    }

    class KeychainManager {
        +save(_ data: Data, service: String, account: String) : OSStatus
        +load(service: String, account: String) : Data?
        +delete(service: String, account: String) : OSStatus
        +loadAuthKey() : String?
    }

    class NetworkManager {
        +createWorkout(memberId: Int, workoutName: String, exerciseIds: [Int], authKey: String, completion: @escaping (Result<Void, Error>) -> Void)
        +fetchDetailedWorkoutData(workoutId: Int, authKey: String, completion: @escaping (Result<DetailedWorkout, Error>) -> Void)
        +fetchWorkoutsForMember(memberId: Int, authKey: String, completion: @escaping (Result<[Workout], Error>) -> Void)
        +fetchMemberMetrics(memberId: Int, authKey: String, completion: @escaping (Result<[MemberMetric], Error>) -> Void)
        +fetchUserDataAndMetrics(memberId: Int, authKey: String, completion: @escaping (UserInfo?) -> Void)
        +signUpUser(with data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void)
        +fetchExercises(page: Int, completion: @escaping ([Exercise]) -> Void)
    }
    class Extensions {
        +func towAWDAWDAWDAWDHex() String?
        +init?(hex: String)
    }
    class VisualComponents {
        +VisualEffectBlur
        +NeumorphicGraphCardView
        +WorkoutDetailsView
        +WeightEntryView
        +HeightEntryView
        +WorkoutPlanCardView
        +WorkoutPreviewCardView
        +ExerciseCardView
        +WorkoutCardView
        +WorkoutPreviewScrollView
        +ExerciseCard
        +CompressedExerciseCard
        +CustomTabBar
    }

    class Models {
        +NetworkError
        +MemberMetric
        +DetailedWorkout
        +ExerciseDetails
        +Achievement
        +UserInfo
        +Workout
        +Exercise
        +WeightUnit
        +SignupResponse
        +LoginResponse
        +AppViewModel
        +TagView
        +CodableColor
        +Reminder
    }

    class Graph {
        +exampleGraphData
        +GraphData
        +LabelView
        +CustomGraphCardView
        +GraphLine
        +LineGraph
        +GraphPoints
    }

    class Server {
        - package.json
        - package-lock.json
        - sql/
        - repbook.js
        - API Endpoints
        
        + initializeServer(): void
        + connectDatabase(): void
        + startServer(): void
        + shutdownServer(): void
        
        + POST /api/members
        + GET /api/members
        + POST /api/fitness_achievements
        + GET /api/fitness_achievements
        + POST /api/members_metrics
        + GET /api/members_metrics
        + POST /api/exercises
        + GET /api/exercises
        + POST /api/gym_memberships
        + GET /api/gym_memberships
        + POST /api/user_workout_plans
        + GET /api/user_workout_plans
        + POST /api/pr_tracker
        + GET /api/pr_tracker
        + POST /api/admin
        + GET /api/admin
    }

    class Database {
        + PostgreSQL
        + Tables
        + ER Diagram
        
        + connect(): void
        + executeQuery(query: String): ResultSet
        + closeConnection(): void

        + members
        + fitness_achievements
        + members_metrics
        + exercises
        + gym_memberships
        + user_workout_plans
        + pr_tracker
        + admin
        + workouts
    }

    class members {
        + id: UUID
        + name: String
        + email: String
        + password_hash: String
        + created_at: Date
        + updated_at: Date
    }
    
    class fitness_achievements {
        + id: UUID
        + member_id: UUID
        + achievement_type: String
        + description: String
        + date: Date
    }

    class members_metrics {
        + id: UUID
        + member_id: UUID
        + metric_type: String
        + value: Float
        + recorded_at: Date
    }

    class exercises {
        + id: UUID
        + name: String
        + category: String
        + description: String
    }

    class gym_memberships {
        + id: UUID
        + member_id: UUID
        + gym_name: String
        + start_date: Date
        + end_date: Date
    }

    class user_workout_plans {
        + id: UUID
        + member_id: UUID
        + workout_name: String
        + created_at: Date
    }

    class pr_tracker {
        + id: UUID
        + member_id: UUID
        + exercise_id: UUID
        + pr_value: Float
        + date: Date
    }

    class admin {
        + id: UUID
        + username: String
        + password_hash: String
        + role: String
    }

    class workouts {
        + id: UUID
        + workout_plan_id: UUID
        + exercise_id: UUID
        + reps: Integer
        + sets: Integer
        + weight: Float
    }



    Database --> members
    Database --> fitness_achievements
    Database --> members_metrics
    Database --> exercises
    Database --> gym_memberships
    Database --> user_workout_plans
    Database --> pr_tracker
    Database --> admin
    Database --> workouts

    members "1" --> "*" fitness_achievements : "member_id"
    members "1" --> "*" members_metrics : "member_id"
    members "1" --> "*" gym_memberships : "member_id"
    members "1" --> "*" user_workout_plans : "member_id"
    members "1" --> "*" pr_tracker : "member_id"
    pr_tracker "*" --> "1" exercises : "exercise_id"
    user_workout_plans "1" --> "*" workouts : "workout_plan_id"
    workouts "*" --> "1" exercises : "exercise_id"


    class members
    class fitness_achievements
    class members_metrics
    class exercises
    class gym_memberships
    class user_workout_plans
    class pr_tracker
    class admin

    ReminderXApp --> ColorSchemeManager
    ReminderXApp --> KeychainManager
    ReminderXApp --> NetworkManager
    NetworkManager --> Server : API Calls
    Server --> Database : Queries
    Database --> members
    Database --> fitness_achievements
    Database --> members_metrics
    Database --> exercises
    Database --> gym_memberships
    Database --> user_workout_plans
    Database --> pr_tracker
    Database --> admin

    ColorSchemeManager ..> Extensions
    KeychainManager ..> Extensions
    NetworkManager ..> Models
    NetworkManager ..> Extensions
    HomeView ..> VisualComponents
    HomeView ..> Graph
