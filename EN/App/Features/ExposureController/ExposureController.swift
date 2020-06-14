/*
* Copyright (c) 2020 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class ExposureController: ExposureControlling {
    init(mutableStatusStream: MutableExposureStateStreaming,
         exposureManager: ExposureManaging?) {
        self.mutableStatusStream = mutableStatusStream
        self.exposureManager = exposureManager
        
        activateExposureManager()
    }
    
    // MARK: - ExposureControlling
    
    func requestExposureNotificationPermission() {
        exposureManager?.setExposureNotificationEnabled(true) { _ in
            self.updateStatusStream()
        }
    }
    
    func requestPushNotificationPermission() {
        // Not implemented yet
    }
    
    func confirmExposureNotification() {
        // Not implemented yet
    }
    
    // MARK: - Private
    
    func activateExposureManager() {
        exposureManager?.activate { _ in
            self.updateStatusStream()
        }
    }
    
    func updateStatusStream() {
        guard let exposureManager = exposureManager else {
            mutableStatusStream.update(state: .inactive(.requiresOSUpdate))
            
            return
        }
        
        let state: ExposureState
        
        switch exposureManager.getExposureNotificationStatus() {
        case .active:
            state = .active
        case .inactive(let error) where error == .bluetoothOff:
            state = .inactive(.bluetoothOff)
        case .inactive(let error) where error == .disabled || error == .restricted:
            state = .inactive(.disabled)
        case .inactive(let error) where error == .notAuthorized:
            state = .notAuthorized
        case .inactive(let error) where error == .unknown:
            state = .notAuthorized
        case .inactive(_):
            state = .inactive(.disabled)
        case .notAuthorized:
            state = .notAuthorized
        }
        
        mutableStatusStream.update(state: state)
    }
    
    private let mutableStatusStream: MutableExposureStateStreaming
    private let exposureManager: ExposureManaging?
}