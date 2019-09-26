//
//  DLUpdater.swift
//  DLUpdater
//
//  Created by Daniel Lin on 08/12/2016.
//  Copyright © 2016 Daniel Lin. All rights reserved.
//

import Siren
import UIKit

public extension RulesManager.UpdateType {
    /// The frequency for each kind of `UpdateType` in which the user is prompted to update the app once a new version is available in the App Store and if they have not updated yet.
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

    /// The type of alert for each kind of `UpdateType` to present after a successful version check has been performed.
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
    private static func _updateType(_ updateType: RulesManager.UpdateType, persistent: Bool = false, updateForced: Bool = false, alertCustom: Bool = false) -> Rules {
        let frequency: UpdatePromptFrequency = (!persistent || updateForced) ? .immediately : updateType.frequency
        let alertType: AlertType = alertCustom ? .none : (updateForced ? .force : updateType.alertType)
        return Rules(promptFrequency: frequency, forAlertType: alertType)
    }

    /// The `Rules` would be used by default when the App Store version of the app signifies that it is a **major** version update (A.b.c.d).
    ///
    /// - Parameters:
    ///   - persistent: Determine whether the updates check would be persistently performed whenever the app enters the foreground.
    ///   - updateForced: Determine whether the update alert should make user update the app forcedly.
    ///   - alertCustom: Determine whether a custom alert should be presents to the end-user for the custom operations.
    /// - Returns: The `Rules` of update alert presentation.
    static func major(persistent: Bool = false, updateForced: Bool = false, alertCustom: Bool = false) -> Rules {
        return self._updateType(.major, persistent: persistent, updateForced: updateForced, alertCustom: alertCustom)
    }

    /// The `Rules` would be used by default when the App Store version of the app signifies that it is a **minor** version update (a.B.c.d).
    ///
    /// - Parameters:
    ///   - persistent: Determine whether the updates check would be persistently performed whenever the app enters the foreground.
    ///   - updateForced: Determine whether the update alert should make user update the app forcedly.
    ///   - alertCustom: Determine whether a custom alert should be presents to the end-user for the custom operations.
    /// - Returns: The `Rules` of update alert presentation.
    static func minor(persistent: Bool = false, updateForced: Bool = false, alertCustom: Bool = false) -> Rules {
        return self._updateType(.minor, persistent: persistent, updateForced: updateForced, alertCustom: alertCustom)
    }

    /// The `Rules` would be used by default when the App Store version of the app signifies that it is a **patch** version update (a.b.C.d).
    ///
    /// - Parameters:
    ///   - persistent: Determine whether the updates check would be persistently performed whenever the app enters the foreground.
    ///   - updateForced: Determine whether the update alert should make user update the app forcedly.
    ///   - alertCustom: Determine whether a custom alert should be presents to the end-user for the custom operations.
    /// - Returns: The `Rules` of update alert presentation.
    static func patch(persistent: Bool = false, updateForced: Bool = false, alertCustom: Bool = false) -> Rules {
        return self._updateType(.patch, persistent: persistent, updateForced: updateForced, alertCustom: alertCustom)
    }

    /// The `Rules` would be used by default when the App Store version of the app signifies that it is a **revision** version update (a.b.c.D).
    ///
    /// - Parameters:
    ///   - persistent: Determine whether the updates check would be persistently performed whenever the app enters the foreground.
    ///   - updateForced: Determine whether the update alert should make user update the app forcedly.
    ///   - alertCustom: Determine whether a custom alert should be presents to the end-user for the custom operations.
    /// - Returns: The `Rules` of update alert presentation.
    static func revision(persistent: Bool = false, updateForced: Bool = false, alertCustom: Bool = false) -> Rules {
        return self._updateType(.revision, persistent: persistent, updateForced: updateForced, alertCustom: alertCustom)
    }
}

/// Extension of `Siren`
public typealias DLUpdater = Siren

private var _majorRulesKey: Int = 0
private var _minorRulesKey: Int = 0
private var _patchRulesKey: Int = 0
private var _revisionRulesKey: Int = 0

// MARK: - DLUpdater

public extension DLUpdater {
    /// The `Rules` that should be used when the App Store version of the app signifies that it is a **major** version update (A.b.c.d). Overrides `Rules.major()`.
    var majorRules: Rules? {
        get {
            return objc_getAssociatedObject(self, &_majorRulesKey) as? Rules
        }
        set {
            objc_setAssociatedObject(self, &_majorRulesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// The `Rules` that should be used when the App Store version of the app signifies that it is a **minor** version update (a.B.c.d). Overrides `Rules.minor()`.
    var minorRules: Rules? {
        get {
            return objc_getAssociatedObject(self, &_minorRulesKey) as? Rules
        }
        set {
            objc_setAssociatedObject(self, &_minorRulesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// The `Rules` that should be used when the App Store version of the app signifies that it is a **patch** version update (a.b.C.d). Overrides `Rules.patch()`.
    var patchRules: Rules? {
        get {
            return objc_getAssociatedObject(self, &_patchRulesKey) as? Rules
        }
        set {
            objc_setAssociatedObject(self, &_patchRulesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// The `Rules` that should be used when the App Store version of the app signifies that it is a **revision** version update (a.b.c.D). Overrides `Rules.revision()`.
    var revisionRules: Rules? {
        get {
            return objc_getAssociatedObject(self, &_revisionRulesKey) as? Rules
        }
        set {
            objc_setAssociatedObject(self, &_revisionRulesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// Initialization of updater object with the specified region code.
    /// - Parameter regionCode: The region or country code for the App Store in which the app is availabe.
    convenience init(regionCode: String) {
        self.init()

        self.setRegionCode(regionCode)
    }

    /// Set the region or country of an App Store in which the app is available. By default, all version check requests are performed against the US App Store. If the app is not available in the US App Store, set it to the identifier of at least one App Store region within which it is available.
    ///
    /// - Parameter code: The region or country code for the App Store in which the app is availabe.
    func setRegionCode(_ code: String) {
        self.apiManager = APIManager(countryCode: code)
    }

    /// Set the attributes of update alert presentation.
    ///
    /// - Parameters:
    ///   - tintColor: The alert's tintColor. Settings this to `nil` defaults to the system default color.
    ///   - appName: The name of the app (overrides the default/bundled name).
    ///   - alertTitle: The title field of the `UIAlertController`.
    ///   - alertMessage: The `message` field of the `UIAlertController`.
    ///   - updateButtonTitle: The `title` field of the Next Time Button `UIAlertAction`.
    ///   - nextTimeButtonTitle: The `title` field of the Skip Button `UIAlertAction`.
    ///   - skipButtonTitle: The `title` field of the Update Button `UIAlertAction`.
    ///   - forceLanguage: The language the alert to which the alert should be set. If `nil`, it falls back to the device's preferred locale.
    func setPresentation(alertTintColor tintColor: UIColor? = nil,
                         appName: String? = nil,
                         alertTitle: String = AlertConstants.alertTitle,
                         alertMessage: String = AlertConstants.alertMessage,
                         updateButtonTitle: String = AlertConstants.updateButtonTitle,
                         nextTimeButtonTitle: String = AlertConstants.nextTimeButtonTitle,
                         skipButtonTitle: String = AlertConstants.skipButtonTitle,
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

    /// Check for available updates from App Store and make alert presentation if needed.
    ///
    /// - Parameters:
    ///   - persistent: Determine whether the updates check would be persistently performed whenever the app enters the foreground.
    ///   - updateForced: Determine whether the update alert should make user update the app forcedly.
    ///   - alertCustom: Determine whether a custom alert should be presents to the end-user for the custom operations.
    ///   - completion: Returns the metadata around a successful version check and interaction with the update modal or it returns nil.
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

        self.wail(performCheck: persistent ? .onForeground : .onDemand, completion: completion)
    }
}
