//
//  SocialInformation.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/17/21.
//

import Foundation
import Combine

class SocialInformation: ObservableObject {
    var followedUserIdentifiers: [String] = []
    var savedExercises: [String] = []
}
