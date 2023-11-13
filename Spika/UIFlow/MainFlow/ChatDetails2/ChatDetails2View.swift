//
//  ChatDetails2View.swift
//  Spika
//
//  Created by Nikola Barbarić on 13.11.2023..
//

import SwiftUI

struct ChatDetails2View: View {
    @StateObject var viewModel: ChatDetails2ViewModel
    
    var body: some View {        
        VStack {
            ChatRoundedAvatar(url: viewModel.profilePictureUrl,
                              isGroupRoom: viewModel.room.type == .groupRoom)
            
            Text(viewModel.roomName)
                .foregroundStyle(Color(.textPrimary))
            
            if let secondLine = viewModel.bellowNameText {
                Text(secondLine)
                    .foregroundStyle(Color(.textPrimary))
            }
            
            Text(viewModel.room.type.description)
                .foregroundStyle(Color(.textPrimary))
            
            HStack(spacing: 32) {
                Button {
                    
                } label: {
                    Image(.rDphone)
                }
                
                Button {
                    viewModel.presentAddToContactsScreen()
                } label: {
                    Image(.rDaddToContacts)
                }
            }.foregroundStyle(Color(.tertiaryColor))
            
            PrimaryButton(imageResource: .rDnotes, text: .getStringFor(.notes), corners: .topCorners, usage: .withRightArrow) {
            }.padding(.horizontal, 16)
            
            PrimaryButton(imageResource: .rDpin, 
                          text: .getStringFor(.pinchat),
                          usage: .withToggle(viewModel.isRoomPinned)) {
                
            }.padding(.horizontal, 16)
            
            PrimaryButton(imageResource: .rDmute, 
                          text: .getStringFor(.mute),
                          corners: .bottomCorners,
                          usage: .withToggle(viewModel.isRoomMuted)) {
                
            }.padding(.horizontal, 16)
            
            Button(action: {
                
            }, label: {
                HStack {
                    Image(.rDblock)
                    Text(verbatim: .getStringFor(.block))
                }.foregroundStyle(Color(.warningColor))
            })
            
            Spacer()
        }
        .ignoresSafeArea()
        .modifier(SpikaBackgroundGradient())
    }
}
