//
//  CheckSwipeDismissChanges.swift
//  Code modified from https://fatbobman.com/en/posts/newinteractivedismissdiabled/
//

import SwiftUI

struct SetSheetDelegate: UIViewRepresentable {
    let delegate: SheetDelegate

    init(isDisabled: Bool, isLoading: Bool, isDiscardingChanges: Binding<Bool>){
        self.delegate = SheetDelegate(isDisabled: isDisabled, isLoading: isLoading, isDiscardingChanges: isDiscardingChanges)
    }

    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            uiView.parentViewController?.presentationController?.delegate = delegate
        }
    }
}

final class SheetDelegate: NSObject, UIAdaptivePresentationControllerDelegate {
    @Binding var isDiscardingChanges: Bool
    let isDisabled: Bool
    let isLoading: Bool

    init(isDisabled: Bool, isLoading: Bool, isDiscardingChanges: Binding<Bool>) {
        self.isDisabled = isDisabled
        self.isLoading = isLoading
        self._isDiscardingChanges = isDiscardingChanges
    }

    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        !isDisabled && !isLoading
    }

    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        if isDisabled && !isLoading {
            isDiscardingChanges = true
        }
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}

public extension View{
    func checkSwipeDismissChanges(isDisabled: Bool, isLoading: Bool, isDiscardingChanges: Binding<Bool>) -> some View{
        background(SetSheetDelegate(isDisabled: isDisabled, isLoading: isLoading, isDiscardingChanges: isDiscardingChanges))
    }
}
