//
//  CurrentChatView2.swift
//  Spika
//
//  Created by Nikola Barbarić on 27.11.2023..
//

import SwiftUI
import CoreData
import Kingfisher

struct TTTTTT<Content: View>: View {
    @SectionedFetchRequest<String, MessageEntity>(
        sectionIdentifier: \.sectionName,
        sortDescriptors: CurrentChatViewModel2.sortD
    ) var fetchRequest
    let content: (SectionedFetchResults<String, MessageEntity>) -> Content
    
    init(id: Int64,
         @ViewBuilder content: @escaping (SectionedFetchResults<String, MessageEntity>) -> Content) {
        _fetchRequest = SectionedFetchRequest(sectionIdentifier: \.sectionName, sortDescriptors: CurrentChatViewModel2.sortD, predicate: NSPredicate(format: "roomId == %d", id))
        self.content = content
    }
    
    var body: some View {
        content(fetchRequest)
    }
}

struct CurrentChatView2: View {
    
    @StateObject var viewModel: CurrentChatViewModel2
        
    var body: some View {
        TTTTTT(id: viewModel.room.id) { results in
            List {
                ForEach(results) { section in
                    Section {
                        ForEach(section) { element in
                            Group {
                                VStack {
                                    Text(element.bodyText ?? "nila")
                                    ReactionsView2(messageId: element.id)
                                    if let fileId = element.bodyFileId {
                                        ImageView2(fileId: fileId)
                                    }
                                }
                            }
                        }
                    } header: {
                        // TODO: - make parameter
                        Text(section.id)
                            .foregroundStyle(Color(.textPrimary))
                            .font(.largeTitle)
                    }
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
            }
            .listStyle(.grouped)
        }
    }
}

struct ReactionsView2: View {
    @FetchRequest private var fetchRequest: FetchedResults<MessageRecordEntity>
    
    init(messageId: String?) {
        var id = Int64(messageId ?? "failIsOk") ?? 0
        self._fetchRequest = FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "messageId == %d AND type == %@", id, MessageRecordType.reaction.rawValue))
    }
    
    var body: some View {
        ForEach(fetchRequest) { aa in
            Text(aa.reaction ?? "missing")
        }
    }
}

struct ImageView2: View {
    @FetchRequest private var fetchRequest: FetchedResults<FileEntity>
    
    init(fileId: String) {
        var id = Int64(fileId ?? "failIsOk") ?? 0
        self._fetchRequest = FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "id == %d", id))
    }
    
    var body: some View {
        if let url = fetchRequest.first?.id.fullFilePathFromId() {
            KFImage(url)
                .resizable()
                .frame(width: 300, height: 300, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        } else {
            Image(.rDdefaultUser)
                .resizable()
                .frame(width: 300, height: 300, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
}
