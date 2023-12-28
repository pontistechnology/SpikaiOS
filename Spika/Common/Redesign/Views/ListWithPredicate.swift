//
//  ListWithPredicate.swift
//  Spika
//
//  Created by Nikola Barbarić on 27.12.2023..
//

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
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
    
    init(sI: KeyPath<T, String>, sD: [NSSortDescriptor], p: NSPredicate?, @ViewBuilder content: @escaping (T)->Content) {
        _fetchRequest = SectionedFetchRequest<String, T>(sectionIdentifier: sI, sortDescriptors: sD, predicate: p)
        self.content = content
    }
}
