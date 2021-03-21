//
//  PrivateInformation.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/17/21.
//

import Foundation
import Combine

/// User's information that is not public to other users.
class PrivateInformation: ObservableObject {
    
    /// Flat array of exercises that should provide to the user as the browse exercise feeds.
    @PublishedCollection var exerciseFeeds: [Exercise] = []
    @Published var favoriteExercises: [Exercise] = []
    @Published var followedUsers: [PublicProfile] = []
    @Published var workoutHistory: [Workout] = []
    
    //MARK: - Asynchronous tasks
    private var networkQueryController = NetworkQueryController()
    private var _exerciseFeedsWillChangeCancellable: AnyCancellable?
    private var _addWorkoutHistoryCancellable: AnyCancellable?
    private var _getWorkoutHistoryCancellable: AnyCancellable?
    private var _getFollowListCancellable: AnyCancellable?
    private var _FollowStatusChangeCancellable: AnyCancellable?
    private var _LikeStatusChangeCancellable: AnyCancellable?
    private var _getlikedVideosCancellable: AnyCancellable?
    
    // MARK: - Initializers
    init() {
        _exerciseFeedsWillChangeCancellable = $exerciseFeeds.debounce(for: 0.5, scheduler: DispatchQueue.main).sink { _ in
            self.objectWillChange.send()
        }
        
    }
    
    func getFavoriteExercises(email: String, token: String){
        _getlikedVideosCancellable=networkQueryController.getLikedVideos(email: email, token: token)
            .receive(on: DispatchQueue.main)
            .sink{[unowned self] videos in
                favoriteExercises=videos
            }
    }

    func getFollowList(token: String, email: String){
        _getFollowListCancellable=networkQueryController.getFollowList(email:email , token: token)
            .receive(on: DispatchQueue.main)
            .sink{[unowned self] workouts in
                followedUsers=workouts
            }
    }
    
    func storeWorkoutHistory(token: String, email: String){
        workoutHistory=[]
        _getWorkoutHistoryCancellable = networkQueryController.getWorkoutHistory(token: token, email: email)
            .receive(on: DispatchQueue.main)
            .sink{[unowned self] workouts in
                for workout in workouts{
                    var newHistory = Workout(caloriesBurned: Double(workout.calories)!, date: Date(), categories: "", duration: Int(workout.duration)!)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    let date = formatter.date(from: workout.completionTime)
                    newHistory.date = date!
                    
                    for category in Exercise.Category.allCases{
                        if category.networkCall==workout.category{
                            newHistory.categories=category.description
                        }
                    }
                    
                    workoutHistory.append(newHistory)
                }
            }}
    
    func addWorkoutHistory(workout: Workout, token: String, email: String){
        _addWorkoutHistoryCancellable=networkQueryController.addWorkoutHistory(workout: workout, token: token, email: email)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self]  token in
                workoutHistory.append(workout)
            }
    }
    
    // MARK: - Instance methods
    
    func hasFavorited(_ exercise: Exercise) -> Bool {
        return favoriteExercises.contains(exercise)
    }
    func hasFollowed(_ user: PublicProfile) -> Bool {
        return followedUsers.contains(user)
    }
    /// Remove exercises from favorites at specified index set. You should use this method to handle list onDelete events.
    func removeExerciseFromFavorites(at indices: IndexSet) {
        favoriteExercises.remove(atOffsets: indices)
    }
   
    /// Remove users from followed list at specified index set. You should use this method to handle list onDelete events.
    func removeFollowedUser(at indicies: IndexSet) {
        followedUsers.remove(atOffsets: indicies)
    }
    func toggleExerciseInFavorites(_ exercise: Exercise, email: String, token: String) {
        if self.hasFavorited(exercise) {
            
            _LikeStatusChangeCancellable=networkQueryController.unlikeVideo(email: email, videoId: exercise.id, token: token).receive(on: DispatchQueue.main)
                .sink{[unowned self] success in
                    if success{
                        favoriteExercises.removeAll { $0 == exercise }
                    }
                }
        } else {
            
            _LikeStatusChangeCancellable=networkQueryController.likeVideo(email: email, videoId: exercise.id, token: token).receive(on: DispatchQueue.main)
                .sink{[unowned self] success in
                    if success{
                        _addExerciseToFavorites(exercise)
                    }
                }
        }
    }
    
    func toggleUserInFollowed(_ user: PublicProfile, token:String, email: String) {
        if self.hasFollowed(user) {
            _FollowStatusChangeCancellable=networkQueryController.unfollow(email: email , unfollowUser: user.identifier, token: token).receive(on: DispatchQueue.main).sink{[unowned self] result in
                followedUsers.removeAll { $0 == user }
            }
        } else {
            _FollowStatusChangeCancellable=networkQueryController.follow(email: email , followUser: user.identifier, token: token).receive(on: DispatchQueue.main).sink{[unowned self] result in
                _addFollowedUser(user)}
        }
    }
    
    private func _addFollowedUser(_ user: PublicProfile) {
        followedUsers.append(user)
        followedUsers.sort()
    }
    private func _addExerciseToFavorites(_ exercise: Exercise) {
        guard !favoriteExercises.contains(exercise) else { return }
        favoriteExercises.append(exercise)
    }
    
    
    // MARK: - Convenience type properties
    static var examplePrivateInformation: PrivateInformation = {
        let information = PrivateInformation()
//        information.followedUsers = PublicProfile.exampleProfiles.sorted()
//        information.favoriteExercises = Exercise.exampleExercisesSmall
        information.workoutHistory = Workout.exampleWorkouts
        return information
    }()
}

// MARK: - View Model

extension PrivateInformation {
    /// Exercise feed structured by category.
    var exerciseInCategory: [Exercise.Category: [Exercise]] {
        get {
            Dictionary(grouping: exerciseFeeds.sorted(by: <), by: { $0.category })
        }
    }
    
    /// Exercises that are display prominantly in `BrowseView`.
    var featuredExercises: [Exercise] {
        let liveExercises = Array(exerciseFeeds.filter { $0.playbackType == .live }.prefix(3))
        if liveExercises.isEmpty {
            return [exerciseFeeds.first!]
        } else {
            return liveExercises
        }
    }
}
