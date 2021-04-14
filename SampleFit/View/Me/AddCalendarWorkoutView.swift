//
//  AddCalendarWorkoutView.swift
//  SampleFit
//
//  Created by Zihan Qi on 4/12/21.
//

import SwiftUI
import EventKit
import EventKitUI

struct AddCalendarWorkoutView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var selectedDate: Date
    
    class Coordinator: NSObject, EKEventEditViewDelegate {
        @Binding var isPresented: Bool
        var selectedDate: Date
        
        init(isPresented: Binding<Bool>, selectedDate: Date) {
            self._isPresented = isPresented
            self.selectedDate = selectedDate
        }
        
        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            switch action {
            case .canceled:
                print("canceled")
                isPresented = false
                break
            case .saved:
                print("saved")
                isPresented = false
                break
            case .deleted:
                print("deleted")
                break
            @unknown default:
                fatalError("Unknown EKEventEditViewAction")
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isPresented: $isPresented, selectedDate: selectedDate)
    }
    
    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let viewController = EKEventEditViewController()
        viewController.editViewDelegate = context.coordinator
        
        let store = EKEventStore()
        let event = EKEvent(eventStore: store)
        event.title = "New Workout"
        event.startDate = Calendar.current.startOfDay(for: selectedDate)
            .advanced(by: Measurement(value: 8, unit: UnitDuration.hours)
            .converted(to: .seconds).value)
        event.endDate = event.startDate
            .advanced(by: Measurement(value: 30, unit: UnitDuration.minutes)
            .converted(to: .seconds).value)
        event.addAlarm(EKAlarm(relativeOffset: 0))
        
        viewController.eventStore = store
        viewController.event = event
        
        return viewController
    }
    
    func updateUIViewController(_ viewController: EKEventEditViewController, context: Context) {
        
    }
    
}

struct AddCalendarWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        AddCalendarWorkoutView(isPresented: .constant(true), selectedDate: Date())
    }
}
