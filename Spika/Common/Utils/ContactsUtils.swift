//
//  ContactsUtils.swift
//  Spika
//
//  Created by Mislav Bagovic on 29.10.2021..
//

import Contacts
import CoreTelephony
import PhoneNumberKit
import Combine

class ContactsUtils {

    static let phoneNumberKit = PhoneNumberKit()
    
    init() {
//        let networkInfo = CTTelephonyNetworkInfo()
////        let phoneNumberKit = PhoneNumberKit()
//        if let carrier = networkInfo.subscriberCellularProvider {
//            print("country code is: " + carrier.mobileCountryCode!)
//            //will return the actual country code
//            print("ISO country code is: " + carrier.isoCountryCode!)
//            print("country code is: " + carrier.mobileNetworkCode!)
//            print("country code is: " + carrier.mobileCountryCode!)
//
////            Countries.
//        }
//
//
//        let pnk = PhoneNumberKit()
//
//        print("REAL COUNTRY CODE IS: " + PhoneNumberKit.defaultRegionCode())
//
//        let prefix = pnk.countryCode(for: PhoneNumberKit.defaultRegionCode())
//
//        if let prefix = prefix {
//            print("THE REAL COUNTRY CODE IS: " + String(prefix));
//        }
        
        print("THE REAL COUNTRY CODE IS: " + (ContactsUtils.getCountyCode() ?? "NULL"));
//        ContactsUtils.getContacts()
    }
    
    class func getCountyCode() -> String? {
        if let code = phoneNumberKit.countryCode(for: PhoneNumberKit.defaultRegionCode()) {
            print("COUNTRY CODE IS: " + String(code));
            return String(code)
        } else {
            return nil
        }
    }
    
    class func getContacts() -> Future<[String], Error> {
        return Future() { promise in
            let store = CNContactStore()
            var contacts = [FetchedContact]()
            CNContactStore().requestAccess(for: .contacts) { granted, error in
                if let error = error {
                    print("failed to request access", error)
                    promise(.failure(error))
                    return
                }
                
                if granted {
                    // 2.
                    var phoneNumbers = [String]()
                    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                    let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                    do {
                        // 3.
                        try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                            contacts.append(FetchedContact(firstName: contact.givenName, lastName: contact.familyName, telephone: contact.phoneNumbers.first?.value.stringValue ?? ""))
                        })
                    } catch let error {
                        print("Failed to enumerate contact", error)
                    }
                    for contact in contacts {
                        print(contact.telephone + " " + contact.firstName + " " + contact.lastName)
                        do {
                            let phoneNumber = try phoneNumberKit.parse(contact.telephone)
                            print(phoneNumberKit.format(phoneNumber, toType: .e164))
                            phoneNumbers.append(phoneNumberKit.format(phoneNumber, toType: .e164))
                        } catch let error {
                            print("Failed to parse telephone number", error)
                        }
                    }
                    promise(.success(phoneNumbers))
                } else {
                    print("access denied")
                    promise(.success([]))
                }
            }
        }
    }
}

struct FetchedContact {
    var firstName: String
    var lastName: String
    var telephone: String
}
