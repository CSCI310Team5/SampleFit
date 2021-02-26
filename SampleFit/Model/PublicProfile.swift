//
//  PublicProfile.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/18/21.
//

import Foundation
import SwiftUI

/// User's information that is publicly available to other users. You should use PublicProfile to uniquely identify a user's information.
class PublicProfile: Identifiable {
    var identifier: String = ""
    var fullName: PersonNameComponents?
    var image: Image?
    
    init() {}
    init(identifier: String, fullName: PersonNameComponents?) {
        self.identifier = identifier
        self.fullName = fullName
    }
    
    // MARK: - Instance methods
    
    func shouldAppearOnSearchText(_ text: String) -> Bool {
        return self.identifier.lowercased().contains(text.lowercased()) ||
            self.fullName?.description.contains(text.lowercased()) ?? false
    }
    
    // MARK: - Convenience type properties
    
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

extension PublicProfile: Equatable, Comparable {
    static func == (lhs: PublicProfile, rhs: PublicProfile) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    static func < (lhs: PublicProfile, rhs: PublicProfile) -> Bool {
        return lhs.identifier < rhs.identifier
    }
    
    
}
