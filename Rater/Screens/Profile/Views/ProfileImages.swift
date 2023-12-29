//
//  ProfileImages.swift
//  Rater
//
//  Created by Александр Семенов on 01.12.2023.
//

import SwiftUI

struct ProfileImages: View {
    
    @StateObject var viewmodel = ProfileViewModel()
    
    
    var body: some View {
        ZStack {
            VStack {
                NavigationView {
                    if let photos = viewmodel.photos {
                        if !photos.isEmpty {
                            ScrollView {
                                LazyVGrid(columns: viewmodel.columns) {
                                    ForEach(photos, id: \.id) { photo in
                                        AsyncImageWithAuth(url: URL(string: getFullURL(photo.url))) { image in image
                                                .resizable()
                                        } placeholder: {
                                            Image("placeholder")
                                                .resizable()
                                        }
                                        .frame(width: 100, height: 100)
                                        .onTapGesture {
                                            viewmodel.SelectedPhoto = photo
                                            viewmodel.isShowingDetail = true
                                        }
                                    }
                                }
                            }
                        } else {
                            ContentUnavailableView("No images",
                                                   systemImage:"photo.stack",
                                                   description: Text("You need to add photos"))
                        }
                    }
                }
            }
            .padding(.top)
            .blur(radius: viewmodel.isShowingDetail ? 20 : 0)
            
            if viewmodel.isLoading {
                LoadingView()
            }
            if viewmodel.isShowingDetail {
                PhotoDetailView(isShowingDetail: $viewmodel.isShowingDetail, photo: viewmodel.SelectedPhoto!)
            }
        }
        .border(Color.black, width: 1)
        .task {
            do {
                try await viewmodel.loadProfilePhotos()
            } catch let error {
                print(error)
            }
        }
        
    }
        
}

#Preview {
    ProfileImages()
}
