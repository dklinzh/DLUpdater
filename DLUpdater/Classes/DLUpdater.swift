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
    
    public typealias DetectNewVersionBlock = (_ shouldUpdate: Bool, _ error: Error?) -> Void

    public static let shared = DLUpdater()
    
    private let siren = Siren.shared
    private var didActiveApplicationObserved = false
    private var autoCheckType: CheckUpdateType = .weekly
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

extension DLUpdater: SirenDelegate {
    
    @objc private func checkUpdateImmediately() {
        Siren.shared.checkVersion(checkType: .immediately)
    }
    
    // 弹出更新提示框
    public func sirenDidShowUpdateDialog(alertType: Siren.AlertType) {
        DLUpdater.shared.detectNewVersionBlock?(true, nil)
        
        if DLUpdater.shared.shouldForcelyCheckUpdate {
            if alertType == .force {
                NotificationCenter.default.addObserver(self, selector:#selector(checkUpdateImmediately) , name:NSNotification.Name.UIApplicationWillEnterForeground , object: nil)
            } else {
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
            }
        }
    }
    
    // 用户点击去 app store 更新
    public func sirenUserDidLaunchAppStore() {
        
    }
    
    // 用户点击跳过此次更新
    public func sirenUserDidSkipVersion() {
        
    }
    
    // 用户点击取消更新
    public func sirenUserDidCancel() {
        
    }
    
    // 检查更新失败(可能返回系统级别的错误)
    public func sirenDidFailVersionCheck(error: Error) {
        DLUpdater.shared.detectNewVersionBlock?(false, error)
    }
    
    // 检测到更新但不弹出提示框
    public func sirenDidDetectNewVersionWithoutAlert(message: String, updateType: UpdateType) {
        DLUpdater.shared.detectNewVersionBlock?(true, nil)
    }
    
    // 已安装最新版本
    public func sirenLatestVersionInstalled() {
        DLUpdater.shared.detectNewVersionBlock?(false, nil)
    }
}
