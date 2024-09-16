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
            ChatRoundedAvatar(url: viewModel.url,
                              imageForUpload: $viewModel.selectedImage)
            .modifier(UploadProgressModifier(isShowing: viewModel.selectedImage != nil))
            .allowsHitTesting(viewModel.selectedImage == nil)
            .onTapGesture {
                viewModel.showChangeImageActionSheet()
            }
            
            Group {
                EditableText(placeholder: .getStringFor(.enterUsername),
                             isEditingMode: $viewModel.isEditingUsername,
                             string: $viewModel.username, 
                             isEditingPossible: true)
                
                Button(action: {}, label: {
                    Text(viewModel.user?.telephoneNumber ?? "")
                        .foregroundStyle(Color(UIColor.textPrimary))
                })
                
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
                    viewModel.askForDeleteConformation()
                }
            }.padding(.horizontal, 16)
            
            Spacer()
        }
        .ignoresSafeArea()
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(sourceType: viewModel.selectedSource,
                        selectedImage: $viewModel.selectedImage)
        }
    }
}
