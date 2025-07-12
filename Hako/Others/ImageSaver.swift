//
//  ImageSaver.swift
//  Code taken from https://www.hackingwithswift.com/books/ios-swiftui/how-to-save-images-to-the-users-photo-library
//

import SwiftUI

class ImageSaver: NSObject {
    @Binding private var isSuccessPresented: Bool
    @Binding private var isErrorPresented: Bool
    
    init(isSuccessPresented: Binding<Bool>, isErrorPresented: Binding<Bool>) {
        self._isSuccessPresented = isSuccessPresented
        self._isErrorPresented = isErrorPresented
    }
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let _ = error {
            print("Error when saving photo")
            isErrorPresented = true
        } else {
            print("Successfully saved photo")
            isSuccessPresented = true
        }
    }
}
