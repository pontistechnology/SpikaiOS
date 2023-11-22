//
//  R.swift
//  Spika
//
//  Created by Nikola Barbarić on 13.11.2023..
//

import SwiftUI
import Kingfisher

struct ChatRoundedAvatar: View {
    let url: URL?
    var isGroupRoom = false
    @Binding var imageForUpload: UIImage?
    
    var body: some View {
        KFImage(url)
            .placeholder { _ in
                if let imageForUpload {
                    Image(uiImage: imageForUpload)
                        .resizable()
                } else {
                    Image(isGroupRoom ? .rDDefaultGroup : .rDdefaultUser)
                        .resizable()
                }
            }
            .resizable()
            .frame(maxWidth: .infinity)
            .frame(height: 400)
            .modifier(RoundedCorners(corners: .bottomLeft, radius: 80))
    }
}
