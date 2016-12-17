//
//  Contact.swift
//  SmartDialer
//
//  Created by Mihai Costiug on 03/12/2016.
//  Copyright © 2016 Mihai Costiug. All rights reserved.
//

import Contacts

class Contact: NSObject {
    private(set) var givenName: String
    private(set) var middleName: String
    private(set) var familyName: String
    private(set) var nickname: String
    
    private(set) var phoneNumbers: [String]
    
    var displayName: String {
        get {
            let names = [self.givenName, self.middleName, self.familyName]
            var finalName = ""
            
            for name in names {
                if name.characters.count > 0 {
                    finalName += "\(name) "
                }
            }
            
            if self.nickname.characters.count > 0 {
                finalName += "\"\(self.nickname)\""
            } else {
                finalName.characters.removeLast()   //last character is a white space
            }
            
            return finalName
        }
    }
    
    init(fromCNContact cnContact: CNContact) {
        self.givenName = cnContact.givenName
        self.middleName = cnContact.middleName
        self.familyName = cnContact.familyName
        self.nickname = cnContact.nickname
        
        self.phoneNumbers = []
        
        for label in cnContact.phoneNumbers {
            let number = label.value.stringValue
            
            if number.characters.count > 0 {
                self.phoneNumbers.append(number)
            }
        }
        
        super.init()
    }    
}
