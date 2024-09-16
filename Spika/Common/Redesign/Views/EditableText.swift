//
//  EditableText.swift
//  Spika
//
//  Created by Nikola Barbarić on 20.11.2023..
//

import SwiftUI

struct EditableText: View {
    var placeholder: String
    @Binding var isEditingMode: Bool
    @Binding var string: String
    var isEditingPossible: Bool
    
    var body: some View {
        if isEditingMode {
            HStack {
                TextField("", text: $string, 
                                  prompt: Text(placeholder)
                    .font(.customFont(.RobotoFlexMedium, size: 12))
                    .foregroundColor(Color(.textSecondary)))
                .font(.customFont(.RobotoFlexMedium, size: 12))
                .frame(height: 50)
                .padding(.horizontal, 24)
                .background(Color(.secondaryColor))
                .clipShape(Capsule())
                
                Button(action: {
                    isEditingMode = false
                }, label: {
                    Image(.rDcheckmark)
                })
            }
            .foregroundStyle(Color(.textPrimary))
        } else {
            Button(action: {
                if isEditingPossible {
                    isEditingMode = true                    
                }
            }, label: {
                Text(string)
                    .foregroundStyle(Color(.textPrimary))
                    .font(.customFont(.RobotoFlexSemiBold, size: 24))
            })
        }
    }
}
