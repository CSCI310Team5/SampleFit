//
//  NetworkQueryController.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/17/21.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}

struct MessagedError: Error {
    let message: String
}

/// Handles asynchronous networking tasks.
class NetworkQueryController {
    
    let baseURL = URL(string: "http://127.0.0.1:8000")!
    
    
    private func livestreamToExercise(live: Livestream, category: Exercise.Category)->Exercise{
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = formatter.date(from: live.createTime!)!
//        let sourceOffset = (TimeZone(abbreviation: "UTC")?.secondsFromGMT(for: UTCdate))!
//        let destinationOffset = TimeZone.current.secondsFromGMT(for: UTCdate)
//        let timeInterval = TimeInterval(destinationOffset - sourceOffset)
//        let date = Date(timeInterval: timeInterval, since: UTCdate)
        let exercise = Exercise(id: String(Int.random(in: Int.min...Int.max)), name: live.title, description: live.description, category: category, playbackType: Exercise.PlaybackType.live, owningUser: PublicProfile(identifier: live.email, fullName: nil), duration: Measurement(value: Double(live.timeLimit), unit: UnitDuration.minutes), previewImageIdentifier: "\(category.rawValue)-\(Int.random(in: 1...3))", peoplelimt: live.peopleLimit, contentlink: live.zoom_link,startTime: date)
        return exercise
    }
    
    private func videoToExercise(upload: VideoFormat, uploadCategory: Exercise.Category)->Exercise{
        
        
        let excercise = Exercise(id: upload.videoID, name: upload.videoName, description: upload.description, category: uploadCategory, playbackType: Exercise.PlaybackType.recordedVideo, owningUser: PublicProfile(identifier: upload.email, fullName: nil), duration: nil, previewImageIdentifier: upload.videoImage, startTime: nil)
        
        excercise.peopleLimit=0
        excercise.contentLink=upload.videoURL
        excercise.description=upload.description
        excercise.likes=upload.likes
        excercise.comment=upload.enableComments
        
        return excercise
    }
    
    func convertFormField(named name: String, value: String, using boundary: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        
        return fieldString
    }
    
    func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
        let data = NSMutableData()
        
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        
        return data as Data
    }
    
    
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
    
    
    func retrievePassword(_ username: String) -> AnyPublisher<Bool, Never> {
        struct EncodeData: Codable{
            var email: String
        }
        let encodeData = EncodeData(email: username)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/requestTempPassword")!
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
                    return true}
                return false
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
    
    /// Returns a publisher that publishes true values if success and false values if an eror occured.
    func createAccount(using authenticationState: AuthenticationState) -> AnyPublisher<String, Never> {
        struct AuthenticationData: Codable{
            var email: String
            var password: String
        }
        struct LogInData: Codable{
            var token: String
        }
        
        let authen = AuthenticationData(email:authenticationState.username, password: authenticationState.password)
        
        let encode = try! JSONEncoder().encode(authen)
        
        let url = URL(string: "http://127.0.0.1:8000/user/signup")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map {
                $0.data
            }
            .decode(type: LogInData.self, decoder: JSONDecoder())
            .map {result in
                if(result.token.isEmpty){
                    return ""
                }
                return result.token
                
            }
            .replaceError(with: "")
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
        print(String(data: encode, encoding: .utf8)!)
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
                return result.token
            }
            .replaceError(with: "")
            .eraseToAnyPublisher()
    }
    
    func deleteAccount(email:String, token:String)->AnyPublisher<Bool,Never>{
        struct EncodeData: Codable{
            var email: String
        }
        
        let email = EncodeData(email: email)
        let encode = try! JSONEncoder().encode(email)
        let url = URL(string: "http://127.0.0.1:8000/user/deleteAccount")!
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
                return true
            }
            .assertNoFailure()
            .eraseToAnyPublisher()
    }
    
    //returns this user's height, weight, etc
    func getProfile(email:String, token:String) -> AnyPublisher<ProfileData,Never>{
        
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
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: { outputValue in
                print("This is the OutPUT!!!: \( outputValue)")
                print( (outputValue.response as! HTTPURLResponse ).statusCode)
                print(String(data: outputValue.data, encoding: .utf8))
                let decode = try! JSONDecoder().decode(ProfileData.self, from: outputValue.data)
                print("\(decode)")
            })
            .map{
                $0.data
            }
            .decode(type: ProfileData.self, decoder: JSONDecoder())
            .map{result in
                return result
            }
            .replaceError(with: ProfileData())
            .handleEvents(receiveOutput:{
                print($0.birthday)
            }
            )
            .eraseToAnyPublisher()
    }
    
    //returns everything except uploaded exercises list needed to show userDetail view
    func getOtherUserInfoExeptUploadedExercises(email:String)->AnyPublisher<OtherUserProfile, Never>{
        struct EncodeData: Codable{
            var email: String
        }
        
        let encodeData = EncodeData(email: email)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/getOtherUserInfo")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        return URLSession.shared.dataTaskPublisher(for: request)
            .map {
                $0.data
            }
            .decode(type: OtherUserProfile.self, decoder: JSONDecoder())
            .map{result in
                return result
            }
            .replaceError(with: OtherUserProfile(email: email))
            .eraseToAnyPublisher()
    }
    
    
    func follow(email: String, followUser: String, token: String)-> AnyPublisher<Bool, Never>{
        struct EncodeData: Codable{
            var email: String
            var follow: String
        }
        let encodeData = EncodeData(email: email, follow: followUser)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/profile/follow")!
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
    
    
    func unfollow(email: String, unfollowUser: String, token: String)-> AnyPublisher<Bool, Never>{
        struct EncodeData: Codable{
            var email: String
            var follow: String
        }
        let encodeData = EncodeData(email: email, follow: unfollowUser)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/profile/unfollow")!
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
    
    func changePassword(email: String, newPassword: String, token: String)-> AnyPublisher<Bool, Never>{
        struct EncodeData: Codable{
            var email: String
            var newPassword: String
        }
        let encodeData = EncodeData(email: email, newPassword: newPassword)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/password")!
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
    
    func getFollowList(email: String, token: String)-> AnyPublisher<[OtherUserProfile], Never>{
        struct EncodeData: Codable{
            var email: String
        }
        let encodeData = EncodeData(email: email)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/followList")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        return URLSession.shared.dataTaskPublisher(for: request)
            .map{
                $0.data
            }
            .decode(type: [OtherUserProfile].self, decoder: JSONDecoder())
            .map{result in
                return result
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    
    func getFollowers(email: String, token: String)-> AnyPublisher<[PublicProfile], Never>{
        struct EncodeData: Codable{
            var email: String
        }
        let encodeData = EncodeData(email: email)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/followList")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        return URLSession.shared.dataTaskPublisher(for: request)
            .map{
                $0.data
            }
            .decode(type: [OtherUserProfile].self, decoder: JSONDecoder())
            .map{result in
                var followers: [PublicProfile] = []
                for r in result{
                    let profile = PublicProfile(identifier: r.email, fullName: nil)
                    profile.nickname = r.nickname
                    profile.uploadedExercises = []
                    if r.avatar != nil && !r.avatar!.isEmpty{
                        profile.loadAvatar(url: r.avatar!)
                    }
                    followers.append(profile)
                }
                return followers
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func getUserUploads(email: String, nickname: String, avatar: UIImage) -> AnyPublisher<[Exercise],Never>{
        struct EncodeData: Codable{
            var email: String
        }
        
        struct DecodeData: Codable{
            var uploadedVideos: [VideoFormat]
            var livestreams: [Livestream]
        }
        
        let encodeData = EncodeData(email: email)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/getOtherUserInfo")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        
        return URLSession.shared.dataTaskPublisher(for: request)
            
            .map{
                $0.data
            }
            
            .decode(type: DecodeData.self, decoder: JSONDecoder())
            .map{result in
                var exercises: [Exercise]=[]
                
                for video in result.uploadedVideos{
                    
                    var uploadCategory = Exercise.Category.hiit
                    
                    for category in Exercise.Category.allCases{
                        if category.networkCall == video.videoCategory{
                            uploadCategory=category
                        }}
                    
                    let tmp = self.videoToExercise(upload:video, uploadCategory: uploadCategory)
                    exercises.append(tmp)
                }
                
                for video in result.livestreams{
                    
                    //                    let formatter = DateFormatter()
                    //                    formatter.timeStyle = .short
                    //                    formatter.dateStyle = .short
                    //                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                    //                    formatter.timeZone = TimeZone(abbreviation: "UTC")
                    //                    let UTCdate = formatter.date(from: video.createTime!)!
                    //                    dateFormatter.timeZone = TimeZone.current
                    //                    let date = formatter.date(from: <#T##String#>)
                    //                    let endDate = date.advanced(by: Double(video.timeLimit*60))
                    //                    let currentDate = Date()
                    //                    if Int(currentDate.timeIntervalSinceReferenceDate) < Int(endDate.timeIntervalSinceReferenceDate){
                    var uploadCategory = Exercise.Category.hiit
                    
                    for category in Exercise.Category.allCases{
                        if category.networkCall == video.category{
                            uploadCategory=category
                        }}
                    
                    let tmp = self.livestreamToExercise(live: video, category: uploadCategory)
                    exercises.append(tmp)
                    
                    //                    }
                }
                
                return exercises
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func addWatchHistory(email: String, id: String, token: String)-> AnyPublisher<Bool,Never>{
        struct EncodeData: Codable{
            var email: String
            var videoID: String
        }
        
        let encodeData = EncodeData(email: email, videoID: id)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/viewVideo")!
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
                return true
            }
            .assertNoFailure()
            .eraseToAnyPublisher()
    }
    
    func getWatchedHistory(email: String, token: String) -> AnyPublisher<[Exercise],Never>{
        struct EncodeData: Codable{
            var email: String
        }
        
        let encodeData = EncodeData(email: email)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/getVideoHistory")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map{
                $0.data
            }
            .decode(type: [VideoFormat].self, decoder: JSONDecoder())
            
            .map{result in
                var watchedVideos : [Exercise] = []
                
                for video in result{
                    
                    var uploadCategory: Exercise.Category = Exercise.Category.cycling
                    
                    for category in Exercise.Category.allCases{
                        if category.networkCall == video.videoCategory{
                            uploadCategory=category
                        }
                    }
                    let excercise = self.videoToExercise(upload: video, uploadCategory: uploadCategory)
                    
                    watchedVideos.append(excercise)
                }
                
                return watchedVideos
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    
    func clearWatchedHistory(email:String, token: String)->AnyPublisher<Bool,Never>{
        struct EncodeData: Codable{
            var email: String
        }
        let encodeData = EncodeData(email: email)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/clearVideoHistory")!
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
                return true
            }
            .assertNoFailure()
            .eraseToAnyPublisher()
        
    }
    
    func getLikedVideos(email: String, token: String) -> AnyPublisher<[Exercise],Never>{
        struct EncodeData: Codable{
            var email: String
        }
        
        let encodeData = EncodeData(email: email)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/likedVids")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map{
                $0.data
            }
            .decode(type: [VideoFormat].self, decoder: JSONDecoder())
            
            .map{result in
                var likedVideos : [Exercise] = []
                
                for video in result{
                    
                    var uploadCategory: Exercise.Category = Exercise.Category.cycling
                    
                    for category in Exercise.Category.allCases{
                        if category.networkCall == video.videoCategory{
                            uploadCategory=category
                        }
                    }
                    let excercise = self.videoToExercise(upload: video, uploadCategory: uploadCategory)
                    
                    likedVideos.append(excercise)
                }
                
                return likedVideos
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    
    func likeVideo(email: String, videoId: String, token: String)-> AnyPublisher<Bool, Never>{
        
        //        let dataThing = "email=\(email)&videoID=\(videoId)".data(using: .utf8)
        struct EncodeData: Codable{
            var email: String
            var videoID: String
        }
        
        let encodeData = EncodeData(email: email, videoID: videoId)
        let encode = try! JSONEncoder().encode(encodeData)
        
        let url = URL(string: "http://127.0.0.1:8000/user/likeVideo")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        
        //                print(String(data: encode, encoding: .utf8)!)
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
    
    
    func unlikeVideo(email: String, videoId: String, token: String)-> AnyPublisher<Bool, Never>{
        
        struct EncodeData: Codable{
            var email: String
            var videoID: String
        }
        
        let encodeData = EncodeData(email: email, videoID: videoId)
        let encode = try! JSONEncoder().encode(encodeData)
        
        let url = URL(string: "http://127.0.0.1:8000/user/unlikeVideo")!
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
    
    
    func createLive(exercise: Exercise, token: String)->AnyPublisher<Bool,Never>{
        
        var encodeData = Livestream()
        encodeData.email=exercise.owningUser.identifier
        encodeData.zoom_link = exercise.contentLink
        encodeData.title=exercise.name
        encodeData.description=exercise.description
        encodeData.category=exercise.category.networkCall
        encodeData.timeLimit=Int((exercise.duration?.converted(to: .minutes).value)!)
        encodeData.peopleLimit=exercise.peopleLimit
        
        //        let formatter = DateFormatter()
        //        formatter.timeStyle = .short
        //        formatter.dateStyle = .short
        //        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        //        encodeData.createTime=formatter.string(from: Date())
        
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/createLivestream")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        print(String(data: encode, encoding: .utf8)!)
        
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
    
    
    func deleteLivestream(zoomLink: String, token: String, email: String)-> AnyPublisher<Bool, Never>{
        
        struct EncodeData: Codable{
            var email: String
            var zoom_link: String
        }
        let encodeData = EncodeData(email: email, zoom_link: zoomLink)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/deleteLiveStream")!
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
    
    func joinLivestream(zoomLink: String, token: String, email: String)-> AnyPublisher<Bool, Never>{
        
        struct EncodeData: Codable{
            var email: String
            var zoom_link: String
        }
        let encodeData = EncodeData(email: email, zoom_link: zoomLink)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/joinLiveStream")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: {
                print(String(data: $0.data, encoding: .utf8))
            })
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
    
    func quitLivestream(zoomLink: String, token: String, email: String) {
        
        struct EncodeData: Codable{
            var email: String
            var zoom_link: String
        }
        let encodeData = EncodeData(email: email, zoom_link: zoomLink)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/quitLiveStream")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(#function), \(error)")
            }
        }.resume()
    }
    
    func getWorkoutHistory(email: String)->AnyPublisher<[Workout],Never>{
        
        struct EncodeData: Codable{
            var email: String
        }
        let encodeData = EncodeData(email: email)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/getExerciseHistory")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody = encode
//        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map{
                $0.data
            }
            .decode(type: [WorkoutHistory].self, decoder: JSONDecoder())
            .map{workouts in
                var workoutHistory: [Workout] = []
                for workout in workouts{
                    var newHistory = Workout(caloriesBurned: Double(workout.calories)!, date: Date(), categories: "", duration: Int(workout.duration)!)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    let date = formatter.date(from: workout.completionTime)
                    newHistory.date = date!
                    
                    for category in Exercise.Category.allCases{
                        if category.networkCall==workout.category{
                            newHistory.categories=category.description
                        }
                    }
                    
                    workoutHistory.append(newHistory)
                }
                return workoutHistory
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    
    func addWorkoutHistory(workout: Workout, token: String, email: String)->AnyPublisher<Bool,Never>{
        
        struct EncodeData: Codable{
            var email: String
            var completionTime: String
            var duration: Int
            var calories: Double
            var category: String
        }
        var category="O"
        //change the description string to the format the backend wants
        for c in Exercise.Category.allCases{
            if workout.categories == c.description{
                category=c.networkCall
            }
        }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: Date())
        
        let calories =  round(100*workout.caloriesBurned)/100.0
        
        let encodeData = EncodeData(email: email, completionTime: date, duration: workout.duration, calories: calories, category: category )
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/addExerciseHistory")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        //        print(String(data: encode, encoding: .utf8)!)
        
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
    
    func clearWorkoutHistory(token: String, email: String)->AnyPublisher<Bool,Never>{
        struct EncodeData: Codable{
            var email: String
        }
        let encodeData = EncodeData(email: email)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/clearExerciseHistory")!
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
    
    
    func changeAvatar(email: String, avatar: UIImage, token:String)-> AnyPublisher<Bool, Never>{
        
        
        
        let url = URL(string: "http://127.0.0.1:8000/user/profile/avatar")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let httpBody = NSMutableData()
        
        
        httpBody.appendString(convertFormField(named: "email", value: email, using: boundary))
        
        
        httpBody.append(convertFileData(fieldName: "avatar",
                                        fileName: "imagename.png",
                                        mimeType: "image/png",
                                        fileData: avatar.pngData()!,
                                        using: boundary))
        
        httpBody.appendString("--\(boundary)--")
        
        request.httpBody = httpBody as Data
        
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
            var birthday: String
        }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: birthday)
        let encodeData = EncodeData(email: email, birthday: date)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/profile/birthday")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        print("Birthday!")
        print(String(data: encode, encoding: .utf8)!)
        
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
        print("Weight!")
        print(String(data: encode, encoding: .utf8)!)
        
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
        print("Height!")
        print(String(data: encode, encoding: .utf8)!)
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
    
    
    func getAllLivestream(token: String) -> AnyPublisher<[Exercise],Never> {
        
        let url = URL(string: "http:127.0.0.1:8000/search/getAllLivestreams")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        return URLSession.shared.dataTaskPublisher(for: request)
            .map{
                $0.data
            }.decode(type: [Livestream].self, decoder: JSONDecoder())
            .map{result in
                var livestreams: [Exercise]=[]
                for live in result{
                    //                    let formatter = DateFormatter()
                    //                    formatter.timeStyle = .short
                    //                    formatter.dateStyle = .short
                    //                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                    //                    print(live.createTime)
                    //                    let date = formatter.date(from: live.createTime ?? "")!
                    //                    let endDate = date.advanced(by: Double(live.timeLimit*60))
                    //                    let currentDate = Date()
                    //                    if Int(currentDate.timeIntervalSinceReferenceDate) < Int(endDate.timeIntervalSinceReferenceDate){
                    let category = Exercise.Category.identify(networkCall: live.category)
                    let tmp = self.livestreamToExercise(live: live, category: category)
                    livestreams.append(tmp)
                    //                    }
                }
                return livestreams
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func getAllVideo( token: String) -> AnyPublisher<[Exercise],Never>{
        
        
        let url = URL(string: "http://127.0.0.1:8000/search/getAllVideos")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        return URLSession.shared.dataTaskPublisher(for: request)
            .map{
                $0.data
            }.decode(type: [VideoFormat].self, decoder: JSONDecoder())
            .map{result in
                var videos: [Exercise]=[]
                for video in result{
                    let category = Exercise.Category.identify(networkCall: video.videoCategory)
                    let tmp = self.videoToExercise(upload:video, uploadCategory: category)
                    videos.append(tmp)
                }
                return videos
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
        
    func getFolloweeVideoUploads(token: String, email: String) -> AnyPublisher<[Exercise], Never> {
        let url = baseURL.appendingPathComponent("user").appendingPathComponent("getAllFolloweeVideos")

        let request = try! url.urlRequestWithToken(token)
                                .withBody([
                                    "email": email
                                ])
        
        return URLSession.shared.debugDataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: [VideoFormat].self, decoder: JSONDecoder())
            .map { result in
                var videos: [Exercise]=[]
                for video in result{
                    let category = Exercise.Category.identify(networkCall: video.videoCategory)
                    let tmp = self.videoToExercise(upload:video, uploadCategory: category)
                    videos.append(tmp)
                }
                return videos
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    
    
    /// Queries the network for exercise results and returns a publisher that emits either relevant exercises on success or an error on failure.
    func searchExerciseResults(searchText: String, category: Exercise.Category?) -> AnyPublisher<[Exercise], Never> {
        struct SearchData: Codable {
            var title: String = ""
            var category: String = ""
        }
        
        let encodeData = SearchData(title: searchText, category: category?.networkCall ?? "")
        let encode = try! JSONEncoder().encode(encodeData)
        
        let url = URL(string: "http://127.0.0.1:8000/search/videoAndLivestream")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody = encode
        
        struct Returned: Codable{
            var videos: [ VideoFormat]
            var livestreams: [Livestream]
        }
        return URLSession.shared.dataTaskPublisher(for: request)
            //            .handleEvents(receiveOutput: { outputValue in
            //                print("This is the OutPUT!!!: \( outputValue)")
            //                print( (outputValue.response as! HTTPURLResponse ).statusCode)
            //                print(String(data: outputValue.data, encoding: .utf8))
            //                let decode = try! JSONDecoder().decode(Returned.self, from: outputValue.data)
            //                print("\(decode)")
            //            })
            .map{
                $0.data
            }.decode(type: Returned.self, decoder: JSONDecoder())
            .map{result in
                var exercises: [Exercise]=[]
                
                for video in result.videos{
                    
                    var uploadCategory = Exercise.Category.hiit
                    
                    for category in Exercise.Category.allCases{
                        if category.networkCall == video.videoCategory{
                            uploadCategory=category
                        }}
                    
                    let tmp = self.videoToExercise(upload:video, uploadCategory: uploadCategory)
                    exercises.append(tmp)
                }
                
                for video in result.livestreams{
                    
                    //                    let formatter = DateFormatter()
                    //                    formatter.timeStyle = .short
                    //                    formatter.dateStyle = .short
                    //                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                    //                    let date = formatter.date(from: video.createTime ?? "")!
                    //                    let endDate = date.advanced(by: Double(video.timeLimit*60))
                    //                    let currentDate = Date()
                    //                    if Int(currentDate.timeIntervalSinceReferenceDate) < Int(endDate.timeIntervalSinceReferenceDate){
                    var uploadCategory = Exercise.Category.hiit
                    
                    for category in Exercise.Category.allCases{
                        if category.networkCall == video.category{
                            uploadCategory=category
                        }}
                    
                    let tmp = self.livestreamToExercise(live: video, category: uploadCategory)
                    exercises.append(tmp)
                    
                    //                    }
                }
                
                return exercises
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    
    /// Quries the network for user results and returns a publisher that emits either relevant user credentials on success or an error on failure.
    func searchUserResults(searchText: String) -> AnyPublisher<[OtherUserProfile], Never> {
        struct EncodeData: Codable{
            var search: String
            var by_nickname: Int = 1
            var by_email: Int = 1
        }
        let encodeData = EncodeData(search: searchText)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/search/user")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        return URLSession.shared.dataTaskPublisher(for: request)
            .map{
                $0.data
            }
            .decode(type: [OtherUserProfile].self, decoder: JSONDecoder())
            .map{result in
                return result
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func addSearchHistory(email: String, searchText: String, token:String) -> AnyPublisher<Bool,Never>{
        struct EncodeData: Codable{
            var email: String
            var keyword: String
        }
        let encodeData = EncodeData(email: email, keyword: searchText)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/search/addHistory")!
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
                return true
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
    func getSearchHistory(email: String, token: String)->AnyPublisher<[String],Never>{
        struct EncodeData: Codable{
            var email: String
        }
        struct DecodeData: Codable{
            var keyword: String
        }
        let encodeData = EncodeData(email: email)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/search/getHistory")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        return URLSession.shared.dataTaskPublisher(for: request)
            .map{
                $0.data
            }
            .decode(type: [DecodeData].self, decoder: JSONDecoder())
            .map{result in
                var returnedList:[String]=[]
                for s in result{
                    returnedList.append(s.keyword)
                }
                return returnedList
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    
    func clearSearchHistory(email:String, token: String)->AnyPublisher<Bool,Never>{
        struct EncodeData: Codable{
            var email: String
        }
        let encodeData = EncodeData(email: email)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/search/clearHistory")!
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
                return true
            }
            .assertNoFailure()
            .eraseToAnyPublisher()
    }
    /// Returns a publisher that publishes image values if success and nil values if an eror occured.
    func loadImage(fromURL url: URL) -> AnyPublisher<UIImage?, Never> {
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map{
                
                UIImage(data: $0.data)
                
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    private func _encodeVideoAsMP4(videoURL: URL) -> AnyPublisher<URL, Error> {
        let avAsset = AVURLAsset(url: videoURL)
        let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough)
        
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let myDocPath = NSURL(fileURLWithPath: docDir).appendingPathComponent("temp.mp4")?.absoluteString
        
        let docDir2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        
        let filePath = docDir2.appendingPathComponent("rendered-Video.mp4")
        deleteFile(filePath!)
        
        if FileManager.default.fileExists(atPath: myDocPath!){
            do{
                try FileManager.default.removeItem(atPath: myDocPath!)
            }catch let error{
                print(error)
            }
        }
        
        exportSession?.outputURL = filePath
        exportSession?.outputFileType = AVFileType.mp4
        exportSession?.shouldOptimizeForNetworkUse = true
        
        let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
        let range = CMTimeRange(start: start, duration: avAsset.duration)
        exportSession?.timeRange = range
        
        return Future<URL, Error> { promise in
            exportSession!.exportAsynchronously {
                switch exportSession!.status{
                case .failed:
                    print("encoding failed")
                    promise(.failure(exportSession!.error!))
                case .cancelled:
                    print("Export cancelled")
                case .completed:
                    print("encoding Successful")
                    promise(.success(exportSession!.outputURL!))
                default:
                    break
                }
            }
        }
        .eraseToAnyPublisher()
        
    }
    
    func deleteFile(_ filePath:URL) {
        guard FileManager.default.fileExists(atPath: filePath.path) else{
            return
        }
        do {
            try FileManager.default.removeItem(atPath: filePath.path)
        }catch{
            fatalError("Unable to delete file: \(error) : \(#function).")
        }
    }
    
    private var _videoEncodingCancellable: AnyCancellable?
    private var _videoUploadCancellable: AnyCancellable?
    
    /// Uploads video at URL. Returns a publisehr that publishes true values if success and false value if an error occured.
    func uploadVideo(atURL videoURL: URL, exercise: Exercise, token: String, completion: @escaping (Exercise) -> ()) {
        
        let networkURL = URL(string: "http://127.0.0.1:8000/user/uploadVideo")!
        var request = URLRequest(url: networkURL)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        _videoEncodingCancellable = _encodeVideoAsMP4(videoURL: videoURL)
            .replaceError(with: videoURL)
            .sink { [unowned self] mp4VideoURL in
                // video is now converted to MP4
                
                var videoFilename = videoURL.lastPathComponent
                videoFilename.removeLast(4)
                videoFilename.append(".mp4")
                var imageFilename = videoURL.lastPathComponent
                imageFilename.removeLast(4)
                imageFilename.append(".png")
                let imgMimeType = "image/png"
                let videoMimeType = "video/mp4"
                let mp4VideoData = try! Data(contentsOf: mp4VideoURL, options: .alwaysMapped)
                let previewImageData = exercise.image!.pngData()!
                let httpBody = NSMutableData()
                
                httpBody.appendString(convertFormField(named: "email", value: exercise.owningUser.identifier, using: boundary))
                httpBody.appendString(convertFormField(named: "videoName", value: exercise.name, using: boundary))
                httpBody.appendString(convertFormField(named: "description", value: exercise.description, using: boundary))
                httpBody.appendString(convertFormField(named: "videoCategory", value: exercise.category.networkCall, using: boundary))
                
                httpBody.append(convertFileData(fieldName: "videoFile",
                                                fileName: videoFilename,
                                                mimeType: videoMimeType,
                                                fileData: mp4VideoData,
                                                using: boundary))
                httpBody.append(convertFileData(fieldName: "videoImage",
                                                fileName: imageFilename,
                                                mimeType: imgMimeType,
                                                fileData: previewImageData,
                                                using: boundary))
                
                httpBody.appendString(convertFormField(named: "enableComments", value: String(exercise.comment!).capitalized, using: boundary))
                
                httpBody.appendString("--\(boundary)--")
                request.httpBody = httpBody as Data
                
                request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
                
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let data = data {
                        print(String(data:data, encoding: .utf8))
                        let videoFormat = try! JSONDecoder().decode(VideoFormat.self, from: data)
                        let outputExercise = self.videoToExercise(upload: videoFormat, uploadCategory: exercise.category)
                        completion(outputExercise)
                    } else {
                        print("No Data returned!")
                    }
                }.resume()
                //                _videoUploadCancellable = URLSession.shared.dataTaskPublisher(for: request)
                //                    .handleEvents(receiveOutput: { outputValue in
                //
                //                        print("This is the OutPUT!!!: \( outputValue)")
                //                        print( (outputValue.response as! HTTPURLResponse ).statusCode)
                //                        print(String(data: outputValue.data, encoding: .utf8))
                //                        let decode = try! JSONDecoder().decode(VideoFormat.self, from: outputValue.data)
                //                        print("\(decode)")
                //                    })
                //                    .map { $0.data }
                //
                //                    .decode(type: VideoFormat.self, decoder: JSONDecoder())
                //                    .mapError {
                ////                            print("Error: \(($0 as! URLError).localizedDescription)")
                //                        return MessagedError(message: ($0 as! URLError).localizedDescription)
                //
                //                    }
                //                    .replaceError(with: VideoFormat())
                //                    .map {
                //                        let exercise = self.videoToExercise(upload: $0, uploadCategory: exercise.category)
                //                        print(exercise)
                //                        promise(.success(exercise))
                //                    }
                //                    .sink { _ in }
            }
    }
    
    func removeVideo(email: String, token: String, videoId: String) -> AnyPublisher<Bool,Never>{
        
        //        let dataThing = "email=\(email)&videoID=\(videoId)".data(using: .utf8)
        struct EncodeData: Codable{
            var email: String
            var videoID: String
        }
        
        let encodeData = EncodeData(email: email, videoID: videoId)
        let encode = try! JSONEncoder().encode(encodeData)
        
        let url = URL(string: "http://127.0.0.1:8000/user/deleteVideo")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        
        //                print(String(data: encode, encoding: .utf8)!)
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
    
    
    func addComment(email:String, token:String, videoID: String, content:String )-> AnyPublisher<Bool,Never>{
        
        //        let dataThing = "email=\(email)&videoID=\(videoId)".data(using: .utf8)
        struct EncodeData: Codable{
            var email: String
            var videoID: String
            var content: String
        }
        
        let encodeData = EncodeData(email: email, videoID: videoID, content: content)
        let encode = try! JSONEncoder().encode(encodeData)
        
        let url = URL(string: "http://127.0.0.1:8000/video/addComment")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        //                print(String(data: encode, encoding: .utf8)!)
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
    
    
    func getComment(videoID: String, page: Int?)-> AnyPublisher<Comments,Never>{
        
        //        let dataThing = "email=\(email)&videoID=\(videoId)".data(using: .utf8)
        struct EncodeData: Codable{
            var videoID: String
            var pageNumber: Int?
        }
        
        let encodeData = EncodeData(videoID: videoID, pageNumber: page)
        let encode = try! JSONEncoder().encode(encodeData)
        
        let url = URL(string: "http://127.0.0.1:8000/video/getComments")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        
        //                print(String(data: encode, encoding: .utf8)!)
        return URLSession.shared.dataTaskPublisher(for: request)
            .map{
                $0.data
            }
            .decode(type: Comments.self, decoder: JSONDecoder())
            .map{result in
                return result
            }
            .assertNoFailure()
            .eraseToAnyPublisher()
    }
    
    func getUserComment(videoID:String, userEmail:String) -> AnyPublisher<[Comments.comment],Never>{
        struct EncodeData: Codable{
            var videoID: String
            var pageNumber: Int?
        }
        
        let encodeData = EncodeData(videoID: videoID, pageNumber: -1)
        let encode = try! JSONEncoder().encode(encodeData)
        
        let url = URL(string: "http://127.0.0.1:8000/video/getComments")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        
        //                print(String(data: encode, encoding: .utf8)!)
        return URLSession.shared.dataTaskPublisher(for: request)
            .map{
                $0.data
            }
            .decode(type: Comments.self, decoder: JSONDecoder())
            .map{result in
                var commentList: [Comments.comment] = []
                for comment in result.comments{
                    if comment.email == userEmail {
                        commentList.append(comment)
                    }
                }
                return commentList
            }
            .assertNoFailure()
            .eraseToAnyPublisher()
    }
    
    func removeComment(email:String, token:String, videoID: String, id:String )-> AnyPublisher<Bool,Never>{
        
        //        let dataThing = "email=\(email)&videoID=\(videoId)".data(using: .utf8)
        struct EncodeData: Codable{
            var email: String
            var videoID: String
            var id: String
        }
        
        let encodeData = EncodeData(email: email, videoID: videoID, id: id)
        let encode = try! JSONEncoder().encode(encodeData)
        
        let url = URL(string: "http://127.0.0.1:8000/video/deleteComment")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        //                print(String(data: encode, encoding: .utf8)!)
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
    
    
    static let shared = NetworkQueryController()
}

// MARK: - Helper extensions

extension URL {
    func urlRequestWithToken(_ token: String) -> URLRequest {
        var request = URLRequest(url: self)
        request.httpMethod="POST"
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

extension URLRequest {
    static let jsonEncoder = JSONEncoder()
    func withBody<T: Encodable>(_ dictionary: [String: T]) throws -> URLRequest {
        var newRequest = self
        let data = try Self.jsonEncoder.encode(dictionary)
        newRequest.httpBody = data
        return newRequest
    }
}

extension URLSession {
    func debugDataTaskPublisher(for request: URLRequest) -> AnyPublisher<DataTaskPublisher.Output, DataTaskPublisher.Failure> {
        return self.dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: {
                print(String(data: $0.data, encoding: .utf8) as Any)
            })
            .eraseToAnyPublisher()
    }
}
