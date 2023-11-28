//
//  PreviewFile.swift
//  Spika
//
//  Created by Nikola Barbarić on 28.11.2023..
//

import SwiftUI

struct PreviewFile: View {
    @ViewBuilder func reactionsAndStuffStack(_ message: Message, isMyMessage: Bool) -> some View {
        HStack {
            if let id = message.id {
                ReactionsView2(messageId: message.id!)
            }
            
            if message.createdAt != message.modifiedAt {
                Text("edited")
            }
            
            if isMyMessage {
                Image(.rDcheckmark)
                    .resizable()
                    .frame(width: 17, height: 13)
            }
        }
        .padding(.horizontal, 16)
    }
    
    let message = Message(createdAt: 4, modifiedAt: 41, fromUserId: 4, roomId: 4, id: 4, localId: "4", totalUserCount: 4, deliveredCount: 4, seenCount: 4, replyId: nil, deleted: false, type: .text, body: MessageBody(text: "jozo", file: nil, thumb: nil), records: nil)
    let isMyMessage = true
    
    var body: some View {
        HStack {
            if isMyMessage {
                Spacer()
            }
            if message.type == .text {
                VStack(alignment: isMyMessage ? .trailing : .leading, spacing: 4) {
                    Text(message.body?.text ?? "")
                        .padding(.top, 10)
                        .padding(.horizontal, 16)
                    
                    reactionsAndStuffStack(message, isMyMessage: isMyMessage)
                        .padding(.bottom, 10)
                }
                .background(Color(.primaryColor))
                .modifier(RoundedCorners(corners: isMyMessage ? .allButBottomRight : .allButBottomLeft, radius: 15))
                .frame(maxWidth: 328, alignment: isMyMessage ? .trailing : .leading)
            } else {
                Text("Unknown cell type")
            }
        }.padding(.horizontal, 12).padding(.vertical, 6)
    }
}

struct PreviewFile_Previews: PreviewProvider {
    static var previews: some View {
        PreviewFile()
            .background(Color.red)
    }
}
