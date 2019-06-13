//
//  DLUpdater.swift
//  DLUpdater
//
//  Created by Daniel Lin on 08/12/2016.
//  Copyright © 2016 Daniel Lin. All rights reserved.
//

import UIKit
import Siren

public extension RulesManager.UpdateType {
    
    var frequency: Rules.UpdatePromptFrequency {
        switch self {
        case .major:
            return .immediately
        case .minor:
            return .daily
        case .patch:
            return .weekly
        case .revision:
            return .weekly
        case .unknown:
            return .immediately
        }
    }
    
    var alertType: Rules.AlertType {
        switch self {
        case .major:
            return .option
        case .minor:
            return .option
        case .patch:
            return .option
        case .revision:
            return .skip
        case .unknown:
            return .none
        }
    }
}

public extension Rules {
    
    static func updateType(_ updateType: RulesManager.UpdateType, persistent: Bool = false, updateForced: Bool = false, alertCustom: Bool = false) -> Rules {
        let frequency: UpdatePromptFrequency = (!persistent || updateForced) ? .immediately : updateType.frequency
        let alertType: AlertType = alertCustom ? .none : (updateForced ? .force : updateType.alertType)
        return Rules(promptFrequency: frequency, forAlertType: alertType)
    }
    
    static func major(persistent: Bool = false, updateForced: Bool = false, alertCustom: Bool = false) -> Rules {
        return updateType(.major, persistent: persistent, updateForced: updateForced, alertCustom: alertCustom)
    }
    
    static func minor(persistent: Bool = false, updateForced: Bool = false, alertCustom: Bool = false) -> Rules {
        return updateType(.minor, persistent: persistent, updateForced: updateForced, alertCustom: alertCustom)
    }
    
    static func patch(persistent: Bool = false, updateForced: Bool = false, alertCustom: Bool = false) -> Rules {
        return updateType(.patch, persistent: persistent, updateForced: updateForced, alertCustom: alertCustom)
    }
    
    static func revision(persistent: Bool = false, updateForced: Bool = false, alertCustom: Bool = false) -> Rules {
        return updateType(.revision, persistent: persistent, updateForced: updateForced, alertCustom: alertCustom)
    }
}

public typealias DLUpdater = Siren

private var _majorRulesKey: Int = 0
private var _minorRulesKey: Int = 0
private var _patchRulesKey: Int = 0
private var _revisionRulesKey: Int = 0

public extension DLUpdater {
    
    var majorRules: Rules? {
        get {
            return objc_getAssociatedObject(self, &_majorRulesKey) as? Rules
        }
        set {
            objc_setAssociatedObject(self, &_majorRulesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var minorRules: Rules? {
        get {
            return objc_getAssociatedObject(self, &_minorRulesKey) as? Rules
        }
        set {
            objc_setAssociatedObject(self, &_minorRulesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var patchRules: Rules? {
        get {
            return objc_getAssociatedObject(self, &_patchRulesKey) as? Rules
        }
        set {
            objc_setAssociatedObject(self, &_patchRulesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var revisionRules: Rules? {
        get {
            return objc_getAssociatedObject(self, &_revisionRulesKey) as? Rules
        }
        set {
            objc_setAssociatedObject(self, &_revisionRulesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func setRegionCode(_ code: String) {
        self.apiManager = APIManager(countryCode: code)
    }
    
    func setPresentation(alertTintColor tintColor: UIColor? = nil,
                         appName: String? = nil,
                         alertTitle: String  = AlertConstants.alertTitle,
                         alertMessage: String  = AlertConstants.alertMessage,
                         updateButtonTitle: String  = AlertConstants.updateButtonTitle,
                         nextTimeButtonTitle: String  = AlertConstants.nextTimeButtonTitle,
                         skipButtonTitle: String  = AlertConstants.skipButtonTitle,
                         forceLanguageLocalization forceLanguage: Localization.Language? = nil) {
        self.presentationManager = PresentationManager(alertTintColor: tintColor,
                                                       appName: appName,
                                                       alertTitle: alertTitle,
                                                       alertMessage: alertMessage,
                                                       updateButtonTitle: updateButtonTitle,
                                                       nextTimeButtonTitle: nextTimeButtonTitle,
                                                       skipButtonTitle: skipButtonTitle,
                                                       forceLanguageLocalization: forceLanguage)
    }
    
    func check(persistent: Bool = false, updateForced: Bool = false, alertCustom: Bool = false, completion: ResultsHandler? = nil) {
        self.rulesManager = RulesManager(majorUpdateRules: self.majorRules ?? Rules.major(persistent: persistent,
                                                                                          updateForced: updateForced,
                                                                                          alertCustom: alertCustom),
                                         minorUpdateRules: self.minorRules ?? Rules.minor(persistent: persistent,
                                                                                          updateForced: updateForced,
                                                                                          alertCustom: alertCustom),
                                         patchUpdateRules: self.patchRules ?? Rules.patch(persistent: persistent,
                                                                                          updateForced: updateForced,
                                                                                          alertCustom: alertCustom),
                                         revisionUpdateRules: self.revisionRules ?? Rules.revision(persistent: persistent,
                                                                                                   updateForced: updateForced,
                                                                                                   alertCustom: alertCustom))
        
        self.wail(performCheck: persistent ? .onForeground : .onDemand , completion: completion)
    }
}
