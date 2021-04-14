//
//  PublicProfile.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/18/21.
//

import Foundation
import Combine
import SwiftUI

/// User's information that is publicly available to other users. You should use PublicProfile to uniquely identify a user's information.
class PublicProfile: Identifiable, ObservableObject {
    var authenticationToken: String = ""
    @Published var identifier: String = ""
    private var _nickname: String?
    /// user's profile image. Defaults to person.fill.
    @Published var image : UIImage? = UIImage(systemName: "person.fill.questionmark")
    private var _birthday: Date?
    private var _height: Measurement<UnitLength>?
    private var _mass: Measurement<UnitMass>?
    
    private var imageLoadingCancellable: AnyCancellable?
    
    @Published var uploadedExercises: [Exercise] = []
    @Published var isUploadedVideoListLoading = false
    
    private var _usesMetricSystem: Bool
    
    var birthdayDateRange: ClosedRange<Date>
    var heightRange: [Measurement<UnitLength>]
    var massRange: [Measurement<UnitMass>]
    
    static private let _dropFractionsNumberFormatter: NumberFormatter = {
        let dropFractionsNumberFormatter = NumberFormatter()
        dropFractionsNumberFormatter.maximumFractionDigits = 0
        return dropFractionsNumberFormatter
    }()
    static var birthdayFormatter: DateFormatter = {
        let birthdayFormatter = DateFormatter()
        birthdayFormatter.timeStyle = .none
        birthdayFormatter.dateStyle = .medium
        return birthdayFormatter
    }()
    static var heightFormatter: LengthFormatter = {
        let heightFormatter = LengthFormatter()
        heightFormatter.isForPersonHeightUse = true
        heightFormatter.unitStyle = .short
        heightFormatter.numberFormatter = _dropFractionsNumberFormatter
        return heightFormatter
    }()
    static var massFormatter: MassFormatter = {
        let massFormatter = MassFormatter()
        massFormatter.isForPersonMassUse = true
        massFormatter.numberFormatter = _dropFractionsNumberFormatter
        return massFormatter
    }()
    
    init(identifier: String, fullName: PersonNameComponents?) {
        self.identifier = identifier
        
        if let fullName = fullName {
            let nameFormatter = PersonNameComponentsFormatter()
            _nickname = nameFormatter.string(from: fullName)
        }
        
        // initialzing ranges
        let calendar = Calendar.autoupdatingCurrent
        let startComponents = DateComponents(year: 1900)
        let endComponents = calendar.dateComponents(in: calendar.timeZone, from: Date())
        self.birthdayDateRange = calendar.date(from: startComponents)! ... calendar.date(from: endComponents)!
        
        _usesMetricSystem = Locale.autoupdatingCurrent.usesMetricSystem
        if _usesMetricSystem {
            // height ranges from 50cm to 200cm
            heightRange = Array(stride(from: 50, through: 200, by: 1)).map { Measurement(value: $0, unit: UnitLength.centimeters) }
            // mass ranges from 20kg to 300kg
            massRange = Array(stride(from: 20, to: 300, by: 1)).map { Measurement(value: $0, unit: UnitMass.kilograms) }
        } else {
            // height ranges from 10in to 80in
            heightRange = Array(stride(from: 10, through: 80, by: 1)).map { Measurement(value: $0, unit: UnitLength.inches) }
            // mass ranges from 50lb to 650lb
            massRange = Array(stride(from: 50, to: 650, by: 1)).map { Measurement(value: $0, unit: UnitMass.pounds) }
        }
        
        // check each minute for deleting expired livestreams that I created
        self._livestreamDeletionCancellable = $uploadedExercises
            .sink { _ in
                for exercise in self.uploadedExercises {
                    exercise.livestreamDeleteOnExpirationCancellable = Timer.publish(every: 1, on: RunLoop.main, in: .default)
                        .autoconnect()
                        .map { Int($0.timeIntervalSinceReferenceDate) / 60 }
                        .map { $0 == Int(exercise._endTime?.timeIntervalSinceReferenceDate ?? 0) }
                        .filter { $0 }
                        .sink { _ in
                            exercise.livestreamDeleteOnExpirationCancellable = NetworkQueryController.shared.deleteLivestream(zoomLink: exercise.contentLink, token: self.authenticationToken).sink { returnValue in
                                print("Delete livestream ok?: \(returnValue)")
                            }
                        }
                }
            }
    }
    
    func setProfile(weight: Double?, height: Double?, nickname: String?, birthday: Date?){
        
        if weight != nil {self.massBinding=Measurement(value: weight!, unit: UnitMass.kilograms)}
        if height != nil {self.heightBinding=Measurement(value: height!, unit: UnitLength.centimeters)}
        if nickname != nil {self.nickname=nickname!}
        if birthday != nil {self.birthdayBinding=birthday!}
        
    }
    
    //MARK: - Asynchronous tasks
    private var networkQueryController = NetworkQueryController()
    private var _nicknameUpdateCancellable: AnyCancellable?
    private var _heightUpdateCancellable: AnyCancellable?
    private var _weightUpdateCancellable: AnyCancellable?
    private var _birthdayUpdateCancellable: AnyCancellable?
    private var _createExerciseCancellable: AnyCancellable?
    private var _avatarUpadateCancellable: AnyCancellable?
    private var _getUploadedExercisesCancellable: AnyCancellable?
    private var _otherUserInfoLoadingCancellable: AnyCancellable?
    private var _imageLoadingCancellable: AnyCancellable?
    private var _livestreamDeletionCancellable: AnyCancellable?
    private var _fetchNewProfileCancellable: AnyCancellable?
    private var _removeExerciseCancellable: AnyCancellable?
    
    func removeProfile(){
        self.image=UIImage(systemName: "person.fill.questionmark")
        self._height=nil
        self._mass=nil
        self.nickname=""
        self._birthday=nil
        self.uploadedExercises.removeAll()
    }
    
    func fetchProfile(){
        _fetchNewProfileCancellable=networkQueryController.getProfile(email: identifier, token: authenticationToken).receive(on: DispatchQueue.main).sink{[unowned self] newProfile in
            self.setProfile(weight: newProfile.weight, height: newProfile.height, nickname: newProfile.nickname, birthday: newProfile.birthdayDate)
        }
    }
    
    /// Remove exercises from uploads at specified index set. You should use this method to handle list onDelete events.
    func removeExerciseFromUploads(at indices: IndexSet) {
        
        let exercise: Exercise = uploadedExercises[indices.first!]
        uploadedExercises.remove(atOffsets: indices)
        if exercise.playbackType == .recordedVideo{
            _removeExerciseCancellable=networkQueryController.removeVideo(email: identifier, token: authenticationToken, videoId: exercise.id)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] success in
                }
        }
        else{
            _removeExerciseCancellable=networkQueryController.deleteLivestream(zoomLink: exercise.contentLink, token: authenticationToken)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] success in
                }
        }
    }
    
    // MARK: - Instance methods
    
    func copy() -> PublicProfile {
        let copyProfile = PublicProfile(identifier: identifier, fullName: nil)
        copyProfile._nickname = _nickname
        copyProfile.image = image
        copyProfile._birthday = _birthday
        copyProfile._height = _height
        copyProfile._mass = _mass
        return copyProfile
    }
    
    // retrives user's avatar, nickname
    func getRemainingUserInfo(userEmail: String){
        _otherUserInfoLoadingCancellable = networkQueryController.getOtherUserInfoExeptUploadedExercises(email: userEmail)
            .receive(on: DispatchQueue.main)
            .sink{returnedProfile in
                self.nickname=returnedProfile.nickname
                if returnedProfile.avatar != nil && !returnedProfile.avatar!.isEmpty{
                    self.loadAvatar(url: returnedProfile.avatar!)
                }
            }}
    
    //load avatar given url
    func loadAvatar(url: String){
        self._imageLoadingCancellable = NetworkQueryController.shared.loadImage(fromURL: URL(string: "http://127.0.0.1:8000\(url)")!)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveOutput: { outputValue in
                    print("Th: \( String(describing: outputValue))")
                          }
              
            )
            .assign(to: \.image, on: self)
    }
    
    
    //retrieves exercise uploads of a user, given that person's email
    func getExerciseUploads(userEmail: String){
        _getUploadedExercisesCancellable=networkQueryController.getUserUploads(email: userEmail, nickname: nickname, avatar: image!).receive(on: DispatchQueue.main)
            .sink { [unowned self] output in
                self.uploadedExercises=output
            }
    }
    
    func createExercise(newExercise: Exercise, token: String){
        isUploadedVideoListLoading = true
        print("setting loading to true!")

        if newExercise.playbackType == .live{
            _createExerciseCancellable=networkQueryController.createLive(exercise: newExercise, token: token)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] success in
                    DispatchQueue.main.async {
                        self.uploadedExercises.append(newExercise)
                    }
                    DispatchQueue.main.async {
                        self.isUploadedVideoListLoading = false
                    }
                    print("setting loading to false!")
                }
        }
        else{
            // video uploads
            networkQueryController.uploadVideo(atURL: URL(string: newExercise.contentLink)!, exercise: newExercise, token: token) {
                self.uploadedExercises.append($0)
                DispatchQueue.main.async {
                    self.isUploadedVideoListLoading = false
                }
                print("setting loading to false!")
            }
        }
    }
    
    func update(using newProfile: PublicProfile, token: String) {
        var delay:Double = 0.1
        
        if self._nickname != newProfile.nickname{
            DispatchQueue.main.asyncAfter(deadline: .now()+delay){[unowned self] in
                self._nicknameUpdateCancellable=self.networkQueryController.changeNickname(email: self.identifier, nickname: newProfile.nickname, token: token)
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] success in
                        self.nickname = newProfile.nickname
                    }
            }
            delay+=0.5
        }
        
        
        
        if self.image != newProfile.image{
            DispatchQueue.main.asyncAfter(deadline: .now()+delay){[unowned self] in
                _avatarUpadateCancellable = networkQueryController.changeAvatar(email: identifier, avatar: newProfile.image!, token: token).receive(on: DispatchQueue.main)
                    .sink{ [unowned self] success in
                        self.image = newProfile.image
                    }
            }
            delay+=0.5
        }
        
        if self._birthday != newProfile._birthday{
            DispatchQueue.main.asyncAfter(deadline: .now()+delay){[unowned self] in
            _birthdayUpdateCancellable=networkQueryController.changeBirthday(email: self.identifier, birthday: newProfile._birthday!, token: token)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] success in
                    self.birthdayBinding = newProfile._birthday!
                }
            }
            delay+=0.5
        }
        
        if self._height != newProfile._height{
            DispatchQueue.main.asyncAfter(deadline: .now()+delay){[unowned self] in
            _heightUpdateCancellable=networkQueryController.changeHeight(email: self.identifier, height: newProfile._height!.converted(to: .centimeters).value, token: token)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] success in
                    self.heightBinding = newProfile._height!
                }
            }
            delay+=0.5
        }
        
        if self._mass != newProfile._mass{
            DispatchQueue.main.asyncAfter(deadline: .now()+delay){[unowned self] in
            _weightUpdateCancellable=networkQueryController.changeWeight(email: self.identifier, weight: (newProfile._mass?.converted(to: .kilograms).value)!, token: token)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] success in
                    self.massBinding = newProfile._mass!
                }
            }
            delay+=0.5
        }
            
        objectWillChange.send()
    }
    
    func shouldAppearOnSearchText(_ text: String) -> Bool {
        return self.identifier.lowercased().contains(text.lowercased()) ||
            self._nickname?.description.contains(text.lowercased()) ?? false
    }
    
    // MARK: - Convenience type properties
    
    static let exampleProfile: PublicProfile = {
        let profile = PublicProfile(identifier: "Zihan Qi", fullName: nil)
        profile._height = Measurement(value: 183, unit: UnitLength.centimeters)
        profile._mass = Measurement(value: 60, unit: UnitMass.kilograms)
        return profile
    }()
    
    static let exampleProfiles: [PublicProfile] = [
        PublicProfile(identifier: "Abudala Awabel", fullName: nil),
        PublicProfile(identifier: "Tim Cook", fullName: nil),
        PublicProfile(identifier: "Mark Redekopp", fullName: nil),
        PublicProfile(identifier: "Andrew Goodney", fullName: nil),
        PublicProfile(identifier: "Johnny Appleseed", fullName: nil),
        PublicProfile(identifier: "Jane Doe", fullName: nil),
        PublicProfile(identifier: "Carol Folt", fullName: nil),
        PublicProfile(identifier: "Barack Obama", fullName: nil),
        PublicProfile(identifier: "Mike Pence", fullName: nil),
        PublicProfile(identifier: "Donald Trump", fullName: nil),
    ]
}

// MARK: - View Model
extension PublicProfile {
    var isNicknameSet: Bool {
        return _nickname != nil
    }
    var nickname: String {
        get { _nickname ?? "" }
        set {
            objectWillChange.send()
            _nickname = newValue
        }
    }
    var isBirthdaySet: Bool {
        return _birthday != nil
    }
    var isHeightSet: Bool {
        return _height != nil
    }
    var isMassSet: Bool {
        return _mass != nil
    }
    var birthdayBinding: Date {
        get { return _birthday ?? Date() }
        set {
            objectWillChange.send()
            _birthday = newValue
        }
    }
    var birthdayDescription: String? {
        guard let birthday = _birthday else { return nil }
        return Self.birthdayFormatter.string(from: birthday)
    }
    var heightBinding: Measurement<UnitLength> {
        get { return _height ?? heightRange[heightRange.count / 2] }
        set {
            objectWillChange.send()
            _height = newValue
        }
    }
    var massBinding: Measurement<UnitMass> {
        get { return _mass ?? massRange[massRange.count / 2]}
        set {
            objectWillChange.send()
            _mass = newValue
        }
    }
    var heightDescription: String? {
        guard let height = _height else { return nil }
        return Self.heightFormatter.string(fromMeters: height.converted(to: .meters).value)
    }
    
    var massDescription: String? {
        guard let mass = _mass else { return nil }
        return Self.massFormatter.string(fromKilograms: mass.converted(to: .kilograms).value)
    }
    
    var getMass: Double?{
        guard let mass = _mass else { return nil }
        return mass.converted(to: .kilograms).value
    }
    
}

// MARK: - Protocol conformance

extension PublicProfile: Equatable, Comparable {
    static func == (lhs: PublicProfile, rhs: PublicProfile) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    static func < (lhs: PublicProfile, rhs: PublicProfile) -> Bool {
        return lhs.identifier < rhs.identifier
    }
}

// MARK: - Convenience extension

extension Measurement where UnitType == UnitLength {
    /// Returns the person height description string using PublicProfile's heightFormatter.
    var personHeightDescription: String {
        PublicProfile.heightFormatter.string(fromMeters: self.converted(to: .meters).value)
    }
}

extension Measurement where UnitType == UnitMass {
    /// Returns the person mass description string using PublicProfile's massFormatter.
    var personMassDescription: String {
        PublicProfile.massFormatter.string(fromKilograms: self.converted(to: .kilograms).value)
    }
}
