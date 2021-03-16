//
//  PublicProfile.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/18/21.
//

import Foundation
import SwiftUI

/// User's information that is publicly available to other users. You should use PublicProfile to uniquely identify a user's information.
class PublicProfile: Identifiable, ObservableObject {
    @Published var identifier: String = ""
    private var _nickname: String?
    /// user's profile image. Defaults to person.fill.
    @Published var image = Image(systemName: "person.fill.questionmark")
    private var _birthday: Date?
    private var _height: Measurement<UnitLength>?
    private var _mass: Measurement<UnitMass>?
    
    @Published var uploadedExercises: [Exercise] = []
    
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
        
        
        
    }
    
    /// Remove exercises from uploads at specified index set. You should use this method to handle list onDelete events.
    func removeExerciseFromUploads(at indices: IndexSet) {
        uploadedExercises.remove(atOffsets: indices)
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
    
    func update(using newProfile: PublicProfile) {
        self._nickname = newProfile.nickname
        self.image = newProfile.image
        self._birthday = newProfile._birthday
        self._height = newProfile._height
        self._mass = newProfile._mass
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
