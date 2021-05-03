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
    @Published var id: String
    @Published var name: String
    @Published var description: String
    @Published var category: Category
    @Published var playbackType: PlaybackType
    @Published var owningUser: PublicProfile
    private var _startTime: Date?
    @Published var isExpired = false
    @Published var duration: Measurement<UnitDuration>?
    @Published var image: UIImage?
    @Published var peopleLimit: Int
    @Published var contentLink: String
    fileprivate var previewImageIdentifier: String
    @Published var likes: Int? = 0
    @Published var comment: Bool? = false
    @Published var comments: Comments = Comments(comments: [],page_number: 0)
    @Published var userComments: [Comments.comment] = []
    @Published var canJoinLivestream = false
    
    var _endTime: Date? {
        guard let startTime = _startTime, let duration = duration else { return nil }
        return startTime.advanced(by: duration.converted(to: .seconds).value)
    }
    
    private var _imageLoadingCancellable: AnyCancellable?
    private var _livestreamExpirationCheckCancellable: AnyCancellable?
    private var getCommentCancellable: AnyCancellable?
    private var addCommentCancellable: AnyCancellable?
    var livestreamDeleteOnExpirationCancellable: AnyCancellable?
    private var _joinLivestreamCancellable: AnyCancellable?
    
    
    enum PlaybackType: Int, CaseIterable {
        case live = 1
        case recordedVideo
    }
    
    enum Category: String, CustomStringConvertible, CaseIterable {
        case hiit
        case pushup
        case cycling
        case jogging
        case situp
        case other
      
        
        static func identify(networkCall:String) -> Category{
            for category in Exercise.Category.allCases{
                if category.networkCall == networkCall{
                    return category
                }}
            return .other
        }
        
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
        
        var networkCall: String{
            switch self{
            case .pushup:
                return "PU"
            case .hiit:
                return "HT"
            case .jogging:
                return "JG"
            case .cycling:
                return "CY"
            case .other:
                return "O"
            case .situp:
                return "SU"
            default:
                fatalError("Unhandled category")
            }
        
            
        }
        
        //FIXME: Index to be changed
        var index: Double{
            switch self {
            case .pushup:
                return 8.5
            case .hiit:
                return 6.5
            default:
                return 5
            }
        }
    }
    
    // MARK: - Initializers
    
    init(id: String, name: String, description: String = "", category: Category, playbackType: PlaybackType, owningUser: PublicProfile, duration: Measurement<UnitDuration>?, previewImageIdentifier: String, peoplelimt: Int = 0, contentlink: String = "", startTime: Date?) {
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
        self._imageLoadingCancellable = MediaLoader.shared.image(withIdentifier: previewImageIdentifier)
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
        
        self._startTime = startTime
        checkExpiration()
    }
    
    
  
    /// Creates a sample exercise.
    convenience init(sampleExerciseInCategory category: Category, playbackType: PlaybackType, previewImageID: Int) {
        let owningUser = PublicProfile.exampleProfiles.randomElement()!
        let loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus vehicula lectus vitae quam maximus semper. Duis eget magna id neque sagittis pretium. Morbi sit amet diam et eros cursus mattis a vitae dolor. Etiam in ex at sapien consectetur euismod. Curabitur in fringilla lectus. Duis dictum orci libero, ac semper risus facilisis sit amet. Praesent a tellus nulla."
        
        self.init(id: String(Int.random(in: Int.min...Int.max)),
                  name: "\(category.description) with \(owningUser.identifier)",
                  description: loremIpsum,
                  category: category,
                  playbackType: playbackType,
                  owningUser: owningUser,
                  duration: Measurement(value: Double.random(in: 1...120), unit: UnitDuration.minutes),
                  previewImageIdentifier: "\(category.rawValue)-\(previewImageID)",
                  peoplelimt:5, startTime: nil)
    }
    
    
    // MARK: - Instance methods
    
    func shouldAppearOnSearchText(_ text: String) -> Bool {
        // if the search text is empty, the user may want to see all exercises available
        guard !text.isEmpty else { return true }
        return self.name.lowercased().contains(text.lowercased())
    }
    
    func startLivestreamTimer() {
        _startTime = Date()
        
       checkExpiration()
    }
    
    func checkExpiration() {
        if _startTime == nil { _startTime = Date() }
        if playbackType == .live &&
            Date().timeIntervalSinceReferenceDate > self._endTime?.timeIntervalSinceReferenceDate ?? 9000000000 {
            self.isExpired = true
            return
        }
        // checking locally if the event expired
        if playbackType == .live {
            self._livestreamExpirationCheckCancellable = Timer.publish(every: 1, on: RunLoop.main, in: .default)
                .autoconnect()
                .map { Int($0.timeIntervalSinceReferenceDate) }
                .map { $0 >= Int(self._endTime?.timeIntervalSinceReferenceDate ?? 900000000) }
                .filter { $0 == true && self.isExpired == false }
                .assign(to: \.isExpired, on: self)
        }
    }
    
    func getComment(page:Int){
        self.getCommentCancellable = NetworkQueryController.shared.getComment(videoID: id, page: page) .receive(on: DispatchQueue.main)
            .sink{[unowned self] comments in
                self.comments.comments.append(contentsOf: comments.comments)
                self.comments.page_number=comments.page_number
            }
    }
    
    func addComment(email:String, token:String, content: String){
        self.addCommentCancellable = NetworkQueryController.shared.addComment(email: email, token: token, videoID: id, content: content)
            .receive(on: DispatchQueue.main)
            .sink{ [unowned self] success in
                let formatter = DateFormatter()
                let date=Date()
                formatter.dateFormat="YYYY-MM-dd mm:ss"
                let stringDate = formatter.string(from: date)
                self.comments.comments.insert(Comments.comment(id: UUID().uuidString, email: email, createTime: stringDate, content: content), at: 0)
            }
    }
    
    func getMyComment(email:String){
        self.getCommentCancellable = NetworkQueryController.shared.getUserComment(videoID: id, userEmail: email).receive(on: DispatchQueue.main)
            .sink{[unowned self] comments in
                userComments=comments
            }
    }
    
    func removeComment(email:String, token:String, at: IndexSet){
        let commentId = userComments[at.first!].id
        userComments.remove(atOffsets: at)
        self.getCommentCancellable = NetworkQueryController.shared.removeComment(email: email, token: token, videoID: id, id: commentId)
            .sink{[unowned self] comments in
            }
    }
    
    func joinLivestream(authenticationToken: String, email: String) {
        print("joining livestream... \(email)")
        _joinLivestreamCancellable = NetworkQueryController.shared.joinLivestream(zoomLink: self.contentLink, token: authenticationToken, email: email)
            .assign(to: \.canJoinLivestream, on: self)
    }
    
    func quitLivestream(authenticationToken: String, email: String) {
        print("quiting livestream... \(email)")
        NetworkQueryController.shared.quitLivestream(zoomLink: self.contentLink, token: authenticationToken, email: email)
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
    
    static let exampleExercise = Exercise(id: "example", name: "Example", description: "", category: .cycling, playbackType: .live, owningUser: PublicProfile.exampleProfile, duration: Measurement(value: 5, unit: UnitDuration.minutes), previewImageIdentifier: "cycling-3", peoplelimt: 3, contentlink: "https://google.com", startTime: nil)
}

// MARK: - View Model

extension Exercise {
    var durationDescription: String {
        guard let durationInMinutes = duration?.value else { return "No Time" }
        return "\(Int(durationInMinutes.rounded()))min"
    }
}

// MARK: - Protocol conformance

extension Exercise: Equatable {
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id
    }
    static func < (lhs: Exercise, rhs: Exercise) -> Bool {
        if lhs.playbackType == rhs.playbackType {
            if lhs.playbackType == .recordedVideo {
                return lhs.likes! > rhs.likes!
            } else {
                // do not sort if both are live
                return true
            }
        } else {
            return lhs.playbackType.rawValue < rhs.playbackType.rawValue
        }
    }
}
