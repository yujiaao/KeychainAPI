//
//  Account.swift
//  Keychain
//
//  Created by Justin Williams on 9/15/14.
//  Copyright (c) 2014 Second Gear. All rights reserved.
//

import Foundation
import Security

public class Account
{
    private var keychain : Keychain?
    public var userName : String
    public var secret: String
    
    // MARK: Initializers
    // ========================================================
    // Initializers
    // ========================================================
    public init(userName: String, secret: String, keychain: Keychain)
    {
        self.userName = userName
        self.secret = secret
        self.keychain = keychain
    }

    public init(userName: String, secret: String)
    {
        self.userName = userName
        self.secret = secret
    }
    
    public init(userName: String)
    {
        self.userName = userName
        self.secret = ""
    }
    
    // MARK: Public Methods
    // ========================================================
    // Public Methods
    // ========================================================
    public func isValid() -> Bool
    {
        return !self.userName.isEmpty
    }
    
    public func attributes() -> NSMutableDictionary
    {
        let passwordData: NSData = self.secret.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var attributes = [
            kSecClass : kSecClassInternetPassword,
            kSecAttrAccount : userName,
            kSecValueData : passwordData
        ] as NSMutableDictionary
        
        // Access groups aren't supported on iOS Simualtor still? What year is this?
        #if arch(i386) && os(iOS)
            if !accessGroup?.isEmpty?
            {
            attributes[kSecAttrAccessGroup] = accessGroup
            }
        #endif
        
        return attributes;
    }
}