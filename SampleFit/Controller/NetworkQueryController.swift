//
//  NetworkQueryController.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/17/21.
//

import Foundation
import SwiftUI
import Combine

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
            .decode(type: LogInData.self, decoder: JSONDecoder())
            .map {result in
                if(result.token.isEmpty){
                    return ""
                }
                return result.token
                
            }
            .replaceError(with: "")
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
            .map{
                $0.data
            }
            .decode(type: [OtherUserProfile].self, decoder: JSONDecoder())
            .handleEvents(
            )
            .map{result in
                var profileList : [PublicProfile] = []
                for r in result{
                    let profile = PublicProfile(identifier: r.email, fullName: nil)
                    profile.nickname = r.nickname
                    profile.uploadedExercises = []
                    if !r.avatar.isEmpty{
                    self._imageLoadingCancellable =
                        NetworkQueryController.shared.loadImage(fromURL: URL(string: "http://127.0.0.1:8000\(r.avatar)")!).receive(on: DispatchQueue.main).sink{[unowned self] returned in profile.image = returned!
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
            .map{
                $0.data
            }.decode(type: OtherUserProfile.self, decoder: JSONDecoder())
            .map{result in
                if !result.avatar.isEmpty{
                self._imageLoadingCancellable =
                    NetworkQueryController.shared.loadImage(fromURL: URL(string: "http://127.0.0.1:8000\(result.avatar)")!).receive(on: DispatchQueue.main).sink{[unowned self] returned in profile.image = returned!
                    }}
                profile.nickname=result.nickname
                return profile
            }
            .assertNoFailure()
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
    
    func changeAvatar(email: String, avatar: UIImage, token:String)-> AnyPublisher<Bool, Never>{
        
        
        
        let url = URL(string: "http://127.0.0.1:8000/user/profile/avatar")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
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
    
    func getLivestreamByCategory(category: Exercise.Category, token: String) -> AnyPublisher<[Exercise],Never>{
        
        let dataThing = "category=\(category.networkCall)".data(using: .utf8)
        let url = URL(string: "http://127.0.0.1:8000/categories/getLiveStream")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=dataThing
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        return URLSession.shared.dataTaskPublisher(for: request)
            .map{
                $0.data
            }.decode(type: [Livestream].self, decoder: JSONDecoder())
            .map{result in
                var livestreams: [Exercise]=[]
                
                for live in result{
                    let tmp = self.livestreamToExercise(live: live, category: category)
                    livestreams.append(tmp)
                }
                return livestreams
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func getVideoByCategory(category: Exercise.Category, token: String) -> AnyPublisher<[Exercise],Never>{
        
        let dataThing = "videoCategory=\(category.networkCall)".data(using: .utf8)
        let url = URL(string: "http://127.0.0.1:8000/categories/getVideo")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=dataThing
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        return URLSession.shared.dataTaskPublisher(for: request)
                        .handleEvents(receiveOutput: { outputValue in
            
                            print("This is the OutPUT!!!: \( outputValue)")
                            print( (outputValue.response as! HTTPURLResponse ).statusCode)
                            let decode = try! JSONDecoder().decode([VideoFormat].self, from: outputValue.data)
                            print("\(decode)")
                        })
            .map{
                $0.data
            }.decode(type: [VideoFormat].self, decoder: JSONDecoder())
            .map{result in
                var videos: [Exercise]=[]
                for video in result{
                    let tmp = self.videoToExercise(upload:video, uploadCategory: category)
                    videos.append(tmp)
                }
                return videos
            }
            .replaceError(with: [])
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
    func searchExerciseResults(searchText: String, category: Exercise.Category?) -> AnyPublisher<[Exercise], Never> {
//         FIXME: Search for exercise results for user over network
//         assuming success now
//         faking networking delay of 2 seconds
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
    func loadImage(fromURL url: URL) -> AnyPublisher<UIImage?, Never> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map{
                UIImage(data: $0.data)
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    
    static let shared = NetworkQueryController()
}
