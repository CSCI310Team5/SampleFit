#  Tasks - based on Homework 3 requirements  

## Networking  
All code that talks to the backend should go into NetworkQueryController. All current functionalities are fake (they dont make network calls just yet) so that you can focus on the UI first.    
  
## 1. Retrieve Accounts  
1. ✅ In AuthenticationView, user should use their email instead of username as the unique identifier. Change UI accordingly.  
2. Add functionality that tells the backend to retrieve password for a given email. This functionality should make call into a method in NetworkQueryController, and let the backend handle the rest.  
  
## 3. Change passwords  
1. Implement changePassword() in UserData, which should call into a new method in NetworkQueryController.  
2. Optional: ChangePasswordView should display circular progress indicator when in progress and dismiss only after success.  
  
## 4. Watch Video & Join Live Stream  
✅1. Add a property in Exercise to store the video URL.  
✅2. Add a property in Exercise to store the live stream Zoom Link.  
✅3. In ExerciseDetail, display the Zoom Link if the Exercise has a .live playback type.  
4. Probably requires a bit more effort: Load video for play.  
    a. In Exercise, add a method which loads the video into memory only when called (the video will probably? be stored in a AVVideo instance), and add another method which cleans the memory of the video (could probably be done just by assigning nil to the video property).  
    b. In ExerciseDetail, add a .onAppear() and a .onDisappear clause. If the exercise is a .recordedVideo playback type, it should call into the two methods above to create video on appear and clean up memory on disappear.  
☑️c. In ExerciseDetail, if the exercise has a .live playback type, display a button / link to the zoom link over the preview image and hide the video player. If the exercise has a .recordedVideo playback type, show the video player and hide the preview image. (use if else / switch statements to optionally display the views)  
  
## 5. Create New Exercise  
✅ 1. In Me -> Uploads, add a "+" button as the trailing navigation item. This button should display a new view using .sheet (in which the user can enter exercise name, type, and upload link / video).  
✅2. In this new view, user should be able to enter the exercise name, the category, the playback type, and upload a video or enter zoom link. You should create a new Exercise instance in this view as an @ObservedObject and modify this instance in this view.  
☑️3.  At the top of this view, there should be a Cancel button on the left and a Done button on the right. Tapping the Cancel button dismisses the view without doing any work. Tapping the Done button will call into a function in UserData, which first adds the new exercise instance to private information, then calls into a new network function to upload the Exercise. You can find similar structure in ChangePasswordView.  
4. Optional: (but probably needed to prevent further issues) Done button should be enabled only when all necesssary information are entered. We probably need to add a new property in Exercise which keeps track the status of all components, and tell us whether an Exercise has all the information needed. Use this property to enable / disable the Done button.  

  
## 8. View other user's interfaces
✅ 1. Implement UserDetail. Display public information about the user (most of which are in PublicProfile.)  
✅ 2. Add a "follow / unfollow" button in this view. Use FollowButton. You can find an existing implementation in FolllowingUserList.  
  

## 10. Record Workout  
✅ 1. I haven't thought through on this yet. Feel free to implement it in any way that makes sense. I think the easier way would be to record the workout locally, and on completion, call a function into UserData, which adds the workout to PrivateInformation, and calls into a function in NetworkQueryController to talk to the backend.

## Other
✅ 1. We can keep other UI as is for now (since there's already a LOT of work to do).
☑️ 2. For a record of what needs to change: workout history UI in Me should change to reflect the requirement from previous homework.
  
## Networking  
1. You can delay implementing networking code by faking the network result first (like all the functions currently in it).  
2. Prioritize Sign Up / Sign In / Sign Out functionalities first. These are specified by the homework 3 requirements.  
    ❓a. Ask the backend to remove password checking on any sign up / sign in. This is currently NOT handled on the frontend.  
    b. In the sign Up / Sign In / Sign Out functionalities, serialize AuthenticiationState to a JSON object that the backend wants.  
    c. Send the JSON object over the network using URLSession APIs.  
3. In NetworkQueryController, add functions which retrieves all necessary information in PublicProfile.
4. In NetworkQueryController, add functions which retrieves all necessary information in PrivateInformation.


