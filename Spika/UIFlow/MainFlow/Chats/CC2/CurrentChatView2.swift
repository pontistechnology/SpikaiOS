//
//  CurrentChatView2.swift
//  Spika
//
//  Created by Nikola Barbarić on 27.11.2023..
//

import SwiftUI
import CoreData
import Kingfisher

struct MessagesFetcher<Content: View>: View {
    @SectionedFetchRequest var fetchRequest: SectionedFetchResults<String, MessageEntity>
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
    
    @ViewBuilder func reactionsAndStuffStack(_ message: Message) -> some View {
        HStack(alignment: .bottom) {
            if let id = message.id {
                ReactionsView2(messageId: id)
            }
            
            if message.createdAt != message.modifiedAt {
                Text("edited")
            }
            
            if message.fromUserId == viewModel.myUserId {
                Image(.rDcheckmark)
                    .resizable()
                    .frame(width: 17, height: 13)
            }
        }
        .padding(.horizontal, 16)
        .background(Color.green)
    }
    
    @ViewBuilder func circleUserImage(id: Int64, hide: Bool) -> some View {
        if hide {
            Spacer()
                .frame(width: 24, height: 24)
        } else {
            KFImage(viewModel.room.users.first(where: { $0.id == id })?.user.avatarFileId?.fullFilePathFromId())
                .placeholder { _ in
                    Image(.rDdefaultUser)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                }
                .resizable()
                .frame(width: 24, height: 24)
                .clipShape(Circle())
        }
    }
    
    @ViewBuilder func messageRow(_ el: MessageEntity,
                                 isPreviousFromSameSender: Bool,
                                 isNextFromSameSender: Bool) -> some View {
        let message = Message(messageEntity: el, fileData: nil, thumbData: nil, records: nil)
        let isMyMessage = message.fromUserId == viewModel.myUserId
        let isGroupRoom = viewModel.room.type == .groupRoom
        
//        guard !message.deleted else {
//            return Text("Deleted message")
//        }
        HStack(alignment: .bottom, spacing: 0) {
            if isMyMessage {
                Spacer()
            }
            if isGroupRoom {
                circleUserImage(id: message.fromUserId, hide: isNextFromSameSender)
            }
            VStack(alignment: .leading, spacing: 0) {
                if isGroupRoom && !isPreviousFromSameSender {
                    Text(viewModel.room.getDisplayNameFor(userId: message.fromUserId))
                }
                switch message.type {
                case .text:
                    VStack(alignment: isMyMessage ? .trailing : .leading, spacing: 4) {
                        Text(message.body?.text ?? "")
                            .padding(.top, 10)
                            .padding(.horizontal, 16)
                        
                        reactionsAndStuffStack(message)
                            .padding(.bottom, 10)
                    }
                    .background(Color(.primaryColor))
                    .modifier(RoundedCorners(corners: isMyMessage ? .allButBottomRight : .allButBottomLeft, radius: 15))

                case .image:
                    if let bodyFileId = el.bodyFileId, let id = Int64(bodyFileId) {
                        ImageView2(fileId: id)
                            .modifier(RoundedCorners(corners: isMyMessage ? .allButBottomRight : .allButBottomLeft, radius: 15))
                    }
                default:
                    Text("Unknown cell type")
            }
    }
            .frame(maxWidth: 328, alignment: isMyMessage ? .trailing : .leading)
        }.padding(.horizontal, 12).padding(.vertical, 6)
    }
    
    var body: some View {
        VStack {
            MessagesFetcher(id: viewModel.room.id) { results in
                ScrollViewReader { proxy in
                    List {
                        ForEach(results) { section in
                            Section {
                                ForEach(section) {
                                    messageRow($0,
                                               isPreviousFromSameSender: section.isPreviousElementSameSender(el: $0),
                                               isNextFromSameSender: section.isNextElementSameSender(el: $0))
                                        .id($0.id)
                                        .listRowSeparator(.hidden)
                                }
                            } header: {
                                Text(section.id)
                                    .foregroundStyle(Color(.textPrimary))
                                    .font(.largeTitle)
                            }
                            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        }
                    }
                    .listStyle(.grouped)
                    .onAppear {
                        proxy.scrollTo(results.last?.last?.id, anchor: .top)
                    }
                }
            }
            .background(.blue)
            
            TextField("", text: $viewModel.inputText, prompt: Text("message"))
                .background(.green)
        }
    }
}

extension SectionedFetchResults<String, MessageEntity>.Element {
    func isPreviousElementSameSender(el: SectionedFetchResults<String, MessageEntity>.Section.Element) -> Bool {
        guard let indexOfCurrent = firstIndex(of: el), indexOfCurrent>startIndex else { return false }
        let indexOfPrevious = index(before: indexOfCurrent)
        return self[indexOfPrevious].fromUserId == self[indexOfCurrent].fromUserId
    }

    func isNextElementSameSender(el: SectionedFetchResults<String, MessageEntity>.Section.Element) -> Bool {
        guard let indexOfCurrent = firstIndex(of: el),
                indexOfCurrent<endIndex-1 // endIndex is same as count for array
        else { return false }
        let indexOfNext = index(after: indexOfCurrent)
        return self[indexOfNext].fromUserId == self[indexOfCurrent].fromUserId
    }
    
}

struct ReactionsView2: View {
    @FetchRequest private var fetchRequest: FetchedResults<MessageRecordEntity>
    
    init(messageId: Int64) {
        // TODO: - sort
        self._fetchRequest = FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "messageId == %d AND type == %@", messageId, MessageRecordType.reaction.rawValue))
    }
    
    var body: some View {
        if let reactions = uniqueReactionsAndCount() {
            Text(reactions)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(Color(.additionalColor))
                .modifier(RoundedCorners(corners: .allButBottomLeft, radius: 15))
        }
    }
    
    func uniqueReactionsAndCount() -> String? {
        let emojis = fetchRequest.compactMap { $0.reaction }
        let maxNumberOfEmojis = 3
        guard let uniqueArray = Array(NSOrderedSet(array: emojis)) as? [String], !uniqueArray.isEmpty
        else { return nil }
        var a = ""
        _ = uniqueArray.prefix(maxNumberOfEmojis).map { a.append($0)}
        
        if emojis.count > maxNumberOfEmojis
            || (uniqueArray.count < emojis.count && emojis.count > 1) {
            a.append("\(emojis.count)")
        }
        return a
    }
}

struct ImageView2: View {
    @FetchRequest private var fetchRequest: FetchedResults<FileEntity>
    
    init(fileId: Int64) {
        self._fetchRequest = FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "id == %d", fileId))
    }
    
    var body: some View {
        if let url = fetchRequest.first?.id.fullFilePathFromId() {
            KFImage(url)
                .resizable()
                .placeholder({ _ in
                    Image(.rDdefaultUser) // TODO: - change placeholder
                        .resizable()
                        .frame(width: 300, height: 300, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                })
                .frame(width: 300, height: 300, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
}
