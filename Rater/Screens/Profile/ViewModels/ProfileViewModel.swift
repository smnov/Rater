//
//  ProfileViewModel.swift
//  Rater
//
//  Created by Александр Семенов on 29.11.2023.
//

import Foundation
import SwiftUI



@MainActor final class ProfileViewModel: ObservableObject {
    
    @Published var profile: Profile?
    @Published var photos: [Photo]?
    @Published var isLoading = false
    @Published var isShowingDetail = false
    @Published var alertItem: AlertItem?
    
    var SelectedPhoto: Photo?
    
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())] // flexible filling the screen
    
    private let profileRoute = ProfileRoute()
    
    
    func loadProfile() async throws {
        do {
            profile = try await profileRoute.loadProfile()
        } catch let error {
            throw error
        }
    }
    
    func loadProfilePhotos() async throws {
        isLoading = true
        do {
            photos = try await profileRoute.loadProfilePhotos()
        } catch let error {
            throw error
        }
        isLoading = false
    }
    
    func uploadPhoto(photo: Image) {
        isLoading = true
        let uiImage = photo.asUIImage()
        profileRoute.uploadPhoto(fileName: "name", image: uiImage) { result in
            switch result {
            case .success(let photo):
                print("success")
            case .failure(let error):
                self.alertItem = AlertItem(title: Text("Error"), message: Text("\(error.localizedDescription)"), dismissButton: .default(Text("OK")))
                
            }
        }
        isLoading = false
    }
}
