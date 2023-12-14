//
//  NewChatView.swift
//  Spika
//
//  Created by Nikola Barbarić on 23.11.2023..
//

import SwiftUI
import Kingfisher

struct NewGroup2ChatView: View {
    @StateObject var viewModel: NewGroup2ChatViewModel
    var body: some View {
        VStack {
            ChatRoundedAvatar(url: viewModel.url,
                              isGroupRoom: true,
                              imageForUpload: $viewModel.selectedImage)
            .modifier(UploadProgressModifier(isShowing: viewModel.selectedImage != nil))
            .allowsHitTesting(viewModel.selectedImage == nil)
            .onTapGesture {
                viewModel.showChangeImageActionSheet()
            }
            
            Group {
                TextField("", text: $viewModel.groupName,
                          prompt: Text(verbatim: .getStringFor(.groupName))
                .foregroundColor(Color(.textSecondary)))
                .frame(height: 50)
                .padding(.horizontal, 24)
                .background(Color(.secondaryColor))
                .clipShape(Capsule())
                
                HStack {
                    Text("\(viewModel.selectedMembers.count) members selected")
                    Spacer()
                    
                    Button {
                        viewModel.showAddMembersScreen = true
                    } label: {
                        Image(.rDplus)
                    }
                }
                
                ScrollView {
                    VStack {
                        ForEach(viewModel.selectedMembers) { user in
                            HStack(spacing: 16) {
                                KFImage(user.avatarFileId?.fullFilePathFromId())
                                    .placeholder { _ in
                                        Image(.rDdefaultUser)
                                            .resizable()
                                    }
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 52, height: 52)
                                
                                VStack(spacing: 0) {
                                    Text(user.getDisplayName())
                                        .foregroundStyle(Color(.textPrimary))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(user.telephoneNumber ?? "")
                                        .foregroundStyle(Color(.textPrimary))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Spacer()
                                Button {
                                    viewModel.selectedMembers.removeFirstIfExist(user)
                                } label: {
                                    Image(.rDx)
                                        .tint(Color(.textPrimary))
                                }
                            }
                            
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .ignoresSafeArea()
        .overlay(alignment: .bottomTrailing) {
            if !viewModel.selectedMembers.isEmpty && !viewModel.groupName.isEmpty {
                Button {
                    viewModel.createGroup()
                } label: {
                    Image(.rDcheckmark)
                        .resizable()
                        .padding()
                        .frame(width: 52, height: 52)
                        .tint(Color(.textPrimary))
                        .background(Color(.primaryColor).clipShape(Circle()))
                }
                .padding()
            }
        }
        .modifier(SpikaBackgroundGradient())
        .sheet(isPresented: $viewModel.showAddMembersScreen) {
            SelectUsersView(selectedUsers: $viewModel.selectedMembers)
                .environment(\.managedObjectContext, viewModel.repository.getMainContext())
        }
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(sourceType: viewModel.selectedSource,
                        selectedImage: $viewModel.selectedImage)
        }
    }
}
