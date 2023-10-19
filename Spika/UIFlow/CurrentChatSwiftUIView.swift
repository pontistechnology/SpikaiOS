//
//  CurrentChatSwiftUIView.swift
//  Spika
//
//  Created by Nikola Barbarić on 20.10.2023..
//

import SwiftUI
import CoreData

class DataController: ObservableObject {
    let container = CoreDataStack().persistentContainer

    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}

struct CurrentChatSwiftUIView: View {
    @FetchRequest(sortDescriptors: []) var messages: FetchedResults<MessageEntity>
    
    var body: some View {
        ScrollViewReader { proxy in
            List(messages, id: \.id) { message in
                Text(message.bodyText ?? "jozararao")
                    .id(message.id)
                    .onTapGesture {
                        guard let id = messages.first?.id else { return }
                        proxy.scrollTo(id)
                    }
            }
        }
    }
}

#Preview {
    CurrentChatSwiftUIView()
}
