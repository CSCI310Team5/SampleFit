//
//  NetworkQueryController.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/17/21.
//

import Foundation

struct NetworkQueryController {
    func createAccount(using: SignUpInformation, completionHandler: @escaping (_ success: Bool) -> ()) {
        // FIXME: Create account over network
        // assuming success now
        // faking networking delay of 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completionHandler(true)
        }
    }
    
    func signIn(using: SignInInformation, completionHandler: @escaping (_ success: Bool) -> ()) {
        // FIXME: Sign in over network
        // assuming succes now
        // faking networking delay of 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completionHandler(true)
        }
    }
}
