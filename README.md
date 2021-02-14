#  SampleFit

SampleFit is a prototype app made to faciliate the discussion of the actual app building for CSCI 310.
The app is written in Swift 5.3. This apps uses SwiftUI as the main UI Frameowork.


## System Requirement

MacOS: This project should be built and run on macOS Big Sur 11.0+, Xcode 12.0+.  

Windows: The app itself cannot be run on Windows. However, some data model can be compiled if it includes only the Foundation framework and that the Windows machine has Swift 5 compiler installed.


# Tasks

## Backend

We need to setup a backend with database to:
    1. store and access videos
    2. Regsiter new user
    3. Log in existing user


## Authentication

In `UserData.swift`, several functions are marked with a `// TODO: ` comment. We need to implement networking code (preferrably using `URLSession` to talk to the backend to do actual authentication.)  
Recommended Documentation:  
[Apple Developer Documentation: URLSession](https://developer.apple.com/documentation/foundation/url_loading_system)


## What's Next

All other parts, except authentication, are still a prototype, i.e. fake. We need to implement each part to make it real.

### Writing data models:
This app uses Swift as the language for data models. Feel free to check out the Swift files located in  `SampleFit/Model`.  
To learn more about Swift, check out [The Swift Programming Language Guide](https://docs.swift.org/swift-book/GuidedTour/GuidedTour.html). A Swift Tour section can quickly ramp you up on core language features, and the Language Guide section describes language syntax in details.
Converting between JSON data and our own data models is an essential task. To learn more about how to do this, check out [Apple Developer Documentation: Encoding and Decoding Custom Types](https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types)

### Writing user interfaces:
This app uses SwiftUI as the UI framework. If you are familar with React, SwiftUI can be a easier to pick up. To learn more about SwiftUI, check out [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui/)
and [iOS App Dev with SwiftUI](https://developer.apple.com/tutorials/app-dev-training)

You can also use UIKit and Storyboard to create user interface for an iOS app since UIKit and SwiftUI can be intergrated in the same app. However, implementing complex interfaces can be more challenging with UIKit. Integration work will also need to be done in the end. To develop user interface in UIKit, check out tutorials on UIKit, Storyboard, and AutoLayout.


