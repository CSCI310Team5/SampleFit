//
//  SocialInformation.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/17/21.
//

import Foundation
import Combine

class SocialInformation: ObservableObject {
    var objectWillChange = ObservableObjectPublisher()
    
    /// Flat array of exercises that should provide to the user as the browse exercise feeds.
    @PublishedCollection var exerciseFeeds: [Exercise] = Exercise.sampleExercisesSmall
    private var exerciseFeedsWillChangeCancellable: AnyCancellable?
    
    init() {
        exerciseFeedsWillChangeCancellable = $exerciseFeeds.debounce(for: 0.5, scheduler: DispatchQueue.main).sink { _ in
            self.objectWillChange.send()
        }
    }
}

// MARK: - View Model

extension SocialInformation {
    /// Exercise feed structured by category.
    var exerciseInCategory: [Exercise.Category: [Exercise]] {
        get {
            Dictionary(grouping: exerciseFeeds, by: { $0.category })
        }
    }
    
    /// Exercises that are displayed more prominently than others.
    var featuredExercises: [Exercise] {
        let liveExercises = Array(exerciseFeeds.filter { $0.playbackType == .live }.prefix(3))
        if liveExercises.isEmpty {
            return [exerciseFeeds.first!]
        } else {
            return liveExercises
        }
    }
}
