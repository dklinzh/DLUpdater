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
    
    public typealias DetectNewVersionBlock = (_ shouldUpdate: Bool, _ error: Error?, _ lookupModel: SirenLookupModel?) -> Void
    
    public static let shared = DLUpdater()
    
    private let siren = Siren.shared
    private var appDidBecomeActiveObserved = false
    private var appWillEnterForegroundObserved = false
    private var autoCheckType: CheckUpdateType = .weekly
    private var shouldForcelyCheckUpdate = false
    fileprivate var detectNewVersionBlock: DetectNewVersionBlock?
    fileprivate var lookupModel: SirenLookupModel?
    
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
            } else if appWillEnterForegroundObserved {
                appWillEnterForegroundObserved = false
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
            }
        }
    }
}

extension DLUpdater: SirenDelegate {
    
    // 弹出更新提示框
    public func sirenDidShowUpdateDialog(alertType: Siren.AlertType) {
        self.detectNewVersionBlock?(true, nil, self.lookupModel)
        self.lookupModel = nil
        
        self.forcelyCheckUpdate(alertType: alertType)
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
        self.detectNewVersionBlock?(false, error, nil)
    }
    
    // 检测到更新但不弹出提示框
    public func sirenDidDetectNewVersionWithoutAlert(message: String, updateType: UpdateType) {
        // FIXME: TODO with 'message'
        self.detectNewVersionBlock?(true, nil, self.lookupModel)
        self.lookupModel = nil
    }
    
    // 返回版本更新检查信息对象
    public func sirenNetworkCallDidReturnWithNewVersionInformation(lookupModel: SirenLookupModel) {
        self.lookupModel = lookupModel
    }
    
    // 已安装最新版本
    public func sirenLatestVersionInstalled() {
        self.detectNewVersionBlock?(false, nil, nil)
    }
}
