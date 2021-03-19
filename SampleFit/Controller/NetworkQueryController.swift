//
//  NetworkQueryController.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/17/21.
//

import Foundation
import SwiftUI
import Combine

struct MessagedError: Error {
    let message: String
}

/// Handles asynchronous networking tasks.
class NetworkQueryController {
    
    /// Returns a publisher that publishes true value if success and false values if an error occured.
    func validateUsername(_ username: String) -> AnyPublisher<Bool, Never> {
        struct emailCheck: Codable{
            var email: String
        }
        let email = emailCheck(email: username)
        let encode = try! JSONEncoder().encode(email)
        let url = URL(string: "http://127.0.0.1:8000/user/emails")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        return URLSession.shared.dataTaskPublisher(for: request)
            .map{
                $0.data
            }
            .decode(type: SignUpData.self, decoder: JSONDecoder())
            .map{result in
                if(result.OK==1){
                    print("GET IN")
                    return true}
                return false
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
    /// Returns a publisher that publishes true value if success and false values if an error occured.
    func validatePassword(_ password: String) -> AnyPublisher<Bool, Never> {
        // FIXME: validate password over network
        // faking validation logic now
        // faking networking delay of 2 seconds
        return Future<Bool, Error> { promise in
            if password.count < 8 {
                promise(.failure(MessagedError(message: "Too short")))
            } else {
                promise(.success(true))
            }
        }
        .replaceError(with: false)
        .delay(for: .seconds(2), scheduler: DispatchQueue.global())
        .eraseToAnyPublisher()
    }
    
    
    /// Returns a publisher that publishes true values if success and false values if an eror occured.
    func createAccount(using authenticationState: AuthenticationState) -> AnyPublisher<Bool, Never> {
        struct AuthenticationData: Codable{
            var email: String
            var password: String
        }
        
        let authen = AuthenticationData(email:authenticationState.username, password: authenticationState.password)
        
        let encode = try! JSONEncoder().encode(authen)
        
        let url = URL(string: "http://127.0.0.1:8000/user/signup")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        
        //        print(String(data: encode, encoding: .utf8)!)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            //            .handleEvents(receiveOutput: { outputValue in
            //
            //                print("This is the OutPUT!!!: \( outputValue)")
            //                print( (outputValue.response as! HTTPURLResponse ).statusCode)
            //                let decode = try! JSONDecoder().decode(SignUpData.self, from: outputValue.data)
            //                print(decode.OK)
            //            })
            .map {
                $0.data
            }
            .decode(type: SignUpData.self, decoder: JSONDecoder())
            .map {result in
                if(result.OK==1){
                    print("GET IN")
                    return true}
                return false
            }
            .replaceError(with: false)
            //            .handleEvents(receiveOutput: {
            //                print("This is the final output: \($0)")
            //            })
            .eraseToAnyPublisher()
    }
    
    /// Returns a publisher that publishes true values if success and false values if an eror occured.
    func signIn(using authenticationState: AuthenticationState) -> AnyPublisher<String, Never> {
        struct AuthenticationData: Codable{
            var email: String
            var password: String
        }
        struct LogInData: Codable{
            var token: String
        }
        let authen = AuthenticationData(email:authenticationState.username, password: authenticationState.password)
        
        let encode = try! JSONEncoder().encode(authen)
        //                print(String(data: encode, encoding: .utf8)!)
        let url = URL(string: "http://127.0.0.1:8000/user/login")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        return
            URLSession.shared.dataTaskPublisher(for: request)
            .map{
                $0.data
            }
            .decode(type: LogInData.self, decoder: JSONDecoder())
            .map{result in
                if(result.token.isEmpty){
                    return ""
                }
                //                print("Login token: \(result.token)")
                return result.token
            }
            .replaceError(with: "")
            .eraseToAnyPublisher()
    }
    
    func getProfile(email:String, token:String) -> AnyPublisher<ProfileData,Never>{
        
        print("GET IN NETWORK")
        struct EncodeData: Codable{
            var email: String
        }
        
        let email = EncodeData(email: email)
        let encode = try! JSONEncoder().encode(email)
        let url = URL(string: "http://127.0.0.1:8000/user/profile")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        print(String(data: encode, encoding: .utf8)!)
        
        return URLSession.shared.dataTaskPublisher(for: request)
                        .handleEvents(receiveOutput: { outputValue in
            
                            print("This is the OutPUT!!!: \( outputValue)")
                            print( (outputValue.response as! HTTPURLResponse ).statusCode)
                            let decode = try! JSONDecoder().decode(ProfileData.self, from: outputValue.data)
                            print(decode)
                        })
            .map{
                $0.data
            }
            .decode(type: ProfileData.self, decoder: JSONDecoder())
            .map{result in
                return result
            }
            .replaceError(with: ProfileData())
            .eraseToAnyPublisher()
    }
    
    
    
    func changeNickname(email: String, nickname: String, token:String)-> AnyPublisher<Bool, Never>{
        
        struct EncodeData: Codable{
            var email: String
            var nickname: String
        }
        let encodeData = EncodeData(email: email, nickname: nickname)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/profile/nickname")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        return URLSession.shared.dataTaskPublisher(for: request)
            .map{
                $0.data
            }
            .decode(type: SignUpData.self, decoder: JSONDecoder())
            .map{result in
                if(result.OK==1){
                    return true}
                return false
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
    func changeBirthday(email: String, birthday: Date, token: String)-> AnyPublisher<Bool, Never>{
            
            struct EncodeData: Codable{
                var email: String
                var birthday: Date
            }
            let encodeData = EncodeData(email: email, birthday: birthday)
            let encode = try! JSONEncoder().encode(encodeData)
            let url = URL(string: "http://127.0.0.1:8000/user/profile/weight")!
            var request = URLRequest(url: url)
            request.httpMethod="POST"
            request.httpBody=encode
            request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
            return URLSession.shared.dataTaskPublisher(for: request)
                .map{
                    $0.data
                }
                .decode(type: SignUpData.self, decoder: JSONDecoder())
                .map{result in
                    if(result.OK==1){
                        return true}
                    return false
                }
                .replaceError(with: false)
                .eraseToAnyPublisher()
        }
    
    func changeWeight(email: String, weight: Double, token:String)-> AnyPublisher<Bool, Never>{
        
        struct EncodeData: Codable{
            var email: String
            var weight: Double
        }
        let encodeData = EncodeData(email: email, weight: weight)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/profile/weight")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        return URLSession.shared.dataTaskPublisher(for: request)
            .map{
                $0.data
            }
            .decode(type: SignUpData.self, decoder: JSONDecoder())
            .map{result in
                if(result.OK==1){
                    return true}
                return false
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
    func changeHeight(email: String, height: Double, token:String)-> AnyPublisher<Bool, Never>{
        
        struct EncodeData: Codable{
            var email: String
            var height: Double
        }
        let encodeData = EncodeData(email: email, height: height)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/profile/height")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        return URLSession.shared.dataTaskPublisher(for: request)
            .map{
                $0.data
            }
            .decode(type: SignUpData.self, decoder: JSONDecoder())
            .map{result in
                if(result.OK==1){
                    return true}
                return false
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
    
    /// Queries the network and returns the exercise feeds or a the default example exercise array on failure.
    func exerciseFeedsForUser(withProfile profile: PublicProfile) -> AnyPublisher<[Exercise], Never> {
        // FIXME: Search for exercise feeds for user over network
        // assuming success now
        // faking networking delay of 2 seconds
        return Future<[Exercise], Error> { promise in
            promise(.success(Exercise.exampleExercisesFull))
        }
        .replaceError(with: Exercise.exampleExercisesSmall)
        .delay(for: .seconds(2), scheduler: DispatchQueue.global())
        .eraseToAnyPublisher()
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
        .delay(for: .seconds(2), scheduler: DispatchQueue.global())
        .eraseToAnyPublisher()
    }
    
    /// Quries the network for user results and returns a publisher that emits either relevant user credentials on success or an error on failure.
    func searchUserResults(searchText: String) -> AnyPublisher<[PublicProfile], Error> {
        // FIXME: Search for user results for user over network
        // assuming success now
        // faking networking delay of 2 seconds
        return Future { promise in
            promise(.success(PublicProfile.exampleProfiles.filter { $0.shouldAppearOnSearchText(searchText) }))
        }
        .delay(for: .seconds(2), scheduler: DispatchQueue.global())
        .eraseToAnyPublisher()
    }
    
    /// Returns a publisher that publishes image values if success and nil values if an eror occured.
    func loadImage(fromURL url: URL) -> AnyPublisher<Image?, Never> {
        // FIXME: Load image over network
        // assuming success now
        // faking networking delay of 2 seconds
        return Future<Image?, Error> { promise in
            promise(.success(Image(systemName: "network")))
        }
        .replaceError(with: nil)
        .delay(for: .seconds(2), scheduler: DispatchQueue.global())
        .eraseToAnyPublisher()
    }
    
    
    static let shared = NetworkQueryController()
}
