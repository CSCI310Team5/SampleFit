//
//  Exercise.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/17/21.
//

import Foundation
import SwiftUI
import Combine

/// Represents an exercise (a video or a livestream) that other users can view.
class Exercise: Identifiable, ObservableObject {
    @Published var id: Int
    @Published var name: String
    @Published var description: String
    @Published var category: Category
    @Published var playbackType: PlaybackType
    @Published var owningUser: PublicProfile
    @Published var duration: Measurement<UnitDuration>?
    @Published var image: Image?
    @Published var peopleLimit: Int
    // MARK: we also need something that points to the link to the prerecorded/zoom link
    @Published var contentLink: String
    fileprivate var previewImageIdentifier: String
    private var imageLoadingCancellable: AnyCancellable?
    
    
    
    enum PlaybackType: Int {
        case live = 1
        case recordedVideo
    }
    
    enum Category: String, CustomStringConvertible, CaseIterable {
        case hiit
        case pushup
        case cycling
        case jogging
        case other
        
        var description: String {
            switch self {
            case .pushup:
                return "Push up"
            case .hiit:
                return "HIIT"
            default:
                return self.rawValue.capitalized
            }
        }
        var searchToken: UISearchToken {
            let token = UISearchToken(icon: nil, text: self.description)
            token.representedObject = self
            return token
        }
    }
    
    // MARK: - Initializers
    
    init(id: Int, name: String, description: String = "", category: Category, playbackType: PlaybackType, owningUser: PublicProfile, duration: Measurement<UnitDuration>?, previewImageIdentifier: String, peoplelimt: Int = 0, contentlink: String = "") {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.playbackType = playbackType
        self.owningUser = owningUser
        self.duration = duration
        self.peopleLimit = peoplelimt
        self.contentLink = contentlink
        self.previewImageIdentifier = previewImageIdentifier
        self.imageLoadingCancellable = ImageLoader.shared.image(withIdentifier: previewImageIdentifier)
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
    }
    
    /// Creates a sample exercise.
    convenience init(sampleExerciseInCategory category: Category, playbackType: PlaybackType, previewImageID: Int) {
        let owningUser = PublicProfile.exampleProfiles.randomElement()!
        let loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus vehicula lectus vitae quam maximus semper. Duis eget magna id neque sagittis pretium. Morbi sit amet diam et eros cursus mattis a vitae dolor. Etiam in ex at sapien consectetur euismod. Curabitur in fringilla lectus. Duis dictum orci libero, ac semper risus facilisis sit amet. Praesent a tellus nulla."
        
        self.init(id: Int.random(in: Int.min...Int.max),
                  name: "\(category.description) with \(owningUser.identifier)",
                  description: loremIpsum,
                  category: category,
                  playbackType: playbackType,
                  owningUser: owningUser,
                  duration: Measurement(value: Double.random(in: 1...120), unit: UnitDuration.minutes),
                  previewImageIdentifier: "\(category.rawValue)-\(previewImageID)",
                  peoplelimt:5)
    }
    
    // MARK: - Instance methods
    
    func shouldAppearOnSearchText(_ text: String) -> Bool {
        // if the search text is empty, the user may want to see all exercises available
        guard !text.isEmpty else { return true }
        return self.name.lowercased().contains(text.lowercased())
    }
    
    
    // MARK: - Convenience type properties
    // Each exercise has a unique id to prevent SwiftUI from neglecting feeds update containing exercise items with the same id.
    
    
    static let exampleExercisesAllPushup = [
        Exercise(sampleExerciseInCategory: .pushup, playbackType: .recordedVideo, previewImageID: 1),
        Exercise(sampleExerciseInCategory: .pushup, playbackType: .recordedVideo, previewImageID: 2),
        Exercise(sampleExerciseInCategory: .pushup, playbackType: .live, previewImageID: 3),
    ]
    
    static let exampleExercisesSmall = [
        Exercise(sampleExerciseInCategory: .hiit, playbackType: .recordedVideo, previewImageID: 1),
        Exercise(sampleExerciseInCategory: .hiit, playbackType: .recordedVideo, previewImageID: 2),
        
        Exercise(sampleExerciseInCategory: .pushup, playbackType: .live, previewImageID: 3),
        
        Exercise(sampleExerciseInCategory: .cycling, playbackType: .recordedVideo, previewImageID: 1),
        
        Exercise(sampleExerciseInCategory: .jogging, playbackType: .live, previewImageID: 1),
        Exercise(sampleExerciseInCategory: .jogging, playbackType: .recordedVideo, previewImageID: 2),
        Exercise(sampleExerciseInCategory: .jogging, playbackType: .live, previewImageID: 3),

        Exercise(sampleExerciseInCategory: .other, playbackType: .recordedVideo, previewImageID: 2),
        Exercise(sampleExerciseInCategory: .other, playbackType: .recordedVideo, previewImageID: 3),
    ]
    
    static let exampleExercisesFull = [
        Exercise(sampleExerciseInCategory: .hiit, playbackType: .recordedVideo, previewImageID: 1),
        Exercise(sampleExerciseInCategory: .hiit, playbackType: .recordedVideo, previewImageID: 2),
        Exercise(sampleExerciseInCategory: .hiit, playbackType: .live, previewImageID: 3),
        
        Exercise(sampleExerciseInCategory: .pushup, playbackType: .recordedVideo, previewImageID: 1),
        Exercise(sampleExerciseInCategory: .pushup, playbackType: .recordedVideo, previewImageID: 2),
        Exercise(sampleExerciseInCategory: .pushup, playbackType: .live, previewImageID: 3),
        
        Exercise(sampleExerciseInCategory: .cycling, playbackType: .recordedVideo, previewImageID: 1),
        Exercise(sampleExerciseInCategory: .cycling, playbackType: .recordedVideo, previewImageID: 2),
        Exercise(sampleExerciseInCategory: .cycling, playbackType: .live, previewImageID: 3),
        
        Exercise(sampleExerciseInCategory: .jogging, playbackType: .live, previewImageID: 1),
        Exercise(sampleExerciseInCategory: .jogging, playbackType: .recordedVideo, previewImageID: 2),
        Exercise(sampleExerciseInCategory: .jogging, playbackType: .live, previewImageID: 3),

        Exercise(sampleExerciseInCategory: .other, playbackType: .live, previewImageID: 1),
        Exercise(sampleExerciseInCategory: .other, playbackType: .recordedVideo, previewImageID: 2),
        Exercise(sampleExerciseInCategory: .other, playbackType: .recordedVideo, previewImageID: 3),
        
        Exercise(sampleExerciseInCategory: .other, playbackType: .recordedVideo, previewImageID: 4),
    ]
}

// MARK: - View Model

extension Exercise {
    var durationDescription: String {
        guard let durationInMinutes = duration?.value else { return "LIVE" }
        return "\(Int(durationInMinutes.rounded()))min"
    }
}

// MARK: - Protocol conformance

extension Exercise: Equatable {
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id
    }
    static func < (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.playbackType.rawValue < rhs.playbackType.rawValue
    }
}
