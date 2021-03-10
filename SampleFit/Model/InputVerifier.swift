//
//  InputVerifier.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/9/21.
//

import Foundation
import Combine

/// Use InputVerfier to handle username and password verifications and updates.
class InputVerifier<InputType> where InputType: Collection, InputType: Equatable {
    /// Publishes update from the original input from the caller.
    private var _inputWillChangeSubject = PassthroughSubject<InputType, Never>()
    private var _outputWillChangeSubject = PassthroughSubject<InputStatus, Never>()
    /// Use this publisher to receive result of the verification.
    var verificationResultWillChangePublisher: AnyPublisher<InputStatus, Never> {
        _outputWillChangeSubject.eraseToAnyPublisher()
    }
    /// Use this publisher to receive to receieve input capped by the limit.
    var inputShouldUpdatePublisher: AnyPublisher<InputType, Never>
    
    /// Attach this subscriber to your publisher that publishes input will change events.
    var inputWillChangeSubscriber: AnySubscriber<InputType, Never> {
        AnySubscriber(_inputWillChangeSubject)
    }
    
        
    private var _beginValidationCancellable: AnyCancellable?
    private var _validationDidReturnCancellable: AnyCancellable?
    
    /// Initializes an input verifier that performs custom verification specified by the validator you provide. Verification is performed only after a specified timer interval eplases between events. You can also limit the maximum length of the input by specifying `limit`.
    init<S>(debounce dueTime: S.SchedulerTimeType.Stride, scheduler: S, limit: Int? = nil, validator: @escaping (InputType) -> AnyPublisher<InputStatus, Never>) where S: Scheduler {
        // publish
        self.inputShouldUpdatePublisher = _inputWillChangeSubject
            .filter {
                if let limit = limit {
                    return $0.count < limit
                } else {
                    return true
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
        
        if dueTime == .zero {
            self._beginValidationCancellable = inputShouldUpdatePublisher
                .sink { [unowned self] newInput in
                    self._validationDidReturnCancellable = validator(newInput)
                        .sink { [unowned self] newStatus in
                            DispatchQueue.main.async {
                                self._outputWillChangeSubject.send(newStatus)
                            }
                        }
                }
        } else {
            self._beginValidationCancellable = inputShouldUpdatePublisher
                .handleEvents(receiveOutput: { [unowned self] _ in
                    self._outputWillChangeSubject.send(.validating)
                    self._validationDidReturnCancellable?.cancel()
                })
                .debounce(for: dueTime, scheduler: scheduler)
                .sink { [unowned self] newInput in
                    self._validationDidReturnCancellable = validator(newInput)
                        .sink { [unowned self] newStatus in
                            DispatchQueue.main.async {
                                self._outputWillChangeSubject.send(newStatus)
                            }
                        }
                }
        }
            
        
            
    }
}

/*
 let usernameVerifier: InputVerifier<String>
 username: String {
    set {
        objectWillChange.send()
        if newValue < 16
        _usernameWillChange.send(newValue)
    }
 }
 
 init() {
    usernameVerifier = InputVerifier<String, InputStatus>(debounce: 1.0, limit: 16, validator: { (newValue: String) -> AnyPublisher<DataEntryStatus, Never> in
        NetworkQueryController.shared.validate(newValue)
    })
 
    _usernameWillChangePublisher.subscribe(usernameVerifier.inputWillChangeSubject)
    usernameVerifier.outputWillChangePublisher.assign(to: \.usernameInputStatus, root: self)
 }
 
 */
