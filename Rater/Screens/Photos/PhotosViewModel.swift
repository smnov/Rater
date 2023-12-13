//
//  PhotosViewModel.swift
//  Rater
//
//  Created by Александр Семенов on 16.11.2023.
//

import Foundation


@MainActor final class PhotosViewModel: ObservableObject {
        @Published var photo: Photo?
        @Published var isEmpty = false
        @Published var isLoading = false
        @Published var attractivenessRating: Float = 0
        @Published var trustWorthyRating: Float = 0
        @Published var smartRating: Float = 0
        @Published var isEditing = false
        
        var rateRoute = PhotoRateRoute()
        
        
        func ratePhoto(id: Int?) async {
            isLoading = true
            let ratedPhoto = PhotoRateRequest(
                                              file_id: id!,
                                              attractiveness_rating: attractivenessRating,
                                              smart_rating: smartRating,
                                              trustworthy_rating: trustWorthyRating)
            do {
                try await rateRoute.ratePhoto(ratedPhoto)
                
            } catch let error {
                print("Error while routing: ",error)
            }
            
            do {
                photo = try await getRandomPhoto()
            } catch {
                isEmpty = true
            }
            isLoading = false
            
        }
        
        
        func getRandomPhoto() async throws -> Photo {
            isLoading = true
            let photoRouter = PhotoRateRoute()
                let result = try await photoRouter.getRandomPhoto()
            switch result {
            case .success(let randomPhoto):
                isLoading = false
                return randomPhoto
                
            case .failure(let error):
                isLoading = false
                throw error
            }
        }
    }
