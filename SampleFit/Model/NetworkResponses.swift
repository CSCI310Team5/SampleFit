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
    var avatar: String?
    
    var birthdayDate: Date? {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd"
        var date: Date?
        if birthday != nil {
            date = formatter.date(from: birthday!)
            return date
        }
        else{
            return nil
        }
        
    }
}

//possible JSON format for publicprofile response
struct OtherUserProfile: Codable {
    var email: String
    var nickname: String = ""
    var avatar: String?
}

struct WorkoutHistory: Codable{
    var completionTime: String
    var duration: String
    var calories: String
    var category: String
}

struct Livestream: Codable{
    var email: String=""
    var zoom_link: String=""
    var title: String=""
    var category: String=""
    var description: String = ""
    var timeLimit: Int = 0
    var peopleLimit: Int = 0
    var createTime: String=""
}



struct VideoFormat: Codable{
    var videoID: String = ""
    var videoName: String = ""
    var description: String = ""
    var videoCategory: String = ""
    var videoImage: String = ""
    var videoURL: String = ""
    var email: String = ""
    var likes: Int? = 0
    var enableComments: Bool = true
}

struct Comments: Codable{
    
    struct comment: Codable{
        var id: String
        var email: String
        var createTime: String
        var content: String
    }
    
    var comments: [comment]
    
    var page_number: Int

}
