//
//  DLUpdater.swift
//  DLUpdater
//
//  Created by Daniel Lin on 08/12/2016.
//  Copyright © 2016 Daniel Lin. All rights reserved.
//

import UIKit
import Siren

public enum CheckUpdateType: Int {
    /// Check application update immediately.
    case immediately = 0
    
    /// Check application update once a day.
    case daily = 1
    
    /// Check application update once a week.
    case weekly = 7
}

public class DLUpdater: NSObject {
    
    public typealias DetectNewVersionBlock = (_ shouldUpdate: Bool, _ error: NSError?) -> Void

    public static let shared = DLUpdater()
    
    private let siren = Siren.shared
    private var didActiveApplicationObserved = false
    private var autoCheckType: CheckUpdateType = .weekly
    private let delegate = DLUpdaterDelegate()
    fileprivate var shouldForcelyCheckUpdate = false
    fileprivate var detectNewVersionBlock: DetectNewVersionBlock?
    
    private override init() {
        super.init()
        
        #if DEBUG
            siren.debugEnabled = true
        #endif
        
        siren.majorUpdateAlertType = .force
        siren.minorUpdateAlertType = .option
        siren.patchUpdateAlertType = .skip
        siren.revisionUpdateAlertType = .none
        
        siren.delegate = delegate
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    public func checkUpdate(type: CheckUpdateType = .immediately, block: DetectNewVersionBlock? = nil) {
        detectNewVersionBlock = block
        
        switch type {
        case .immediately:
            siren.checkVersion(checkType: .immediately)
        case .daily:
            siren.checkVersion(checkType: .daily)
        case .weekly:
            siren.checkVersion(checkType: .weekly)
        }
    }
    
    public func autoCheckUpdate(type: CheckUpdateType = .weekly, block: DetectNewVersionBlock? = nil) {
        autoCheckType = type
        checkUpdate(type: type, block: block)
        
        if !didActiveApplicationObserved {
            didActiveApplicationObserved = true
            NotificationCenter.default.addObserver(self, selector:#selector(checkUpdateWhenDidBecomeActive) , name:NSNotification.Name.UIApplicationDidBecomeActive , object: nil)
        }
    }
    
    public func enableForcelyCheckUpdate() {
        shouldForcelyCheckUpdate = true
    }
    
    @objc private func checkUpdateWhenDidBecomeActive() {
        switch autoCheckType {
        case .immediately:
            siren.checkVersion(checkType: .immediately)
        case .daily:
            siren.checkVersion(checkType: .daily)
        case .weekly:
            siren.checkVersion(checkType: .weekly)
        }
    }
}

class DLUpdaterDelegate: SirenDelegate {
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc private func checkUpdateImmediately() {
        Siren.shared.checkVersion(checkType: .immediately)
    }
    
    func sirenDidShowUpdateDialog(alertType: Siren.AlertType) {
        DLUpdater.shared.detectNewVersionBlock?(true, nil)
        
        if DLUpdater.shared.shouldForcelyCheckUpdate {
            if alertType == .force {
                NotificationCenter.default.addObserver(self, selector:#selector(checkUpdateImmediately) , name:NSNotification.Name.UIApplicationWillEnterForeground , object: nil)
            } else {
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
            }
        }
    }
    
    func sirenUserDidLaunchAppStore() {
        
    }
    
    func sirenUserDidSkipVersion() {
        
    }
    
    func sirenUserDidCancel() {
        
    }
    
    func sirenDidFailVersionCheck(error: NSError) {
        DLUpdater.shared.detectNewVersionBlock?(false, error)
    }
    
    func sirenDidDetectNewVersionWithoutAlert(message: String) {
        DLUpdater.shared.detectNewVersionBlock?(true, nil)
    }
    
    func sirenLatestVersionInstalled() {
        DLUpdater.shared.detectNewVersionBlock?(false, nil)
    }
}
