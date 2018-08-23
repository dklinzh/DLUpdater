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

public enum UpdateAlertType {
    case `default`
    case force
    case none
}

public class DLUpdater: NSObject {
    
    public typealias DetectNewVersionBlock = (_ shouldUpdate: Bool, _ error: Error?, _ lookupModel: SirenLookupModel?) -> Void
    
    public static let shared = DLUpdater()
    
    public var alertType: UpdateAlertType {
        didSet {
            switch alertType {
            case .force:
                siren.alertType = .force
            case .none:
                siren.alertType = .none
            default:
                siren.majorUpdateAlertType = .force
                siren.minorUpdateAlertType = .option
                siren.patchUpdateAlertType = .skip
                siren.revisionUpdateAlertType = .none
            }
        }
    }
    
    private let siren = Siren.shared
    private var appDidBecomeActiveObserved = false
    private var appWillEnterForegroundObserved = false
    private var autoCheckType: CheckUpdateType = .weekly
    private var shouldForcelyCheckUpdate = false
    fileprivate var detectNewVersionBlock: DetectNewVersionBlock?
    fileprivate var lookupModel: SirenLookupModel?
    
    private override init() {
        alertType = .default
        super.init()
        
        #if DEBUG
        siren.debugEnabled = true
        #endif
        
        siren.delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
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
        
        if !appDidBecomeActiveObserved {
            appDidBecomeActiveObserved = true
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
    
    @objc private func checkUpdateImmediately() {
        Siren.shared.checkVersion(checkType: .immediately)
    }
    
    private func forcelyCheckUpdate(alertType: Siren.AlertType) {
        if shouldForcelyCheckUpdate {
            if alertType == .force && !appWillEnterForegroundObserved {
                appWillEnterForegroundObserved = true
                NotificationCenter.default.addObserver(self, selector:#selector(checkUpdateImmediately) , name:NSNotification.Name.UIApplicationWillEnterForeground , object: nil)
            } else if alertType != .force && appWillEnterForegroundObserved {
                appWillEnterForegroundObserved = false
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
            }
        }
    }
}

extension DLUpdater: SirenDelegate {

    /// Siren performed a version check and did not display an alert.
    public func sirenDidDetectNewVersionWithoutAlert(title: String, message: String, updateType: UpdateType) {
        self.detectNewVersionBlock?(true, nil, self.lookupModel)
        self.lookupModel = nil
    }
    
    /// Siren failed to perform version check.
    ///
    /// - Note:
    ///     Depending on the reason for failure,
    ///     a system-level error may be returned.
    public func sirenDidFailVersionCheck(error: Error) {
        self.detectNewVersionBlock?(false, error, nil)
    }
    
    /// User presented with an update dialog.
    public func sirenDidShowUpdateDialog(alertType: Siren.AlertType) {
        self.detectNewVersionBlock?(true, nil, self.lookupModel)
        self.lookupModel = nil
        
        self.forcelyCheckUpdate(alertType: alertType)
    }
    
    /// Siren performed a version check and the latest version was already installed.
    public func sirenLatestVersionInstalled() {
        self.detectNewVersionBlock?(false, nil, nil)
    }
    
    /// Provides the decoded JSON information from a successful version check call.
    ///
    /// - Parameter lookupModel: The `Decodable` model representing the JSON results from the iTunes Lookup API.
    public func sirenNetworkCallDidReturnWithNewVersionInformation(lookupModel: SirenLookupModel) {
        self.lookupModel = lookupModel
    }
    
    /// User did click on button that cancels update dialog.
    public func sirenUserDidCancel() {
        
    }
    
    /// User did click on button that launched "App Store.app".
    public func sirenUserDidLaunchAppStore() {
        
    }
    
    /// User did click on button that skips version update.
    public func sirenUserDidSkipVersion() {
        
    }
}
