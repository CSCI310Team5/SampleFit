//
//  WorkoutView.swift
//  SampleFit
//
//  Created by apple on 3/11/21.
//

import SwiftUI



class workoutTimer: ObservableObject{
    
    @Published var seconds = 0
    var timer = Timer()
    @Published var isWorkingout = false
    @Published var calories: Double = 0
    
    func start(mass: Double) {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.seconds += 1
            self.calories = Double(self.seconds)*3.5/12000*mass
        }
    }
    
    func stop(category: String) -> Workout{
        timer.invalidate()
        let workout = Workout(caloriesBurned: Int(self.calories), date: Date(), categories: category, duration: self.seconds)
        self.seconds=0
        self.calories=0
        return workout
    }
}

struct WorkoutView: View {
    @ObservedObject var privateInformation: PrivateInformation
    @EnvironmentObject var userData: UserData
    @ObservedObject var publicInformation: PublicProfile
    
    var categoryName: String
    var categoryIndex: Double
    
    @ObservedObject var timer=workoutTimer()
    
    func asString(second: Int) -> String{
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: TimeInterval(second))!
    }
    
    
    var body: some View {
        
        VStack {
            Text("🔥Let's Do \(categoryName)🔥").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).bold()
            
            VStack{
                Text("Time Exercised: \(asString(second: timer.seconds))").padding()
                
                if publicInformation.massDescription != nil {
                    Text("Calories Burned So Far: \((String(format: "%.2f", timer.calories*categoryIndex)) ) Cal")
                }else{
                    Text("Set your weight in your profile page to start recording calorie burned").foregroundColor(.red)
                }
            }.padding(.vertical,100)
            Button(action: {
                timer.isWorkingout ? privateInformation.workoutHistory.append(self.timer.stop(category: categoryName))
                    : self.timer.start(mass: publicInformation.getMass ?? 0)
                withAnimation {timer.isWorkingout.toggle()}
            }) {
                Group {
                    if timer.isWorkingout {
                        HStack {
                            Image(systemName: "pause.circle.fill")
                                .font(.title3)
                            Text("End Workout")
                        }
                        
                    } else {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .font(.title3)
                            Text("Start Workout")
                        }
                    }
                }
                .font(.headline)
                .foregroundColor(Color.systemBackground)
                .frame(minWidth: 100, maxWidth: 150)
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 7.5)
                        .fill(Color.accentColor)
                )
            }
            .padding()
            Spacer()
            
        }.padding()
        .onDisappear{
            if timer.isWorkingout {
                
                privateInformation.workoutHistory.append(self.timer.stop(category: categoryName))
                
                timer.isWorkingout.toggle()
            }
            
            
            
            
        }
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var userData = UserData()
    static var previews: some View {
        WorkoutView(privateInformation: PrivateInformation.examplePrivateInformation,publicInformation: userData.publicProfile, categoryName: "Yoga", categoryIndex: 1.5).environmentObject(userData)
    }
}
