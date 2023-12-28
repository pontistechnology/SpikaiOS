//
//  SelectUsersView.swift
//  Spika
//
//  Created by Nikola Barbarić on 23.11.2023..
//
import Kingfisher
import SwiftUI
import CoreData

extension [SelectedUserOrGroup] {
    var onlyUsers: [UserEntity] {self.compactMap { $0.user }}
    var onlyRooms: [RoomEntity] {self.compactMap { $0.room }}
}

enum SelectedUserOrGroup: Identifiable, Hashable {
    case user(UserEntity)
    case room(RoomEntity)
    
    var id: String {
        return switch self {
        case .user(let userEntity):
            "user\(userEntity.id)" //prefix is needed because room and user can have same number for id
        case .room(let roomEntity):
            "room\(roomEntity.id)"
        }
    }
    
    var user: UserEntity? {
        switch self {
        case .user(let userEntity):
            userEntity
        case .room:
            nil
        }
    }
    
    var room: RoomEntity? {
        switch self {
        case .user:
            nil
        case .room(let roomEntity):
            roomEntity
        }
    }
    
    var avatarURL: URL? {
        switch self {
        case .user(let userEntity):
            userEntity.avatarFileId.fullFilePathFromId()
        case .room(let roomEntity):
            roomEntity.avatarFileId.fullFilePathFromId()
        }
    }
    
    var displayName: String {
        switch self {
        case .user(let userEntity):
            User(entity: userEntity).getDisplayName()
        case .room(let roomEntity):
            roomEntity.name ?? "no name"
        }
    }
    
    var description: String? {
        switch self {
        case .user(let userEntity):
            user?.telephoneNumber
        case .room(let roomEntity):
            room?.type
        }
    }
    
    var placeholderImage: Image {
        switch self {
        case .user:
            Image(.rDdefaultUser)
        case .room:
            Image(.rdDefaultGroup)
        }
    }
}

struct SelectUsersView: View {
    @State var selectedUsersAndGroups: [SelectedUserOrGroup] = []
    @State var isUsersSelected = true
    @StateObject var viewModel: SelectUsersViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            titleAndClose()
                .padding(.vertical, 10)
            
            TextField("", text: $viewModel.searchTerm, prompt: Text(verbatim: .getStringFor(.search)))
                .frame(height: 38)
                .padding(.horizontal, 12)
                .background(Color(.thirdAdditionalColor))
                .clipShape(Capsule())
            
            contactsOrGroupToggle()
                .padding(.vertical, 8)
            
            selectedMembersView()
            
            if isUsersSelected {
                ListWithPredicate(sI: \.sectionName, sD: viewModel.usersSortDescriptor, p: viewModel.usersPredicate) { (userEntity: UserEntity) in
                    memberRow(.user(userEntity))
                        .listRowBackground(Color(.secondaryColor))
                }
            } else {
                ListWithPredicate(sI: \.sectionName, sD: viewModel.roomsSortDescriptor, p: viewModel.roomsPredicate) { (roomEntity: RoomEntity) in
                    memberRow(.room(roomEntity))
                        .listRowBackground(Color(.secondaryColor))
                }
            }
            
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .background(Color(.secondaryColor))
    }
    
    private func titleAndClose() -> some View {
        HStack {
            Text("Forward message") // TODO: - change
            Spacer()
            Button {
                
            } label: {
                Image(.rDx)
            }
        }
    }
    
    private func contactsOrGroupToggle() -> some View {
        HStack(spacing: 5) {
            Button {
                isUsersSelected = true
            } label: {
                Text(verbatim: .getStringFor(.users))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .foregroundStyle(Color.fromUIColor(.textPrimary))
                    .background(isUsersSelected
                                ? Color.fromUIColor(.primaryColor)
                                : .fromUIColor(.fourthAdditionalColor))
                    .modifier(RoundedCorners(corners: .leftCorners, radius: 15))
            }
            
            Button {
                isUsersSelected = false
            } label: {
                Text(verbatim: .getStringFor(.groups))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .foregroundStyle(Color.fromUIColor(.textPrimary))
                    .background(isUsersSelected
                                ? .fromUIColor(.fourthAdditionalColor)
                                : Color.fromUIColor(.primaryColor))
                    .modifier(RoundedCorners(corners: .rightCorners, radius: 15))
            }
        }
    }
    
    private func selectedMembersView() -> some View {
        VStack(spacing: 0) {
            Text("\(selectedUsersAndGroups.count) selected")
                .frame(maxWidth: .infinity, alignment: .leading)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(selectedUsersAndGroups) { selectedThing in
                        VStack(spacing: 0)  {
                            KFImage(selectedThing.avatarURL)
                                .placeholder { _ in
                                    selectedThing.placeholderImage
                                        .resizable()
                                }
                                .resizable()
                                .clipShape(Circle())
                                .padding()
                                .frame(width: 84, height: 84)
                                .overlay(alignment: .topTrailing) {
                                    Button(action: {
                                        selectedUsersAndGroups.removeFirstIfExist(selectedThing)
                                    }, label: {
                                        Image(.rDx)
                                            .tint(Color(.textPrimary))
                                            .background(Color(.primaryColor).clipShape(Circle()))
                                            .padding(.trailing, 8)
                                            .padding(.top, 8)
                                    })
                                }
                            Text(selectedThing.displayName)
                                .frame(maxWidth: 84)
                        }
                    }
                }
                .fixedSize()
            }
        }
        .padding(.vertical, 8)
    }
    
    private func memberRow(_ thing: SelectedUserOrGroup) -> some View {
        Button {
            selectedUsersAndGroups.toggle(thing)
        } label: {
            HStack(spacing: 16) {
                KFImage(thing.avatarURL)
                    .placeholder { _ in
                        thing.placeholderImage.resizable()
                    }
                    .resizable()
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
                
                VStack {
                    Text(thing.displayName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(thing.description ?? "-")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }.foregroundStyle(Color(.textPrimary))
                
                Spacer()
                if selectedUsersAndGroups.contains(thing) {
                    Image(.rDcheckmark)
                        .tint(Color(.textPrimary))
                }
            }
        }
    }
}
