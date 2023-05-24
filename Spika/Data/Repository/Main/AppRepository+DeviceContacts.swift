//
//  AppRepository+DeviceContacts.swift
//  Spika
//
//  Created by Vedran Vugrin on 23.05.2023..
//

import UIKit
import Combine
import Contacts
import CoreTelephony

enum ContactStoreChanged {
    case contactAdded(CNContact)
    case contactModified(CNContact)
    case contactDeleted(String)
    case userInitiated
}

extension AppRepository {
    
    func syncContacts() {
        self.manualContactTrigger?.send(Void())
    }
    
    func setupContactSync() {
        // 1. Instantiating manual trigger if none
        if let _ = manualContactTrigger { return }
        manualContactTrigger = PassthroughSubject()
        
        // 2. Two triggers, manual pulls all device contacts, contacts changed pulls only modified / added contacts
        let manualContact = PassthroughSubject<[FetchedContact],Error>()
        let contactsChanged = PassthroughSubject<[FetchedContact],Error>()
        
        manualContactTrigger!.flatMap { _ in self.acces() }
                    .filter { $0 }
                    .flatMap { _ in self.getPhoneContacts() }
                    .compactMap { $0.fetchedContacts }
                    .subscribe(manualContact)
                    .store(in: &subs)
        
        
        self.phoneNumberParser.contactStoreChanged
            .compactMap { update -> CNContact? in
                switch update {
                case .contactAdded(let contact): return contact
                case .contactModified(let contact): return contact
                case .contactDeleted(_): return nil
                default: return nil
                }
            }
            .map { contact in
                return self.phoneNumberParser.parse(contact.phoneNumbers.map { $0.value.stringValue })
                    .map { FetchedContact(firstName: contact.givenName, lastName: contact.familyName, telephone: $0) }
            }.subscribe(contactsChanged)
            .store(in: &subs)
        
        // 3. Combined stream posts all contact hashes, receives response from server that is saved in local Database
        manualContact.merge(with: contactsChanged)
            .flatMap { contacts in
                let phoneHashes = contacts.map { $0.telephone.getSHA256() }
                return self.postContacts(hashes: phoneHashes)
            }
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] response in
                guard let users = response.data?.list else { return }
                _ = self?.saveUsers(users)
            })
            .store(in: &subs)

        // On App start all contacts are synced once
        self.manualContactTrigger?.send(Void())
    }
    
    func getPhoneContacts() -> Future<ContactFetchResult, Error> {
        return Future() { promise in
            let store = CNContactStore()
            var contacts = [FetchedContact]()
            CNContactStore().requestAccess(for: .contacts) { granted, error in
                if let error = error {
                    print("failed to request access", error)
                    promise(.success(ContactFetchResult(error: error)))
                    return
                }
                
                if granted {
                    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                    let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                    DispatchQueue.global(qos: .background).async {
//                        let timer = ParkBenchTimer()
                        do {
                            try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                                let fetchedContacts = self.phoneNumberParser.parse(contact.phoneNumbers.map { $0.value.stringValue })
                                    .map { FetchedContact(firstName: contact.givenName, lastName: contact.familyName, telephone: $0) }
                                
                                contacts.append(contentsOf: fetchedContacts)
                            })
                        } catch let error {
                            print("Failed to enumerate contact", error)
                        }
//                        print("Contact Pull finished: \(contacts.count), duration: \(timer.stop())")
                        promise(.success(ContactFetchResult(fetchedContacts: contacts)))
                    }
                } else {
                    promise(.success(ContactFetchResult()))
                }
            }
        }
    }
    
    private func acces() -> Future<Bool,Never> {
        return Future { promise in
            CNContactStore().requestAccess(for: .contacts) { granted, error in
                if let _ = error {
                    promise(.success(false))
                } else {
                    promise(.success(true))
                }
            }
        }
    }
    
}
