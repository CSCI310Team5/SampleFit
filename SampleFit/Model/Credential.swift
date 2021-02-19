//
//  Credential.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/18/21.
//

import Foundation

/// Stores user credential.
class Credential {
    var identifier: String = ""
    var fullName: PersonNameComponents?
    
    init() {}
    init(identifier: String, fullName: PersonNameComponents?) {
        self.identifier = identifier
        self.fullName = fullName
    }
}
