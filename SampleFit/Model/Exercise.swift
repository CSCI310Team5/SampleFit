//
//  Exercise.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/17/21.
//

import Foundation
import SwiftUI
import Combine

class Exercise: Identifiable, ObservableObject {
    var objectWillChange = ObservableObjectPublisher()
    
    var id: Int
    var name: String
    var description: String
    var category: Category
    var playbackType: PlaybackType
    var duration: Measurement<UnitDuration>?
    var image: Image?
    fileprivate var previewImageIdentifier: String
    
    enum PlaybackType {
        case live
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
    }
    
    // MARK: - Initializers
    
    init(id: Int, name: String, description: String = "", category: Category, playbackType: PlaybackType, duration: Measurement<UnitDuration>?, previewImageIdentifier: String) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.playbackType = playbackType
        self.duration = duration
        self.previewImageIdentifier = previewImageIdentifier
        ImageLoader.shared.image(withIdentifier: previewImageIdentifier) { (result) in
            switch result {
            case let .success(image):
                DispatchQueue.main.async {
                    self.image = image
                    self.objectWillChange.send()
                }
                
            case let .failure(error):
                print(error)
                DispatchQueue.main.async {
                    self.image = nil
                }
            }
        }
    }
    
    /// Creates a sample exercise.
    convenience init(sampleExerciseInCategory category: Category, playbackType: PlaybackType, previewImageID: Int) {
        let names = ["Abudala Awabel", "Tim Cook", "Mark Redekopp", "Andrew Goodney", "Johnny Appleseed", "Jane Doe", "Carol Folt", "Barack Obama", "Mike Pence", "Donald Trump"]
        let loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus vehicula lectus vitae quam maximus semper. Duis eget magna id neque sagittis pretium. Morbi sit amet diam et eros cursus mattis a vitae dolor. Etiam in ex at sapien consectetur euismod. Curabitur in fringilla lectus. Duis dictum orci libero, ac semper risus facilisis sit amet. Praesent a tellus nulla."
        
        self.init(id: Int.random(in: Int.min...Int.max),
                  name: "\(category.description) with \(names.randomElement()!)",
                  description: loremIpsum,
                  category: category,
                  playbackType: playbackType,
                  duration: playbackType == .recordedVideo ? Measurement(value: Double.random(in: 1...120), unit: UnitDuration.minutes) : nil,
                  previewImageIdentifier: "\(category.rawValue)-\(previewImageID)")
    }
    
    
    // MARK: - Convenience type properties
    // Each exercise has a unique id to prevent SwiftUI from neglecting feeds update containing exercise items with the same id.
    
    
    static let sampleExercisesAllPushup = [
        Exercise(sampleExerciseInCategory: .pushup, playbackType: .recordedVideo, previewImageID: 1),
        Exercise(sampleExerciseInCategory: .pushup, playbackType: .recordedVideo, previewImageID: 2),
        Exercise(sampleExerciseInCategory: .pushup, playbackType: .live, previewImageID: 3),
    ]
    
    static let sampleExercisesSmall = [
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
    
    static let sampleExercisesFull = [
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
        return "\(Int(durationInMinutes.rounded())) mins"
    }
}

extension Exercise: Equatable {
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id
    }
    
}