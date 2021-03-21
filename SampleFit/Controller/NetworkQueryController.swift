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
    private var _imageLoadingCancellable: AnyCancellable?
    private var _otherUserProfileLoadingCancellable: AnyCancellable?
    
    private func livestreamToExercise(live: Livestream, category: Exercise.Category)->Exercise{
        
        let exercise = Exercise(id: String(Int.random(in: Int.min...Int.max)), name: live.title, description: live.description, category: category, playbackType: Exercise.PlaybackType.live, owningUser: PublicProfile(identifier: live.email, fullName: nil), duration: Measurement(value: Double(live.timeLimit), unit: UnitDuration.minutes), previewImageIdentifier: "", peoplelimt: live.peopleLimit, contentlink: live.zoom_link)
        
        self._otherUserProfileLoadingCancellable = NetworkQueryController.shared.getOtherUserInfoExeptUploadedExercises(email: live.email)
            .receive(on: DispatchQueue.main)
            .sink{returnedProfile in
                exercise.owningUser=returnedProfile
            }
        return exercise
    }
    
    private func videoToExercise(upload: VideoFormat, uploadCategory: Exercise.Category)->Exercise{
        
        
        let excercise = Exercise(id: upload.videoID, name: upload.videoName, category: uploadCategory, playbackType: Exercise.PlaybackType.recordedVideo, owningUser: PublicProfile(identifier: upload.email, fullName: nil), duration: nil, previewImageIdentifier: upload.videoImage)
        
        self._otherUserProfileLoadingCancellable = NetworkQueryController.shared.getOtherUserInfoExeptUploadedExercises(email: upload.email)
            .receive(on: DispatchQueue.main)
            .sink{returnedProfile in
                excercise.owningUser=returnedProfile
            }
        
        excercise.peopleLimit=0
        excercise.contentLink=upload.videoURL
        
        return excercise
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
                //                print("Login token: \(result.token)")
                return result.token
            }
            .replaceError(with: "")
            .eraseToAnyPublisher()
    }
    
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
        
        //        print("Token: \(token)")
        //
        //        print(String(data: encode, encoding: .utf8)!)
        return URLSession.shared.dataTaskPublisher(for: request)
            //                        .handleEvents(receiveOutput: { outputValue in
            //
            //                            print("This is the OutPUT!!!: \( outputValue)")
            //                            print( (outputValue.response as! HTTPURLResponse ).statusCode)
            //                            let decode = try! JSONDecoder().decode(ProfileData.self, from: outputValue.data)
            //                            print(decode)
            //                        })
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
        let url = URL(string: "http://127.0.0.1:8000/user/profile/password")!
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
    
    func getFollowList(email: String, token: String)-> AnyPublisher<[PublicProfile], Never>{
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
            .handleEvents(receiveOutput: { outputValue in
                print("This is the OutPUT!!!: \( outputValue)")
                print( (outputValue.response as! HTTPURLResponse ).statusCode)
                print(String(data: outputValue.data, encoding: .utf8))
                let decode = try! JSONDecoder().decode([OtherUserProfile].self, from: outputValue.data)
                print("\(decode)")
            })
            .map{
                $0.data
            }
            .decode(type: [OtherUserProfile].self, decoder: JSONDecoder())
            .map{result in
                var profileList : [PublicProfile] = []
                for r in result{
                    let profile = PublicProfile(identifier: r.email, fullName: nil)
                    profile.nickname = r.nickname
                    profile.uploadedExercises = []
                    if r.avatar != nil && !r.avatar!.isEmpty {
                        self._imageLoadingCancellable =
                            NetworkQueryController.shared.loadImage(fromURL: URL(string: "http://127.0.0.1:8000\(r.avatar!)")!).receive(on: DispatchQueue.main).sink{[unowned self] returned in profile.image = returned!
                            }}
                    profileList.append(profile)
                    
                }
                return profileList
                
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
                var videoUploaded : [Exercise] = []
                let profile: PublicProfile = PublicProfile(identifier: email, fullName: nil)
                profile.image=avatar
                profile.nickname=nickname
                var uploadCategory: Exercise.Category = Exercise.Category.cycling
                
                for upload in result.uploadedVideos{
                    for category in Exercise.Category.allCases{
                        if category.networkCall == upload.videoCategory{
                            uploadCategory=category
                        }}
                    
                    let excercise = self.videoToExercise(upload: upload, uploadCategory: uploadCategory)
                    
                    videoUploaded.append(excercise)
                }
                
                return videoUploaded
            }
            .replaceError(with: [])
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
    
    //returns everything except uploaded exercises list
    func getOtherUserInfoExeptUploadedExercises(email:String)->AnyPublisher<PublicProfile, Never>{
        struct EncodeData: Codable{
            var email: String
        }
        
        let encodeData = EncodeData(email: email)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/getOtherUserInfo")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=encode
        let profile: PublicProfile = PublicProfile(identifier: email, fullName: nil)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: { outputValue in
                
                print("This is the OutPUT!!!: \( outputValue)")
                print( (outputValue.response as! HTTPURLResponse ).statusCode)
                print(String(data: outputValue.data, encoding: .utf8))
                let decode = try! JSONDecoder().decode(OtherUserProfile.self, from: outputValue.data)
                print("\(decode)")
            })
            .map {
                $0.data
            }
            .decode(type: OtherUserProfile.self, decoder: JSONDecoder())
            .map{result in
                if result.avatar != nil && !result.avatar!.isEmpty {
                    self._imageLoadingCancellable =
                        NetworkQueryController.shared.loadImage(fromURL: URL(string: "http://127.0.0.1:8000\(result.avatar!)")!).receive(on: DispatchQueue.main).sink{[unowned self] returned in profile.image = returned!
                            /* http:/sdfsdfsdfd8000/media/users/avatars/zihanqiusc.edu.png */
                        }}
                profile.nickname=result.nickname
                return profile
            }
            .handleEvents(receiveOutput: {
                print($0)
            })
            .replaceError(with: PublicProfile(identifier: "errorprofileEmail@usc.edu", fullName: nil))
            .eraseToAnyPublisher()
    }
    
    
    func likeVideo(email: String, videoId: String, token: String)-> AnyPublisher<Bool, Never>{
        
        let dataThing = "email=\(email)&videoID=\(videoId)".data(using: .utf8)
        
        let url = URL(string: "http://127.0.0.1:8000/user/likeVideo")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=dataThing
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
        
        let dataThing = "email=\(email)&videoID=\(videoId)".data(using: .utf8)
        
        let url = URL(string: "http://127.0.0.1:8000/user/unlikeVideo")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=dataThing
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
        
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/createLivestream")!
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
    
    
    func getWorkoutHistory(token: String, email: String)->AnyPublisher<[WorkoutHistory],Never>{
        
        struct EncodeData: Codable{
            var email: String
        }
        let encodeData = EncodeData(email: email)
        let encode = try! JSONEncoder().encode(encodeData)
        let url = URL(string: "http://127.0.0.1:8000/user/getExerciseHistory")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody = encode
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map{
                $0.data
            }
            .decode(type: [WorkoutHistory].self, decoder: JSONDecoder())
            .map{result in
                return result
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
    
    
    func getAllLivestream(token: String) -> AnyPublisher<[Exercise],Never> {
        
        let url = URL(string: "http:127.0.0.1:8000/search/getAllLivestreams")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        return URLSession.shared.dataTaskPublisher(for: request)
//            .handleEvents(receiveOutput: { outputValue in
//                print("This is the OutPUT!!!: \( outputValue)")
//                print( (outputValue.response as! HTTPURLResponse ).statusCode)
//                print(String(data: outputValue.data, encoding: .utf8))
//                let decode = try! JSONDecoder().decode([Livestream].self, from: outputValue.data)
//            })
            .map{
                $0.data
            }.decode(type: [Livestream].self, decoder: JSONDecoder())
            .map{result in
                var livestreams: [Exercise]=[]
                for live in result{
                    let category = Exercise.Category.identify(networkCall: live.category)
                    let tmp = self.livestreamToExercise(live: live, category: category)
                    livestreams.append(tmp)
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
                    var category = Exercise.Category.identify(networkCall: video.videoCategory)
                    let tmp = self.videoToExercise(upload:video, uploadCategory: category)
                    videos.append(tmp)
                }
                return videos
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    
    
    /// Queries the network and returns the exercise feeds or a the default example exercise array on failure.
    func exerciseFeedsForUser(token: String) -> AnyPublisher<[Exercise], Never> {
        
        var exercises: [Exercise] = []
        
        
        /*
         func fetchLiveFeeds(category: Exercise.Category, token: String) -> [Exercise]{
         var output:[Exercise]=[]
         _fetchLivestreamCancellable=networkQueryController.getLivestreamByCategory(category: category, token: token)
         .receive(on: DispatchQueue.main)
         .sink{[unowned self] exercises in
         output=exercises
         }
         return output
         }
         func fetchVideoFeeds(category: Exercise.Category, token: String) -> [Exercise]{
         var output:[Exercise]=[]
         _fetchLivestreamCancellable=networkQueryController.getVideoByCategory(category: category, token: token)
         .receive(on: DispatchQueue.main)
         .sink{[unowned self] exercises in
         output=exercises
         }
         return output
         }
         */
        
        
        
        return Future<[Exercise], Error> { promise in
            promise(.success(Exercise.exampleExercisesFull))
        }
        .replaceError(with: Exercise.exampleExercisesSmall)
        .delay(for: .seconds(2), scheduler: DispatchQueue.global())
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
                    
                    var uploadCategory = Exercise.Category.hiit
                    
                    for category in Exercise.Category.allCases{
                        if category.networkCall == video.category{
                            uploadCategory=category
                        }}
                    
                    let tmp = self.livestreamToExercise(live: video, category: uploadCategory)
                    exercises.append(tmp)
                }
                
                return exercises
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    
    /// Quries the network for user results and returns a publisher that emits either relevant user credentials on success or an error on failure.
    func searchUserResults(searchText: String) -> AnyPublisher<[PublicProfile], Error> {

        return Future { promise in
            promise(.success(PublicProfile.exampleProfiles.filter { $0.shouldAppearOnSearchText(searchText) }))
        }
        .delay(for: .seconds(2), scheduler: DispatchQueue.global())
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
    func uploadVideo(atURL videoURL: URL, exercise: Exercise, token: String,  completion: @escaping (Exercise) -> ()) {
        
        let networkURL = URL(string: "http://127.0.0.1:8000/user/uploadVideo")!
        var request = URLRequest(url: networkURL)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        _videoEncodingCancellable = _encodeVideoAsMP4(videoURL: videoURL)
            .replaceError(with: videoURL)
            .sink { [unowned self] mp4VideoURL in
                // video is now converted to MP4
                
                let filename = videoURL.lastPathComponent
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
                                                fileName: filename,
                                                mimeType: videoMimeType,
                                                fileData: mp4VideoData,
                                                using: boundary))
                httpBody.append(convertFileData(fieldName: "videoImage",
                                                fileName: filename,
                                                mimeType: imgMimeType,
                                                fileData: previewImageData,
                                                using: boundary))
                
                httpBody.appendString("--\(boundary)--")
                request.httpBody = httpBody as Data
                
                request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
                
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let data = data {
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
    
    
    static let shared = NetworkQueryController()
}
