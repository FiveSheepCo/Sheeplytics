//
//  UserIdentifier.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 05.08.2024.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public extension Sheeplytics.Config {
    
    /// Identication method for the individual user.
    enum UserIdentifier: Sendable {
        case autoDetect
        
        /// Use a debug user identifier.
        case debug
        
        #if canImport(UIKit)
        /// Use the device vendor identifier for identification.
        ///
        /// - NOTE: This value changes when the app is reinstalled.
        case systemVendorId
        #endif
        
        /// Use a custom value for identification.
        case custom(String)
        
        @MainActor internal var resolvedValue: String? {
            switch self {
                case .autoDetect:
                    #if canImport(UIKit)
                    UserIdentifier.systemVendorId.resolvedValue
                    #else
                    nil
                    #endif
                case .debug:
                    "debug"
                #if canImport(UIKit)
                case .systemVendorId:
                    UIDevice.current.identifierForVendor?.uuidString
                #endif
                case .custom(let identifier):
                    identifier
            }
        }
    }
}
