//
//  AvatarImage.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 2/16/26.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct AvatarImage: Transferable, Equatable {
    let image: Image
    let data: Data
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let image = AvatarImage(data: data) else {
                throw TransferError.importFailed
            }
            
            return image
        }
    }
}

extension AvatarImage {
    init?(data: Data) {
        #if canImport(AppKit)
            guard let nsImage = NSImage(data: data) else {
                return nil
            }
            let image = Image(nsImage: nsImage)
        #elseif canImport(UIKit)
            guard let uiImage = UIImage(data: data) else {
                return nil
            }
            let image = Image(uiImage: uiImage)
        #else
            return nil
        #endif
        
        self.init(image: image, data: data)
    }
}

enum TransferError: Error {
    case importFailed
}
