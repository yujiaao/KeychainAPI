//
//  KeychainTests.swift
//  KeychainTests
//
//  Created by Justin Williams on 9/15/14.
//  Copyright (c) 2014 Second Gear. All rights reserved.
//

import UIKit
import XCTest
@testable import KeychainAPI

class KeychainTests: XCTestCase
{
    let defaultUserName = "justinw@me.com"
    var keychain:Keychain = Keychain(service: "com.secondgear.keychainapi.tests", accessibility: Accessibility.WhenUnlocked)
    var defaultAccount:Account = Account(userName:"", secret: "lovesecretsexgod")
    
    
    
    override func setUp()
    {
        super.setUp()
        print("========do setUp=========")

        self.keychain = Keychain(service: "com.secondgear.keychainapi.tests", accessibility: Accessibility.WhenUnlocked)
        self.defaultAccount = Account(userName: defaultUserName, secret: "lovesecretsexgod")
        self.keychain.add(self.defaultAccount)
    }
    
    override func tearDown()
    {
        self.keychain.remove(self.defaultAccount)
        super.tearDown()
    }
    
    func testCreatingNewAccount()
    {
        let newAccount:Account = Account(userName: "jdoe@keychain.io", secret: "s3kr37")
        let result = self.keychain.add(newAccount)
        
        XCTAssertNotNil(newAccount)
        XCTAssertTrue(result)
        
        self.keychain.remove(newAccount)
    }

    func testFetchingExistingAccount()
    {
        let account:Account = self.keychain.accountFor(defaultUserName)

        XCTAssertNotNil(account)
        XCTAssertEqual(account.userName, defaultUserName)
    }

    func testUpdatingExistingAccount()
    {
        let account:Account = self.defaultAccount
        account.secret = "newsecret"
        
        let result = self.keychain.update(account)
        let refeched:Account = self.keychain.accountFor(defaultUserName)
        
        XCTAssertTrue(result)
        XCTAssertEqual(refeched.secret, account.secret)
    }

    func testRemovingExistingAccount()
    {
        let newAccount:Account = Account(userName: "jdoe@keychain.io", secret: "s3kr37")
        let res = self.keychain.add(newAccount)
        XCTAssertTrue(res)
        
        let result = self.keychain.remove(newAccount)
        XCTAssertTrue(result)
    }

}
