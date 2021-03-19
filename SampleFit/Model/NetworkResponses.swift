//
//  NetworkResponses.swift
//  SampleFit
//
//  Created by apple on 3/17/21.
//

import Foundation

struct SignUpData: Codable{
    var OK: Int = 0
}

struct ProfileData: Codable{
    var nickname : String?
    var birthday: String?
    var weight : Double?
    var height: Double?
}

//possible JSON format for publicprofile response
struct OtherUserProfile: Codable{
    var email: String
    var nickname: String = ""
    var avatar: URL
//    var uploadedVideos: [Exercise]
}

struct WorkoutHistory: Codable{
    var completionTime: String
    var duration: String
    var calories: String
    var category: String
}
