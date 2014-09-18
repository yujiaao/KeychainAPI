//
//  KeychainTests.swift
//  KeychainTests
//
//  Created by Justin Williams on 9/15/14.
//  Copyright (c) 2014 Second Gear. All rights reserved.
//

import UIKit
import XCTest
import KeychainAPI

class KeychainTests: XCTestCase
{
    var keychain:Keychain
    var defaultAccount:Account

    override func setUp()
    {
        super.setUp()
        self.keychain = Keychain(service: "com.secondgear.keychainapi.tests", accessibility: Accessibility.WhenUnlocked)
        self.defaultAccount = Account(userName: "justinw@me.com", secret: "lovesecretsexgod")

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
        let account:Account = self.keychain.accountFor("justinw@me.com")

        XCTAssertNotNil(account)
        XCTAssertEqual(account.userName, "justinw@me.com")
    }

    func testUpdatingExistingAccount()
    {
        let account:Account = self.defaultAccount
        let oldPass = account.secret
        
        account.secret = "newsecret"
        let result = self.keychain.update(account)
        let refeched:Account = self.keychain.accountFor("justinw@me.com")
        
        XCTAssertTrue(result)
        XCTAssertEqual(refeched.secret!, account.secret!)
    }

    func testRemovingExistingAccount()
    {
        let newAccount:Account = Account(userName: "jdoe@keychain.io", secret: "s3kr37")
        self.keychain.add(newAccount)
        
        let result = self.keychain.remove(newAccount)
        XCTAssertTrue(result)
    }

}
