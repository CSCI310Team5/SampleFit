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
        
    private var _birthdayFormatter: DateFormatter
    private var _heightformatter: LengthFormatter
    private var _massformatter: MassFormatter
    
    var birthdayDateRange: ClosedRange<Date> = {
        let calendar = Calendar.autoupdatingCurrent
        let startComponents = DateComponents(year: 1900)
        let endComponents = calendar.dateComponents(in: calendar.timeZone, from: Date())
        return calendar.date(from: startComponents)! ... calendar.date(from: endComponents)!
    }()
    
    init(identifier: String, fullName: PersonNameComponents?) {
        self.identifier = identifier
        
        if let fullName = fullName {
            let nameFormatter = PersonNameComponentsFormatter()
            _nickname = nameFormatter.string(from: fullName)
        }
        
        self._birthdayFormatter = DateFormatter()
        _birthdayFormatter.timeStyle = .none
        _birthdayFormatter.dateStyle = .medium
        self._heightformatter = LengthFormatter()
        _heightformatter.isForPersonHeightUse = true
        _heightformatter.unitStyle = .short
        self._massformatter = MassFormatter()
        _massformatter.isForPersonMassUse = true
        let dropFractionsNumberFormatter = NumberFormatter()
        dropFractionsNumberFormatter.maximumFractionDigits = 0
        _heightformatter.numberFormatter = dropFractionsNumberFormatter
        _massformatter.numberFormatter = dropFractionsNumberFormatter
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
    var birthdayBinding: Date {
        get { return _birthday ?? Date() }
        set {
            objectWillChange.send()
            _birthday = newValue
        }
    }
    var birthdayDescription: String? {
        guard let birthday = _birthday else { return nil }
        return _birthdayFormatter.string(from: birthday)
    }
    var heightDescription: String? {
        guard let height = _height else { return nil }
        return _heightformatter.string(fromMeters: height.converted(to: .meters).value)
    }
    var massDescription: String? {
        guard let mass = _mass else { return nil }
        return _massformatter.string(fromKilograms: mass.converted(to: .kilograms).value)
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
