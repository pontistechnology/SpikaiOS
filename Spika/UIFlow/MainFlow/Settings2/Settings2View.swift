//
//  Settings2.swift
//  Spika
//
//  Created by Nikola Barbarić on 09.11.2023..
//

import SwiftUI
import Swinject

struct Settings2View: View {
    @StateObject var viewModel: Settings2ViewModel

    var body: some View {
        ScrollView {
            let url = viewModel.user?.avatarFileId?.fullFilePathFromId()
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                } else {
                    Image(.userDefaultProfilePicture)
                        .resizable()
                        .clipped()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 400)
            .modifier(RoundedCorners(corners: .bottomLeft, radius: 80))
            
            Button(action: {}, label: {
                Text(viewModel.user?.getDisplayName() ?? "")
            })
            
            Button(action: {}, label: {
                Text(viewModel.user?.telephoneNumber ?? "")
            })
            
            Group {
                // appereance
                PrimaryButton(imageResource: .editPen, text: .getStringFor(.appereance), corners: .topCorners) {
                    viewModel.onAppereanceClick()
                }

                // privacy
                PrimaryButton(imageResource: .privacyEye, text: .getStringFor(.privacy)) {
                    viewModel.onPrivacyClick()
                }
                
                // delete
                PrimaryButton(imageResource: .deleteBin,
                              text: .getStringFor(.delete),
                              corners: .bottomCorners,
                              backgroundColor: .warningColor) {
                    
                }
            }.padding(.horizontal, 16)
            
            Spacer()
            
            
        }
        .ignoresSafeArea()
    }
}


