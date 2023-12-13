//
//  PhotoDetailView.swift
//  Rater
//
//  Created by Александр Семенов on 12.12.2023.
//

import SwiftUI

struct PhotoDetailView: View {
    
    @Binding var isShowingDetail: Bool
    
    let photo: Photo
    var body: some View {
        VStack(spacing: 20) {
            AsyncImageWithAuth(url: URL(string: getFullURL(photo.url))) { image in image 
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 225)
            } placeholder: {
                Image("placeholder")
                    .resizable()
                    .scaledToFill()
            }
        }
//        .frame(width: 300, height: 525)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 40)
        .overlay(DismissButton(isShowingDetail: $isShowingDetail), alignment: .topTrailing)
    }
}

//#Preview {
//    PhotoDetailView()
//}
