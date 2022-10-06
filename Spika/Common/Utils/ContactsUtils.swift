//
//  ContactsUtils.swift
//  Spika
//
//  Created by Mislav Bagovic on 29.10.2021..
//

import Contacts
import CoreTelephony
import Combine
import libPhoneNumber_iOS

class ContactsUtils {
    
    class func getContacts() -> Future<[FetchedContact], Error> {
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
                    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                    let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                    DispatchQueue.global(qos: .background).async {
                        do {
                            try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                                
                                guard let phoneUtil = NBPhoneNumberUtil.sharedInstance(), let defaultRegionCode = defaultRegionCode() else {
                                    return
                                }
                                
                                for phoneNumber in contact.phoneNumbers {
                                    
                                    do {
                                        let parsedPhoneNumber: NBPhoneNumber = try phoneUtil.parse(phoneNumber.value.stringValue, defaultRegion: defaultRegionCode)
                                        let formattedString: String = try phoneUtil.format(parsedPhoneNumber, numberFormat: .E164)
                                        
                                        contacts.append(FetchedContact(firstName: contact.givenName, lastName: contact.familyName, telephone: formattedString))
                                    }
                                    catch let error as NSError {
                                        print(error.localizedDescription)
                                    }
                                }
                            })
                        } catch let error {
                            print("Failed to enumerate contact", error)
                        }
                        promise(.success(contacts))
                    }
                } else {
                    print("access denied")
                    promise(.success([]))
                }
            }
        }
    }
    
    // Get a user's default region code
    ///
    /// - returns: A computed value for the user's current region - based on the iPhone's carrier and if not available, the device region.
    public class func defaultRegionCode() -> String? {
#if os(iOS) && !targetEnvironment(simulator) && !targetEnvironment(macCatalyst)
        if let isoCountryCode = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.values.first?.isoCountryCode {
            return isoCountryCode.uppercased()
        }
#endif
        if let countryCode = Locale.current.regionCode {
            return countryCode.uppercased()
        }
        return nil
    }
}
