//
//  SelectUsersView.swift
//  Spika
//
//  Created by Nikola Barbarić on 23.11.2023..
//
import Kingfisher
import SwiftUI
import CoreData

struct ListWithPredicate<T: NSManagedObject & Identifiable, Content: View>: View {
    @SectionedFetchRequest<String, T> var fetchRequest: SectionedFetchResults<String, T>
    let content: (T) -> Content
    
    var body: some View {
        List {
            ForEach(fetchRequest) { section in
                Section {
                    ForEach(section) { element in
                        content(element)
                    }
                } header: {
                    // TODO: - make parameter
                    Text(section.id)
                        .foregroundStyle(Color(.textPrimary))
                        .font(.largeTitle)
                }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        }
        .listStyle(.plain)
    }
    
    init(sI: KeyPath<T, String>, sD: [NSSortDescriptor], p: NSPredicate?, @ViewBuilder content: @escaping (T)->Content) {
        _fetchRequest = SectionedFetchRequest<String, T>(sectionIdentifier: sI, sortDescriptors: sD, predicate: p)
        self.content = content
    }
}

struct SelectUsersView: View {
    @Binding var selectedUsers: [User]
    @State var searchTerm = ""
    var predicate: NSPredicate? {
        searchTerm.isEmpty ? nil : NSPredicate(format: "contactsName CONTAINS[c] '\(searchTerm)' OR telephoneNumber CONTAINS[c] '\(searchTerm)'")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TextField("", text: $searchTerm, prompt: Text(verbatim: .getStringFor(.search)))
                .frame(height: 38)
                .padding(.horizontal, 12)
                .background(Color(.thirdAdditionalColor))
                .clipShape(Capsule())
            
            selectedMembersView()
            
            ListWithPredicate(sI: \.sectionName, sD: SelectUsersViewModel.sortD, p: predicate) { (userEntity: UserEntity) in
                let user = User(entity: userEntity)
                memberRow(user: user)
                    .listRowBackground(Color(.secondaryColor))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .background(Color(.secondaryColor))
    }
    
    private func selectedMembersView() -> some View {
        VStack(spacing: 0) {
            Text("\(selectedUsers.count) selected")
                .frame(maxWidth: .infinity, alignment: .leading)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(selectedUsers) { user in
                        VStack(spacing: 0)  {
                            KFImage(user.avatarFileId?.fullFilePathFromId())
                                .placeholder { _ in
                                    Image(.rDdefaultUser)
                                        .resizable()
                                }
                                .resizable()
                                .clipShape(Circle())
                                .padding()
                                .frame(width: 84, height: 84)
                                .overlay(alignment: .topTrailing) {
                                    Button(action: {
                                        selectedUsers.removeFirstIfExist(user)
                                    }, label: {
                                        Image(.rDx)
                                            .tint(Color(.textPrimary))
                                            .background(Color(.primaryColor).clipShape(Circle()))
                                            .padding(.trailing, 8)
                                            .padding(.top, 8)
                                    })
                                }
                            Text(user.getDisplayName())
                                .frame(maxWidth: 84)
                        }
                    }
                }
                .fixedSize()
            }
        }
        .padding(.vertical, 8)
    }
    
    private func memberRow(user: User) -> some View {
        Button {
            selectedUsers.toggle(user)
        } label: {
            HStack(spacing: 16) {
                KFImage(user.avatarFileId?.fullFilePathFromId())
                    .placeholder { _ in
                        Image(.rDdefaultUser)
                            .resizable()
                    }
                    .resizable()
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
                
                VStack {
                    Text(user.getDisplayName())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(user.telephoneNumber ?? "")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }.foregroundStyle(Color(.textPrimary))
                
                Spacer()
                if selectedUsers.contains(where: { $0.id == user.id }) {
                    Image(.rDcheckmark)
                        .tint(Color(.textPrimary))
                }
            }
        }
    }
}
