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
    
    func syncContacts(force: Bool?) {
        // Setup the Rx stream at app start
        guard let _ = manualContactTrigger else {
            self.setupContactSync()
            self.manualContactTrigger?.send(Void())
            return
        }
        // If force sync - sync immediately, if not check timestamp if older than 24h
        if force ?? false {
            self.manualContactTrigger?.send(Void())
        } else if !self.contactsLastSynced.isInToday {
            self.manualContactTrigger?.send(Void())
        }
    }
    
    private func setupContactSync() {
        class PhoneNumberPage {
            let hashes: [String]
            let lastPage: Bool
            init(hashes: [String], lastPage: Bool) {
                self.hashes = hashes
                self.lastPage = lastPage
            }
        }
        
        // 1. Instantiating manual trigger if none
        if let manualContactTrigger { return }
        manualContactTrigger = PassthroughSubject()
        
        // 2. Two triggers, manual pulls all device contacts, contacts changed pulls only modified / added contacts
        let manualContact = PassthroughSubject<[FetchedContact],Error>()
        let contactsChanged = PassthroughSubject<[FetchedContact],Error>()
        
        manualContactTrigger?.flatMap { [unowned self] _ in self.access() }
                    .filter { $0 }
                    .flatMap { [unowned self] _ in self.getPhoneContacts() }
                    .compactMap { $0.fetchedContacts }
                    .subscribe(manualContact)
                    .store(in: &subs)
        
        
        self.phoneNumberParser.contactStoreChanged
            .flatMap { [unowned self] _ in self.getPhoneContacts() }
            .compactMap { $0.fetchedContacts }
            .subscribe(contactsChanged)
            .store(in: &subs)
        
        // 3. Combined stream posts all contact hashes, receives response from server and saves in local Database
        let syncContacts = manualContact.merge(with: contactsChanged)
        syncContacts
            .flatMap { contacts -> AnyPublisher<PhoneNumberPage,Never> in
                let phoneHashes = contacts.map { $0.telephone.getSHA256() }.chunked(into: 40)
                let objects = phoneHashes.enumerated().map { element in
                    PhoneNumberPage(hashes: element.element, lastPage: element.offset == (phoneHashes.count - 1))
                }
                return Publishers.Sequence(sequence: objects ).eraseToAnyPublisher()
            }
            .buffer(size: .max, prefetch: .byRequest, whenFull: .dropNewest)
            .flatMap(maxPublishers: .max(1), { [unowned self] phoneHashes -> AnyPublisher<ContactsResponseModel, Error> in
                print("Sync number of contacts: \(phoneHashes.hashes.count) last page: \(phoneHashes.lastPage)")
                return self.postContacts(hashes: phoneHashes.hashes, lastPage: phoneHashes.lastPage)
            })
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] response in
                guard let users = response.data?.list else { return }
                print("Sync received response: \(users.first?.displayName ?? "")")
                _ = self?.saveUsers(users)
                self?.contactsLastSynced = Date()
            })
            .store(in: &subs)
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
    
    private func access() -> Future<Bool,Never> {
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
