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
            
            VStack {
                
                nameTelephoneAndDescription()
                
                if viewModel.detailsMode.isPrivate {
                    chatAndContactIcons()
                }
                
                menuButtons()
                
                if viewModel.detailsMode.isPrivate {
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            Image(.rDblock)
                            Text(verbatim: .getStringFor(.block))
                        }.foregroundStyle(Color(.warningColor))
                    })
                } else if let room = viewModel.room {
                    memberCountAndPlus(isAdmin: viewModel.isMyUserAdmin)
                        .padding(.vertical, 12)
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
            
            if let secondLine = viewModel.bellowNameText {
                Text(secondLine)
            }
            
            Text(viewModel.detailsMode.description)
        }
        .foregroundStyle(Color(.textPrimary))
    }
    
    private func menuButtons() -> some View {
        Group {
            PrimaryButton(imageResource: .rDnotes, text: .getStringFor(.notes), corners: .topCorners, usage: .withRightArrow) {
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
            }
            
            PrimaryButton(imageResource: .rDdeleteBin, text: .getStringFor(.deleteChat), corners: .bottomCorners, backgroundColor: .warningColor, usage: .onlyTitle) {
                
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
            
            VStack(alignment: .leading) {
                Text(isMyUser ? .getStringFor(.you) : user.getDisplayName())
                Text(user.telephoneNumber ?? "")
            }
            Spacer()
            if isAdmin {
                Text(verbatim: .getStringFor(.admin))
            } else if showRemove {
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
