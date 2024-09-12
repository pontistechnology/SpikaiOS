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
        ScrollView {
            ChatRoundedAvatar(url: viewModel.profilePictureUrl,
                              isGroupRoom: viewModel.detailsMode.isGroup, imageForUpload: .constant(nil))
            .onTapGesture {
                // TODO: - add change image
            }
            
            VStack(spacing: 0) {
                Spacer().frame(height: 24)
                
                nameTelephoneAndDescription()
                
                if viewModel.detailsMode.isPrivate {
                    Spacer().frame(height: 16)
                    chatAndContactIcons()
                }
                
                Spacer().frame(height: 24)
                menuButtons()
                    .modifier(RoundedCorners(corners: .allCorners, radius: 15))
                
                if viewModel.detailsMode.isPrivate {
                    Spacer().frame(height: 16)
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            Image(.rDblock)
                            Text(verbatim: .getStringFor(.block))
                        }.foregroundStyle(Color(.warningColor))
                    })
                } else if let room = viewModel.room {
                    Spacer().frame(height: 16)
                    memberCountAndPlus(isAdmin: viewModel.isMyUserAdmin)
                        .padding(.vertical, 19)
                    VStack(spacing: 26) {
                        ForEach(room.users) { roomUser in
                            Button {
                                viewModel.clickOnMemberRow(roomUser: roomUser)
                            } label: {
                                memberRowView(user: roomUser.user,
                                              isAdmin: roomUser.isAdmin ?? false,
                                              isMyUser: roomUser.userId == viewModel.myUserId,
                                              showRemove: viewModel.isMyUserAdmin)
                            }
                            
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .ignoresSafeArea()
        .modifier(SpikaBackgroundGradient())
        .sheet(isPresented: $viewModel.showAddMembersScreen, content: {
            viewModel.getAppCoordinator()?.getSelectUsersOrGroupsView(purpose: .addToExistingGroup(hiddenUserIds: viewModel.room?.users.compactMap({ $0.userId }) ?? []))
                .environment(\.managedObjectContext, viewModel.repository.getMainContext())
        })
    }
}

extension ChatDetails2View {
    private func chatAndContactIcons() -> some View {
        HStack(spacing: 32) {
            Button {
                viewModel.showChatScreen()
            } label: {
                Image(.rDchatBubble)
            }
            Button {
                viewModel.showPhoneNumberOptions()
            } label: {
                Image(.rDaddToContacts)
            }
        }.foregroundStyle(Color(.tertiaryColor))
    }
    
    private func nameTelephoneAndDescription() -> some View {
        return Group {
            Text(viewModel.roomName)
                .font(.customFont(.RobotoFlexSemiBold, size: 24))
            
            if let secondLine = viewModel.bellowNameText {
                Text(secondLine)
                    .font(.customFont(.RobotoFlexMedium, size: 12))
            }
            
            Text(viewModel.detailsMode.description)
                .font(.customFont(.RobotoFlexMedium, size: 12))
        }
        .foregroundStyle(Color(.textPrimary))
    }
    
    private func menuButtons() -> some View {
        VStack(spacing: 8) {
            PrimaryButton(imageResource: .rDMediaLinksDocs, text: .getStringFor(.mediaLinksDocs), usage: .withRightArrow) {
                // TODO: - implement shared media links docs
            }
            
            PrimaryButton(imageResource: .rDnotes, text: .getStringFor(.notes), usage: .withRightArrow) {
                viewModel.presentAllNotesScreen()
            }
            
            PrimaryButton(imageResource: .rDpin,
                          text: .getStringFor(.pinchat),
                          usage: .withToggle(viewModel.isRoomPinned)) {
                viewModel.isRoomPinned.wrappedValue.toggle()
            }
            
            PrimaryButton(imageResource: .rDmute,
                          text: .getStringFor(.mute),
                          usage: .withToggle(viewModel.isRoomMuted)) {
                viewModel.isRoomMuted.wrappedValue.toggle()
            }
            
            if viewModel.detailsMode.isGroup {
                PrimaryButton(imageResource: .rDxInCircle, text: .getStringFor(.exitGroup), backgroundColor: .warningColor, usage: .onlyTitle) {
                    
                }
                
                // TODO: - add DELETE CHAT LOGIC
//                PrimaryButton(imageResource: .rDdeleteBin, text: .getStringFor(.deleteChat), corners: .bottomCorners, backgroundColor: .warningColor, usage: .onlyTitle) {
//
//                }
            }
            
        }
    }
    
    private func memberRowView(user: User, 
                               isAdmin: Bool = false,
                               isMyUser: Bool = false,
                               showRemove: Bool = false) -> some View {
        return HStack(spacing: 16) {
            AsyncImage(url: user.avatarFileId?.fullFilePathFromId()) {
                phase in
                if let image = phase.image {
                    image
                        .resizable()
                } else {
                    Image(.rDdefaultUser)
                        .resizable()
                }
            }
            .frame(width: 42, height: 42)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(isMyUser ? .getStringFor(.you) : user.getDisplayName())
                    .font(.customFont(.RobotoFlexSemiBold, size: 14))
                Text(user.telephoneNumber ?? "")
                    .font(.customFont(.RobotoFlexMedium, size: 10))
            }
            Spacer()
            if isAdmin {
                Text(verbatim: .getStringFor(.admin))
                    .font(.customFont(.RobotoFlexSemiBold, size: 14))
            } else if showRemove && !isMyUser {
                Button(action: {
                    viewModel.removeUsersFromGroup(user: user)
                }, label: {
                    Image(.rDx)
                })
            }
        }.foregroundStyle(Color(.textPrimary))
    }
    
    private func memberCountAndPlus(isAdmin: Bool) -> some View {
        return HStack {
            Text("\(viewModel.room?.users.count ?? 0)" + " " +  .getStringFor(.members))
                .font(.customFont(.RobotoFlexSemiBold, size: 20))
            Spacer()
            if isAdmin {
                Button {
                    viewModel.showAddMembersScreen = true
                } label: {
                    Image(.rDplus)
                }
            }
        }.foregroundStyle(Color(.textPrimary))
    }
}
