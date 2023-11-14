//
//  R.swift
//  Spika
//
//  Created by Nikola Barbarić on 13.11.2023..
//

import SwiftUI

struct ChatRoundedAvatar: View {
    let url: URL?
    var isGroupRoom = false
    @Binding var imageForUpload: UIImage?
    
    var body: some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image
                    .resizable()
            } else {
                if let imageForUpload {
                    Image(uiImage: imageForUpload)
                        .resizable()
                } else {
                    Image(isGroupRoom ? .rDDefaultGroup : .rDdefaultUser)
                        .resizable()
                        .clipped()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 400)
        .modifier(RoundedCorners(corners: .bottomLeft, radius: 80))
    }
}
