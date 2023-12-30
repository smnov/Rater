//
//  FAQData.swift
//  Rater
//
//  Created by Александр Семенов on 30.12.2023.
//

import Foundation
import SwiftUI

struct FAQData {
    
    public var russianVersion: [[String: String]] = [
        ["question": "Как использовать Rater?", "answer": "Просто загрузите свою фотографию, и пользователи Rater будут оценивать ее анонимно. Вы также можете просматривать и оценивать фотографии других пользователей."],
        
        ["question": "Могу ли я видеть оценки своих фотографий?", "answer": "Да, но вы не сможете увидеть, кто оценивал ваши фотографии."],
        
        ["question": "Как обеспечивается анонимность?", "answer": "Оценки фотографий анонимны, и пользователи видят только обобщенные результаты."],
        
        ["question": "Могу ли я удалять свои фотографии?", "answer": "Да, вы можете управлять своими фотографиями и удалять их в любое время через раздел управления фотографиями."]
    ]
    
    public var englishVersion: [[String: String]] = [
        ["question": "How to use Rater?", "answer": "Simply upload your photo, and Rater users will anonymously rate it. You can also browse and rate photos of other users."],

        ["question": "Can I see the ratings of my photos?", "answer": "Yes, but you won't be able to see who rated your photos."],

        ["question": "How is anonymity ensured?", "answer": "Photo ratings are anonymous, and users only see aggregated results."],

        ["question": "Can I delete my photos?", "answer": "Yes, you can manage your photos and delete them at any time through the photo management section."]
    ]
}


