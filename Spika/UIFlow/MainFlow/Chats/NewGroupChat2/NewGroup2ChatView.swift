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
            .overlay(alignment: .top) {
                Text("Name the group")
                    .font(.customFont(.RobotoFlexSemiBold, size: 16))
                    .foregroundStyle(Color.fromUIColor(.textPrimary))
                    .padding(.top, 70)
            }
            
            Group {
                TextField("", text: $viewModel.groupName,
                          prompt: 
                            Text(verbatim: .getStringFor(.enterGroupName))
                                .foregroundColor(Color(.textSecondary))
                )
                .font(.customFont(.RobotoFlexMedium, size: 12))
                .foregroundStyle(Color.fromUIColor(.textPrimary))
                .frame(height: 50)
                .padding(.horizontal, 24)
                .background(Color(.secondaryColor))
                .clipShape(Capsule())
                
                HStack {
                    Text("\(viewModel.selectedMembers.count) members selected")
                        .font(.customFont(.RobotoFlexSemiBold, size: 16))
                        .foregroundStyle(Color.fromUIColor(.textPrimary))
                    Spacer()
                    
                    Button {
                        viewModel.showAddMembersScreen = true
                    } label: {
                        Image(.rDplus)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.fromUIColor(.primaryColor))
                    }
                }
                
                Spacer().frame(height: 16)
                
                ScrollView {
                    VStack(spacing: 22) {
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
                                        .font(.customFont(.RobotoFlexSemiBold, size: 14))
                                        .foregroundStyle(Color(.textPrimary))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(user.telephoneNumber ?? "")
                                        .font(.customFont(.RobotoFlexMedium, size: 10))
                                        .foregroundStyle(Color(.textPrimary))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Spacer()
                                Button {
                                    viewModel.selectedMembers.removeFirstIfExist(user)
                                } label: {
                                    Image(.rDx)
                                        .tint(Color(.textPrimary))
                                        .frame(width: 24, height: 24)
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
            viewModel.getAppCoordinator()?.getSelectUsersOrGroupsView(purpose: .addToNewGroupCreationFlow(hiddenUserIds: viewModel.selectedMembers.compactMap({ $0.id })))
                .environment(\.managedObjectContext, viewModel.repository.getMainContext())
        }
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(sourceType: viewModel.selectedSource,
                        selectedImage: $viewModel.selectedImage)
        }
    }
}
