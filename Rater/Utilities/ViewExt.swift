//
//  ViewExt.swift
//  Rater
//
//  Created by Александр Семенов on 30.11.2023.
//

import SwiftUI

extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}
