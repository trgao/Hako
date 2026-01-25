//
//  UserListStatusPicker.swift
//  Hako
//  With adapted code from https://stackoverflow.com/a/79158800 for scrollview fading effect
//
//  Created by Gao Tianrun on 17/1/26.
//

import SwiftUI

struct UserListStatusPicker: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.screenSize) private var screenSize
    @Binding private var selection: StatusEnum
    @State private var firstZoneSize: CGFloat = 0
    @State private var lastZoneSize: CGFloat = 0
    private let options: [StatusEnum]
    
    init(selection: Binding<StatusEnum>, options: [StatusEnum]) {
        self._selection = selection
        self.options = options
    }
    
    private func getCornerRadius() -> CGFloat {
        if #available(iOS 26.0, *) {
            return 20
        } else {
            return 10
        }
    }
    
    private func getPadding() -> CGFloat {
        if #available(iOS 26.0, *) {
            return 20
        } else {
            return 12
        }
    }
    
    var body: some View {
        if screenSize.width > 612 {
            TabPicker(selection: $selection, options: options.map{ ($0.toString(), $0) })
        } else {
            ZStack {
                if #available(iOS 26.0, *) {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle((colorScheme == .light ? Color.white : Color.black).opacity(0.6))
                        .glassEffect(.regular)
                        .padding(.horizontal, 15)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle((colorScheme == .light ? Color.white : Color.black).opacity(0.9))
                        .padding(.horizontal, 7)
                }
                ScrollViewReader { proxy in
                    GeometryReader { outer in
                        ScrollView(.horizontal) {
                            ZStack {
                                // This HStack is a hack for ScrollViewReader to scroll to position correctly without going into UIKit things
                                HStack {
                                    ForEach(options, id: \.self) { option in
                                        Text(option.rawValue)
                                    }
                                }
                                .hidden()
                                ScrollableSegmentedControl(selection: $selection, options: options)
                                    .onGeometryChange(for: CGRect.self) { proxy in
                                        proxy.frame(in: .scrollView)
                                    } action: { frame in
                                        let outerSize = outer.size
                                        let leadingZoneWidth = min(-frame.minX, 50)
                                        let trailingZoneWidth = min(frame.maxX - outerSize.width, 50)
                                        if firstZoneSize != leadingZoneWidth {
                                            firstZoneSize = leadingZoneWidth
                                        }
                                        if lastZoneSize != trailingZoneWidth {
                                            lastZoneSize = trailingZoneWidth
                                        }
                                    }
                            }
                        }
                        .scrollIndicators(.never)
                        .mask {
                            HStack(spacing: 0) {
                                LinearGradient(colors: [.clear, .black], startPoint: .leading, endPoint: .trailing)
                                    .frame(width: max(1, firstZoneSize))
                                Color.black
                                LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                                    .frame(width: max(1, lastZoneSize))
                            }
                        }
                        .background(Color(.systemGray4).opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: getCornerRadius()))
                        .padding(.horizontal, getPadding())
                        .onAppear {
                            proxy.scrollTo(selection, anchor: .center)
                        }
                        .onChange(of: selection) {
                            withAnimation {
                                proxy.scrollTo(selection, anchor: .center)
                            }
                        }
                        .frame(maxHeight: .infinity, alignment: .center)
                    }
                }
            }
            .frame(height: 42)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(5)
            .sensoryFeedback(.impact(weight: .light), trigger: selection)
        }
    }
}

class NoDragGestureSegmentedControl: UISegmentedControl {
    override init(items: [Any]?) {
        super.init(items: items)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageViews = subviews.compactMap { $0 as? UIImageView }.prefix(numberOfSegments)
        imageViews.forEach { $0.isHidden = true }
    }
}

struct ScrollableSegmentedControl: UIViewRepresentable {
    @Binding var selection: StatusEnum
    var options: [StatusEnum]

    func makeUIView(context: Context) -> NoDragGestureSegmentedControl {
        let control = NoDragGestureSegmentedControl(items: options.map{ $0.toString() })
        control.selectedSegmentIndex = options.firstIndex(of: selection) ?? 0
        control.addTarget(context.coordinator, action: #selector(Coordinator.updateSelectedSegment(sender:)), for: .valueChanged)
        return control
    }

    func updateUIView(_ uiView: NoDragGestureSegmentedControl, context: Context) {
        uiView.selectedSegmentIndex = options.firstIndex(of: selection) ?? 0
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIView, context: Context) -> CGSize? {
        uiView.sizeThatFits(CGSize(width: proposal.width ?? .infinity, height: proposal.height ?? .infinity))
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: ScrollableSegmentedControl

        init(_ parent: ScrollableSegmentedControl) {
            self.parent = parent
        }

        @objc func updateSelectedSegment(sender: UISegmentedControl) {
            parent.selection = parent.options[sender.selectedSegmentIndex]
        }
    }
}
