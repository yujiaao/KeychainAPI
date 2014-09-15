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
    private var accessGroup: String
    private var accessibility: Accessibility
    
    // MARK: Initializers
    // ========================================================
    // Initializers
    // ========================================================
    public init(service: String, accessibility: Accessibility)
    {
        self.service = service
        self.accessGroup = service
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
        attributes[kSecAttrService] = self.service
        attributes[kSecAttrAccessible] = self.accessibilityAttribute()
        
        let statusCode: OSStatus = SecItemAdd(attributes, nil);
        if statusCode != 0
        {
            return true
        }
        
        return false;
    }
    
    public func update(account: Account) -> Bool
    {
        assert(account.isValid(), "Can only update a valid account in keychain")
        
        let existing:Account? = self.accountFor(account.userName)
        if existing == nil
        {
            return false
        }
        
        let existingAttributes = existing!.attributes()
        existingAttributes[kSecAttrService] = self.service
        existingAttributes[kSecAttrAccessible] = self.accessibilityAttribute()

        let statusCode: OSStatus = SecItemUpdate(existingAttributes, account.attributes())
        if statusCode != 0
        {
            return true
        }

        return false
    }
    
    public func remove(account: Account) -> Bool
    {
        let attributes = account.attributes();
        attributes[kSecAttrService] = self.service
        attributes[kSecAttrAccessible] = self.accessibilityAttribute()
        
        let statusCode: OSStatus = SecItemDelete(attributes);
        if statusCode != 0
        {
            return true
        }
        
        return false
    }
    
    public func accountFor(userName: String) -> Account
    {
        let attributes = [
            kSecAttrService: self.service,
            kSecAttrAccount: userName,
            kSecAttrAccessible: self.accessibilityAttribute(),
            kSecReturnData: kCFBooleanTrue
        ]
        
        var result:Unmanaged<AnyObject>?
        let statusCode: OSStatus = SecItemCopyMatching(attributes, &result);
        if statusCode != 0
        {
            let opaque = result?.toOpaque()
            var secretValue: NSString?
            if let op = opaque?
            {
                let retrievedData = Unmanaged<NSData>.fromOpaque(op).takeUnretainedValue()
                secretValue = NSString(data:retrievedData, encoding:NSUTF8StringEncoding)
                return Account(userName: userName, secret: secretValue!, keychain: self)
            }
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
            typeRef = kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
            
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