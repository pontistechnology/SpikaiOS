//
//  MessageView.swift
//  Spika
//
//  Created by Nikola Barbarić on 21.10.2023..
//

import SwiftUI

struct MessageView: View {
    let message: Message
    var body: some View {
        if #available(iOS 16.0, *) {
            switch message.type {
            case .text:
                Text(message.body?.text ?? "")
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(.pink)
                    .foregroundStyle(.white)
                    .clipShape(.rect(topLeadingRadius: 0, bottomLeadingRadius: 15, bottomTrailingRadius: 0, topTrailingRadius: 15, style: .continuous))
            case .image:
                Text("a")
            case .video:
                Text("a")
            case .file:
                Text("a")
            case .audio:
                Text("a")
            case .unknown:
                EmptyView()
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

#Preview {
    MessageView(message: Message(createdAt: 3, modifiedAt: 4, fromUserId: 43, roomId: 3, id: 23, localId: "aa", totalUserCount: 5, deliveredCount: 4, seenCount: 3, replyId: nil, deleted: false, type: .text, body: MessageBody(text: "Kaze da moze sada...", file: nil, thumb: nil), records: nil))
}
