//
//  PhotoDetailViewModel.swift
//  Rater
//
//  Created by Александр Семенов on 13.12.2023.
//

import Foundation

@MainActor class PhotoDetailViewModel: ObservableObject {
    
    @Published var photoStat: PhotoRating?
    
    
    func getStatOfPhoto(id: Int) async {
        let statRoute = PhotoStatRoute()
        do {
            let result = try await statRoute.getPhotoStat(id: id)
            switch result {
            case .success(let data):
                self.photoStat = data
            case .failure(let error):
                print("Error while getting stat: \(error)")
            }
        } catch {
            print(error)
        }
    }
}
