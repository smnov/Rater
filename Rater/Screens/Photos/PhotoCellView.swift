//
//  PhotoCellView.swift
//  Rater
//
//  Created by Александр Семенов on 18.11.2023.
//

import SwiftUI

struct PhotoCellView: View {
    
    @State var photo: Photo
    @StateObject var viewmodel = PhotosViewModel()
    
    var body: some View {
        VStack {
            AsyncImageWithAuth(url: URL(string: getFullURL(photo.url))) { image in image
                    .resizable()
            } placeholder: {
                Image("placeholder")
                    .resizable()
            }
            .frame(width: 400, height: 400)
            SliderView(rating: $viewmodel.attractivenessRating, text: "Attractiveness")
            SliderView(rating: $viewmodel.smartRating, text: "Smart")
            SliderView(rating: $viewmodel.trustWorthyRating, text: "Trustworthy")
            Button {
                Task {
                    await viewmodel.ratePhoto(id: photo.id)
                    do {
                        let newPhoto = try await viewmodel.getRandomPhoto()
                        photo = newPhoto
                    } catch let error {
                        print(error)
                    }
                }
            } label: {
                Text("Rate")
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width-32, height: 48)
            }
            .background(Color(.systemBlue))
            .cornerRadius(10)
            .padding(.top, 24)
        }
    }
}

//#Preview {
//    PhotoCellView(photo: Photo.SamplePhoto.first!)
//}
