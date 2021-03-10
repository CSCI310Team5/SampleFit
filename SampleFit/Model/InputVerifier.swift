//
//  InputVerifier.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/9/21.
//

import Foundation
import Combine

/// Use InputVerfier to handle username and password verifications and updates.
class InputVerifier<InputType> where InputType: Equatable, InputType: Collection {
    /// Publishes update from the original input from the caller.
    private var _inputWillChangeSubject = PassthroughSubject<InputType, Never>()
    private var _outputWillChangeSubject = PassthroughSubject<InputVerificationStatus, Never>()
    /// Use this publisher to receive result of the verification.
    var verificationResultWillChangePublisher: AnyPublisher<InputVerificationStatus, Never> {
        _outputWillChangeSubject.eraseToAnyPublisher()
    }
    /// Use this publisher to receive to receieve input capped by the limit. If no limit is provided at initialization, this will simply publish the input value.
    var inputShouldUpdatePublisher: AnyPublisher<InputType, Never>
    
    /// Attach this subscriber to your publisher that publishes input will change events.
    var inputWillChangeSubscriber: AnySubscriber<InputType, Never> {
        AnySubscriber(_inputWillChangeSubject)
    }
    
    private var _beginValidationCancellable: AnyCancellable?
    private var _validationDidReturnCancellable: AnyCancellable?
    
    /// Initializes an input verifier that performs custom verification specified by the validator you provide. Verification is performed only after a specified timer interval eplases between events. You can also limit the maximum length of the input by specifying `limit`.
    init<S>(debounce dueTime: S.SchedulerTimeType.Stride, scheduler: S, limit: Int? = nil, validator: @escaping (InputType) -> AnyPublisher<InputVerificationStatus, Never>) where S: Scheduler {
        // publish input values capped by the limit
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
        
        // if dueTime is zero, verify immediately without jumping to .validating state
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
    
    /// Initializes a dummy verifier.
    init() {
        self.inputShouldUpdatePublisher = _inputWillChangeSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
