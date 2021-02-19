//
//  NetworkQueryController.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/17/21.
//

import Foundation
import SwiftUI

/// Handles asynchronous networking tasks.
struct NetworkQueryController {
    func createAccount(using: CreateAccountInformation, completionHandler: @escaping (_ success: Bool) -> ()) {
        // FIXME: Create account over network
        // assuming success now
        // faking networking delay of 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completionHandler(true)
        }
    }
    
    func signIn(using: SignInInformation, completionHandler: @escaping (_ success: Bool) -> ()) {
        // FIXME: Sign in over network
        // assuming success now
        // faking networking delay of 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completionHandler(true)
        }
    }
    
    func exerciseFeedsForUser(withCredential credential: Credential, completionHandler: @escaping (_ result: Result<[Exercise], Error>) -> ()) {
        // FIXME: Search for exercise feeds for user over network
        // assuming success now
        // faking networking delay of 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completionHandler(.success(Exercise.sampleExercisesFull))
        }
    }
    
    func loadImage(fromURL url: URL, completionHandler: @escaping (_ result: Result<Image, Error>) -> ()) {
        // FIXME: Load image over network
        // assuming success now
        // faking networking delay of 2 seconds
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            completionHandler(Result.success(Image(systemName: "network")))
        }
    }
    
    static let shared = NetworkQueryController()
}
