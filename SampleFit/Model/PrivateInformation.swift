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
    
    var authenticationToken: String = ""
    var email: String = ""
    
    /// Flat array of exercises that should provide to the user as the browse exercise feeds.
    @PublishedCollection var exerciseFeeds: [Exercise] = []
    @Published var favoriteExercises: [Exercise] = []
    @Published var followedUsers: [PublicProfile] = []
    @Published var workoutHistory: [Workout] = []
    @Published var watchedExercises: [Exercise] = []
    @Published var searchHistory: [String] = []
    
    //MARK: - Asynchronous tasks
    private var networkQueryController = NetworkQueryController()
    private var _exerciseFeedsWillChangeCancellable: AnyCancellable?
    private var _addWorkoutHistoryCancellable: AnyCancellable?
    private var _getWorkoutHistoryCancellable: AnyCancellable?
    private var _getFollowListCancellable: AnyCancellable?
    private var _FollowStatusChangeCancellable: AnyCancellable?
    private var _LikeStatusChangeCancellable: AnyCancellable?
    private var _getlikedVideosCancellable: AnyCancellable?
    private var _addHistoryCancellable: AnyCancellable?
    private var _getWatchedHistoryCancellable: AnyCancellable?
    private var _emptyWatchedHistoryCancellable: AnyCancellable?
    private var _emptyWorkoutHistoryCancellable: AnyCancellable?
    private var getSearchHistoryCancellable: AnyCancellable?
    private var addSearchHistoryCancellable: AnyCancellable?
    private var emptySearchHistoryCancellable: AnyCancellable?
    
    
    
    // MARK: - Initializers
    init() {
        _exerciseFeedsWillChangeCancellable = $exerciseFeeds.debounce(for: 0.5, scheduler: DispatchQueue.main).sink { _ in
            self.objectWillChange.send()
        }
        
    }
    
    
    //used for logout data emptying
    func removeProfile(){
        self.exerciseFeeds.removeAll()
        self.watchedExercises.removeAll()
        self.followedUsers.removeAll()
        self.favoriteExercises.removeAll()
        self.workoutHistory.removeAll()
        self.searchHistory.removeAll()
    }
    
    
    func getSearchHistory(token:String, email:String){
        self.getSearchHistoryCancellable = networkQueryController.getSearchHistory(email: email, token: token)
            .receive(on: DispatchQueue.main)
            .sink{[unowned self] returnedList in
                searchHistory=returnedList
            }
    }
    
    func addSearchHistory(searchText:String){
        
        guard !searchText.isEmpty else {
            return
        }
        
        self.addSearchHistoryCancellable = networkQueryController.addSearchHistory(email: email, searchText: searchText, token: authenticationToken)
            .receive(on: DispatchQueue.main)
            .sink{[unowned self] success in
                searchHistory.insert(searchText, at: 0)
            }
    }
    
    func emptySearchHistory(){
        emptySearchHistoryCancellable = networkQueryController.clearSearchHistory(email: email, token: authenticationToken)
            .receive(on: DispatchQueue.main)
            .sink{ [unowned self] result in
                searchHistory.removeAll()
            }
    }
    
    func emptyWorkoutHistory(){
        _emptyWorkoutHistoryCancellable = networkQueryController.clearWorkoutHistory(token: authenticationToken, email: email)
            .receive(on: DispatchQueue.main)
            .sink{ [unowned self] result in
                workoutHistory.removeAll()
            }
    }
    
    func emptyWatchHistory(){
        _emptyWatchedHistoryCancellable = networkQueryController.clearWatchedHistory(email: email, token: authenticationToken)
            .receive(on: DispatchQueue.main)
            .sink{ [unowned self] result in
                watchedExercises.removeAll()
            }
    }
    
    func addHistory(exercise: Exercise){
        //add newly watched video
        _addHistoryCancellable = networkQueryController.addWatchHistory(email: email , id: exercise.id, token: authenticationToken)
            .receive(on: DispatchQueue.main)
            .sink{[unowned self] result in
                var i=0
                
                while i<watchedExercises.count{
                    if watchedExercises[i].id == exercise.id{
                        watchedExercises.remove(at: i)
                    }
                    i+=1
                }
                watchedExercises.append(exercise)
            }
    }
    
    func getWatchedHistory(){
        _getWatchedHistoryCancellable=networkQueryController.getWatchedHistory(email: email, token: authenticationToken)
            .receive(on: DispatchQueue.main)
            .sink{[unowned self] videos in
                watchedExercises=videos
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
            .sink{[unowned self] returnedList in
                for r in returnedList{
                    let profile = PublicProfile(identifier: r.email, fullName: nil)
                    profile.nickname = r.nickname
                    profile.uploadedExercises = []
                    if r.avatar != nil && !r.avatar!.isEmpty{
                        profile.loadAvatar(url: r.avatar!)
                    }
                    followedUsers.append(profile)
                }
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
    func toggleExerciseInFavorites(_ exercise: Exercise) {
        if self.hasFavorited(exercise) {
            
            _LikeStatusChangeCancellable=networkQueryController.unlikeVideo(email: email, videoId: exercise.id, token: authenticationToken).receive(on: DispatchQueue.main)
                .sink{[unowned self] success in
                    if success{
                        favoriteExercises.removeAll { $0 == exercise }
                    }
                }
        } else {
            
            _LikeStatusChangeCancellable=networkQueryController.likeVideo(email: email, videoId: exercise.id, token: authenticationToken).receive(on: DispatchQueue.main)
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
            return exerciseFeeds.first != nil ? [exerciseFeeds.first!] : [Exercise.exampleExercisesSmall[0]]
        } else {
            return liveExercises
        }
    }
}
