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
    @PublishedCollection var exerciseFeeds: [Exercise] = Exercise.exampleExercisesSmall
    @Published var favoriteExercises: [Exercise] = []
    @Published var followedUsers: [PublicProfile] = []
    @Published var workoutHistory: [Workout] = []
    
    private var _exerciseFeedsWillChangeCancellable: AnyCancellable?
    
    // MARK: - Initializers
    init() {
        _exerciseFeedsWillChangeCancellable = $exerciseFeeds.debounce(for: 0.5, scheduler: DispatchQueue.main).sink { _ in
            self.objectWillChange.send()
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
    func toggleExerciseInFavorites(_ exercise: Exercise) {
        if self.hasFavorited(exercise) {
            favoriteExercises.removeAll { $0 == exercise }
        } else {
            _addExerciseToFavorites(exercise)
        }
    }
    func toggleUserInFollowed(_ user: PublicProfile) {
        if self.hasFollowed(user) {
            followedUsers.removeAll { $0 == user }
        } else {
            _addFollowedUser(user)
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
