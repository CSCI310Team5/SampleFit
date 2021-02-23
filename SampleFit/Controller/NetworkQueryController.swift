//
//  NetworkQueryController.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/17/21.
//

import Foundation
import SwiftUI
import Combine

/// Handles asynchronous networking tasks.
class NetworkQueryController {
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
    
    /// Queries the network and returns the exercise feeds or an error in the completion handler.
    func exerciseFeedsForUser(withCredential credential: PersonalInformation, completionHandler: @escaping (_ result: Result<[Exercise], Error>) -> ()) {
        // FIXME: Search for exercise feeds for user over network
        // assuming success now
        // faking networking delay of 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completionHandler(.success(Exercise.exampleExercisesFull))
        }
    }
    
    /// Queries the network for exercise results and returns a publisher that emits either relevant exercises on success or an error on failure.
    func searchExerciseResults(searchText: String, category: Exercise.Category?) -> AnyPublisher<[Exercise], Error> {
        // FIXME: Search for exercise results for user over network
        // assuming success now
        // faking networking delay of 2 seconds
        return Future { promise in
            promise(.success(Exercise.exampleExercisesFull.filter {
                if let category = category {
                    return $0.category == category && $0.shouldAppearOnSearchText(searchText)
                } else {
                    return $0.shouldAppearOnSearchText(searchText)
                }
            }))
        }
        .delay(for: .seconds(2), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    /// Quries the network for user results and returns a publisher that emits either relevant user credentials on success or an error on failure.
    func searchUserResults(searchText: String) -> AnyPublisher<[PersonalInformation], Error> {
        // FIXME: Search for user results for user over network
        // assuming success now
        // faking networking delay of 2 seconds
        return Future { promise in
            promise(.success(PersonalInformation.examplePersonalInformation.filter { $0.shouldAppearOnSearchText(searchText) }))
        }
        .delay(for: .seconds(2), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
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
