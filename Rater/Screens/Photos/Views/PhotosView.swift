//
//  PhotosView.swift
//  Rater
//
//  Created by Александр Семенов on 14.11.2023.
//

import SwiftUI

struct PhotosView: View {
    
    @StateObject var viewmodel = PhotosViewModel()
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    if viewmodel.photo != nil {
                        if let photo = viewmodel.photo {
                            PhotoCellView(photo: photo)
                        } 
                        
                    } else {
                        Spacer()
                        ContentUnavailableView("No new images",
                                               systemImage:"photo.stack",
                                               description: Text("Try again later :("))
                    }
                    
                }
                .task {
                    do {
                        let randomPhoto = try await viewmodel.getRandomPhoto()
                        viewmodel.photo = randomPhoto   
                    } catch let error {
                        print(error)
                    }
                }
            }
            if viewmodel.isLoading {
                LoadingView()
            }
        }
        .onAppear {
            Task {
                do {
                    let newPhoto = try await viewmodel.getRandomPhoto()
                    viewmodel.photo = newPhoto
                } catch {
                    print("Error getting random photo on appear: \(error)")
                }
            }
        }
        
    }
}

#Preview {
    PhotosView()
}
