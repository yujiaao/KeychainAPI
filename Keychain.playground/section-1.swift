// Playground - noun: a place where people can play

import KeychainAPI

let keychain: Keychain = Keychain(service: "com.secondgear.myapp", accessibility: Accessibility.WhenUnlocked)
let userAccount = Account(userName: "justinw@me.com", secret: "lovesecretsexgod")
keychain.add(userAccount)

let fetchedAccount:Account = keychain.accountFor("justinw@me.com")
fetchedAccount.secret = "newpassword"
keychain.update(fetchedAccount)

let fetAccount = keychain.accountFor("justinw@me.com");

keychain.remove(fetchedAccount)
