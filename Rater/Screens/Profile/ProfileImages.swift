//
//  ProfileImages.swift
//  Rater
//
//  Created by Александр Семенов on 01.12.2023.
//

import SwiftUI

struct ProfileImages: View {
    
    @StateObject var viewmodel = ProfileView.ProfileViewModel()
    
    
    var body: some View {
        ZStack {
            VStack {
                NavigationView {
                    if let photos = viewmodel.photos {
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
                    }
                }
            }
            if viewmodel.isLoading {
                LoadingView()
            }
            if viewmodel.isShowingDetail {
                PhotoDetailView(isShowingDetail: $viewmodel.isShowingDetail, photo: viewmodel.SelectedPhoto!)
            }
        }
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
