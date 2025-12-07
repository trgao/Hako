//
//  ProfileImage.swift
//  Hako
//
//  Created by Gao Tianrun on 11/5/25.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import SystemNotification

struct ProfileImage: View {
    @StateObject private var controller: ImageFrameController
    @Namespace private var transitionNamespace
    @State private var image: UIImage?
    @State private var isPresented = false
    @State private var isSuccessPresented = false
    @State private var isErrorPresented = false
    private let username: String?
    private let allowExpand: Bool
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
    init(imageUrl: String?, username: String? = nil, allowExpand: Bool = false) {
        self._controller = StateObject(wrappedValue: ImageFrameController(id: "userImage", imageUrl: imageUrl, isProfile: true))
        self.username = username
        self.allowExpand = allowExpand
    }
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    var label: some View {
        VStack {
            if let image = controller.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 2)
                    
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.gray)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 2)
            }
        }
        .task {
            await controller.refresh()
        }
    }
    
    var cover: some View {
        VStack(alignment: .trailing) {
            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark")
            }
            .padding([.horizontal, .top], 20)
            TabView {
                VStack(spacing: 10) {
                    if let username = username {
                        Image(uiImage: generateQRCode(from: "https://myanimelist.net/profile/\(username)"))
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180)
                            .padding(.bottom, 50)
                    }
                    label
                        .contextMenu {
                            if let inputImage = controller.image {
                                Button {
                                    let imageSaver = ImageSaver(isSuccessPresented: $isSuccessPresented, isErrorPresented: $isErrorPresented)
                                    imageSaver.writeToPhotoAlbum(image: inputImage)
                                } label: {
                                    Label("Save image", systemImage: "square.and.arrow.down")
                                }
                            }
                        }
                    Text(username ?? "")
                        .bold()
                        .font(.system(size: 25))
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .never))
        }
        .systemNotification(isActive: $isSuccessPresented) {
            Label("Successfully saved photo", systemImage: "checkmark.circle.fill")
                .labelStyle(.iconTint(.green))
                .padding()
        }
        .alert("Could not successfully save photo", isPresented: $isErrorPresented) {
            Button("Ok") {}
        } message: {
            Text("Check that you have provided permission for the app to access your photo library, in the Settings app under Apps > Hako > Photos > Add Photos Only")
        }
    }

    var body: some View {
        VStack {
            if #available(iOS 18.0, *) {
                Button {
                    isPresented = true && allowExpand
                } label: {
                    label
                }
                .matchedTransitionSource(id: "profile", in: transitionNamespace)
            } else {
                Button {
                    isPresented = true && allowExpand
                } label: {
                    label
                }
            }
        }
        .fullScreenCover(isPresented: $isPresented) {
            if #available(iOS 18.0, *) {
                cover
                    .navigationTransition(.zoom(sourceID: "profile", in: transitionNamespace))
            } else {
                cover
            }
        }
    }
}
