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
                    .foregroundStyle(Color(UIColor.textPrimary))
            })
            
            Button(action: {}, label: {
                Text(viewModel.user?.telephoneNumber ?? "")
                    .foregroundStyle(Color(UIColor.textPrimary))
            })
            
            Group {
                // appereance
                PrimaryButton(imageResource: .rDeditPen, text: .getStringFor(.appereance), corners: .topCorners, usage: .withRightArrow) {
                    viewModel.onAppereanceClick()
                }

                // privacy
                PrimaryButton(imageResource: .rDprivacyEye, text: .getStringFor(.privacy), usage: .withRightArrow) {
                    viewModel.onPrivacyClick()
                }
                
                // delete
                PrimaryButton(imageResource: .rDdeleteBin,
                              text: .getStringFor(.deleteMyAccount),
                              corners: .bottomCorners,
                              backgroundColor: .warningColor) {
                    
                }
            }.padding(.horizontal, 16)
            
            Spacer()
            
            
        }
        .ignoresSafeArea()
    }
}


