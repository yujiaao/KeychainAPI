//
//  Keychain.swift
//  Keychain
//
//  Created by Justin Williams on 9/15/14.
//  Copyright (c) 2014 Second Gear. All rights reserved.
//

import Foundation
import Security

public enum Accessibility: Int
{
    // DEFAULT. Item data can only be accessed while the device is unlocked.
    case WhenUnlocked
    
    // Item data can only be accessed once the device has been unlocked after a restart.
    case AfterFirstUnlock
    
    // Item data can always be accessed regardless of the lock state of the device
    case Always
    
    // Item data can only be accessed while the device is unlocked.
    // Only available if a passcode is set on the device.
    case PasscodeSetThisDeviceOnly
    
    // Item data can only be accessed while the device is unlocked.
    case WhenUnlockedThisDeviceOnly
    
    // Item data can only be accessed once the device has been unlocked after a restart
    case AfterFirstUnlockThisDeviceOnly
    
    // Item data can always be accessed regardless of the lock state of the device
    case AlwaysThisDeviceOnly
}

public class Keychain
{
    private var service: String
//    private var accessGroup: String?
    private var accessibility: Accessibility
    
    // MARK: Initializers
    // ========================================================
    // Initializers
    // ========================================================
    public init(service: String, accessibility: Accessibility)
    {
        self.service = service
        
//        // Access groups aren't supported on iOS Simualtor still? What year is this?
//        #if arch(i386) && os(iOS)
//            self.accessGroup = service
//        #endif

        self.accessibility = accessibility
    }
    
    // MARK: Public Methods
    // ========================================================
    // Public Methods
    // ========================================================
    public func add(account: Account) -> Bool
    {
        assert(account.isValid(), "Can only add a valid account to keychain")
        let attributes = account.attributes();
        
        let SecServiceAttribute: String! = kSecAttrService as String
        let SecAccessibleAttribute: String! = kSecAttrAccessible as String
        
        attributes[SecServiceAttribute] = self.service
        attributes[SecAccessibleAttribute] = self.accessibilityAttribute()
        
        let statusCode: OSStatus = SecItemAdd(attributes, nil);
        if statusCode == 0
        {
            return true
        }
        
        return false;
    }
    
    public func update(account: Account) -> Bool
    {
        assert(account.isValid(), "Can only update a valid account in keychain")
        
        let SecServiceAttribute: String! = kSecAttrService as String
        let SecAccessibleAttribute: String! = kSecAttrAccessible as String
        
        let existing:Account? = self.accountFor(account.userName)
        if existing == nil
        {
            return false
        }
        
        let existingAttributes = existing!.attributes()
        existingAttributes[SecServiceAttribute] = self.service
        existingAttributes[SecAccessibleAttribute] = self.accessibilityAttribute()

        let statusCode: OSStatus = SecItemUpdate(existingAttributes, account.attributes())
        if statusCode != 0
        {
            return true
        }

        return false
    }
    
    public func remove(account: Account) -> Bool
    {
        let SecServiceAttribute: String! = kSecAttrService as String
        let SecAccessibleAttribute: String! = kSecAttrAccessible as String

        let attributes = account.attributes();
        attributes[SecServiceAttribute] = self.service
        attributes[SecAccessibleAttribute] = self.accessibilityAttribute()

        let statusCode: OSStatus = SecItemDelete(attributes);
        
        if (statusCode != noErr || statusCode != errSecItemNotFound){
            print("Delete \(account.userName) failed: \(statusCode) (ignored)" )
        }
    
        if statusCode != 0
        {
            return true
        }
        
        return false
    }
    
    public func accountFor(userName: String) -> Account
    {
        let GenericPasswordAttribute: String! = kSecClassGenericPassword as String
        let AccountAttribute: String! = kSecAttrAccount as String
        let ClassAttribute: String! = kSecClass as String
        let ValueDataAttribute: String! = kSecValueData as String
        let SecServiceAttribute: String! = kSecAttrService as String
        let SecAccessibleAttribute: String! = kSecAttrAccessible as String
        let ReturnDataAttribute: String! = kSecReturnData as String
        
        let attributes = [
            ClassAttribute : GenericPasswordAttribute,
            SecServiceAttribute: self.service,
            AccountAttribute: userName,
            SecAccessibleAttribute: self.accessibilityAttribute(),
            ReturnDataAttribute: kCFBooleanTrue
        ] as NSMutableDictionary
        
        attributes.removeObjectForKey(kSecValueData)
        
        var result:AnyObject?
        let statusCode: OSStatus = SecItemCopyMatching(attributes, &result);
        if statusCode == noErr
        {
            //let opaque = result as? NSData.toOpaque()
            
            var secretValue: NSString?
            let restriveData = result as? NSData
            secretValue  = NSString(data: (restriveData)!, encoding: NSUTF8StringEncoding)
            return Account(userName: userName,secret:secretValue! as String, keychain:self)
//            if let op = opaque
//            {
//                let retrievedData = Unmanaged<NSData>.fromOpaque(op).takeUnretainedValue()
//                secretValue = NSString(data:retrievedData, encoding:NSUTF8StringEncoding)
//                return Account(userName: userName, secret: secretValue! as String, keychain: self)
//            }
        }
        
        return Account(userName: "") // Should handle this better
    }
    
    // MARK: Private Methods
    // ========================================================
    // Private Methods
    // ========================================================
    internal func accessibilityAttribute() -> CFTypeRef
    {
        var typeRef: CFTypeRef
        switch self.accessibility
            {
        case .WhenUnlocked:
            typeRef = kSecAttrAccessibleWhenUnlocked
            
        case .AfterFirstUnlock:
            typeRef = kSecAttrAccessibleAfterFirstUnlock
            
        case .Always:
            typeRef = kSecAttrAccessibleAlways
            
        case .PasscodeSetThisDeviceOnly:
            if #available(iOS 8.0, *) {
                typeRef = kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
            } else {
                // Fallback on earlier versions
                typeRef = kSecAttrAccessibleAlways
            }
            
        case .WhenUnlockedThisDeviceOnly:
            typeRef = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            
        case .AfterFirstUnlockThisDeviceOnly:
            typeRef = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            
        case .AlwaysThisDeviceOnly:
            typeRef = kSecAttrAccessibleAlwaysThisDeviceOnly
        }
        
        return typeRef;
    }
}