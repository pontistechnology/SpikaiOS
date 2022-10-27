//
//  ContactsUtils.swift
//  Spika
//
//  Created by Mislav Bagovic on 29.10.2021..
//

import Contacts
import CoreTelephony
import Combine
import PhoneNumberKit

class ContactsUtils {
    
    let phoneNumberKit = PhoneNumberKit()
    
    func getContacts() -> Future<[FetchedContact], Error> {
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
//                        let timer = ParkBenchTimer()
                        do {
                            try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                                let fetchedContacts = self.phoneNumberKit.parse(contact.phoneNumbers.map { $0.value.stringValue })
                                    .map {  self.phoneNumberKit.format($0, toType: .e164, withPrefix: true) }
                                    .map { FetchedContact(firstName: contact.givenName, lastName: contact.familyName, telephone: $0) }
                                
                                contacts.append(contentsOf: fetchedContacts)
                            })
                        } catch let error {
                            print("Failed to enumerate contact", error)
                        }
//                        print("Contact Pull finished: \(contacts.count), duration: \(timer.stop())")
                        promise(.success(contacts))
                    }
                } else {
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
