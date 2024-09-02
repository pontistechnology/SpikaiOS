//
//  DatabaseService+DeviceContacts.swift
//  Spika
//
//  Created by Vedran Vugrin on 22.05.2023..
//

import Combine
import Contacts
import CoreTelephony
import PhoneNumberKit
import ContactsChangeNotifier

class PhoneNumberParser {
    
    private let phoneNumberKit = PhoneNumberUtility()
    
    private let contactStore = CNContactStore()
    
    let contactStoreChanged = PassthroughSubject<ContactStoreChanged,Never>()
    
    private var contactsChangeNotifier: ContactsChangeNotifier?
    
    init() {
        self.setupContactsObserver()
    }
    
    private func setupContactsObserver() {
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        let request = CNChangeHistoryFetchRequest()
        request.additionalContactKeyDescriptors = keys as [CNKeyDescriptor]
        
        contactsChangeNotifier = try? ContactsChangeNotifier(
            store: self.contactStore,
            fetchRequest: request)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contactStoreChanged(notification: )),
                                               name: ContactsChangeNotifier.didChangeNotification,
                                               object: nil)
    }
    
    public func parse(_ numberStrings: [String]) -> [String] {
        return self.phoneNumberKit.parse(numberStrings).map {  self.phoneNumberKit.format($0, toType: .e164, withPrefix: true) }
    }
    
    @objc func contactStoreChanged(notification: Notification) {
        for event in notification.contactsChangeEvents ?? [] {
            switch event {
            case let addEvent as CNChangeHistoryAddContactEvent:
                self.contactStoreChanged.send(.contactAdded(addEvent.contact))
//                print(addEvent.contact)
            case let updateEvent as CNChangeHistoryUpdateContactEvent:
                self.contactStoreChanged.send(.contactModified(updateEvent.contact))
//                print(updateEvent.contact)
            case let deleteEvent as CNChangeHistoryDeleteContactEvent:
                self.contactStoreChanged.send(.contactDeleted(deleteEvent.contactIdentifier))
//                print(deleteEvent.contactIdentifier)
            default:
                break
            }
        }
    }
    
}
