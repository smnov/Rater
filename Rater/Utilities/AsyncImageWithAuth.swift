//
//  AsyncImageWithAuth.swift
//  Rater
//
//  Created by Александр Семенов on 02.12.2023.
//

import Foundation
import SwiftUI

struct AsyncImageWithAuth<Content: View, Placeholder: View>: View {
    
    @State var uiImage: UIImage?
    
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    public init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ){
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    public var body: some View {
        if let uiImage = uiImage {
            content(Image(uiImage: uiImage))
        } else {
            placeholder()
                .task {
                    self.uiImage = await getImage(fromUrl: url?.absoluteString)
                }
        }
    }
    
    private func getImage(fromUrl url: String?) async -> UIImage? {
        guard let urlString = url, let url = URL(string: urlString) else {
            print("Missing URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let token = try Store.shared.getTokenFromStorage()
            request.setValue(token, forHTTPHeaderField: "jwt-token")
        } catch let error {
            print("\(error)")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                return nil
            }
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
}
