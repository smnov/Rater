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
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            } placeholder: {
                Image("placeholder")
                    .resizable()
                    .scaledToFill()
            }
            PhotoStatView(id: photo.id)
            HStack {
                Spacer()
                Image(systemName: "trash")
                    .padding(5)
                
            }
        }
        .aspectRatio(contentMode: .fit)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 40)
        .overlay(DismissButton(isShowingDetail: $isShowingDetail), alignment: .topTrailing)
    }
}

//#Preview {
//    PhotoDetailView()
//}
