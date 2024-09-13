//
//  NewPrivateChatView.swift
//  Spika
//
//  Created by Nikola Barbarić on 12.09.2024..
//

import SwiftUI
import Kingfisher

struct NewPrivateChatView: View {
    @Environment(\.managedObjectContext) var context
    @StateObject var viewModel: NewPrivateChatViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                viewModel.getAppCoordinator()?.popTopViewController()
                viewModel.getAppCoordinator()?.presentCreateNewGroup2ChatScreen()
            } label: {
                Text("New group chat")
                    .font(.customFont(.RobotoFlexSemiBold, size: 14))
                    .foregroundStyle(Color(.tertiaryColor))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.vertical, 12)

            TextField("", text: $viewModel.searchTerm, 
                      prompt: Text(verbatim: .getStringFor(.search))
                .foregroundColor(Color.fromUIColor(.textSecondary)))
                .frame(height: 38)
                .padding(.horizontal, 12)
                .background(Color(.thirdAdditionalColor))
                .clipShape(Capsule())
                .foregroundStyle(Color(UIColor.textPrimary))
            
            ListWithPredicate(sI: \.sectionName,
                              sD: viewModel.usersSortDescriptor,
                              p: viewModel.usersPredicate) { (userEntity: UserEntity) in
                memberRow(.user(userEntity))
                    .listRowBackground(Color(.clear))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
//        .background(Color(.secondaryColor))
        .modifier(SpikaBackgroundGradient())
    }
    
    private func memberRow(_ thing: SelectedUserOrGroup) -> some View {
        Button {
            guard let userId = thing.user?.id else { return }
            viewModel.actionPublisher?.send(.openRoomWithUser(userId: userId))
            viewModel.getAppCoordinator()?.popTopViewController()
        } label: {
            HStack(spacing: 16) {
                KFImage(thing.avatarURL)
                    .startLoadingBeforeViewAppear()
                    .placeholder { _ in
                        Image(thing.placeholderImage)
                            .resizable()
                    }
                    .resizable()
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())
                
                VStack {
                    Text(thing.displayName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.customFont(.RobotoFlexSemiBold, size: 14))
                    Text(thing.description ?? "-")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.customFont(.RobotoFlexMedium, size: 10))
                }.foregroundStyle(Color(.textPrimary))
                
                Spacer()
            }
            .padding(.vertical, 11)
        }
    }
}
