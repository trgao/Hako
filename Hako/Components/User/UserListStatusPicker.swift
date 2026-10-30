//
//  UserListStatusPicker.swift
//  Hako
//  With adapted code from https://stackoverflow.com/a/79158800 for scrollview fading effect
//  ClearSegmentedPicker design adapted from https://www.sabesh.space/blog/engineering/clear-segmented-picker
//  With massive help from Claude
//
//  Created by Gao Tianrun on 17/1/26.
//

import SwiftUI

struct UserListStatusPicker: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.screenSize) private var screenSize
    @Binding private var selection: StatusEnum
    @State private var firstZoneSize: CGFloat = 0
    @State private var lastZoneSize: CGFloat = 0
    @State private var fade = EdgeFade()
    @State private var didInitialScroll = false
    @State private var scrollPosition = ScrollPosition()
    @State private var scrollMetrics = ScrollMetricsBox()
    private let options: [StatusEnum]
    private let isLoading: Bool
    private let fadeLength: CGFloat = 50

    private struct EdgeFade: Equatable {
        var leading: CGFloat = 0
        var trailing: CGFloat = 0
    }

    private final class ScrollMetricsBox {
        var offset: CGFloat = 0
        var contentWidth: CGFloat = 0
        var containerWidth: CGFloat = 0
    }

    init(selection: Binding<StatusEnum>, options: [StatusEnum], isLoading: Bool) {
        self._selection = selection
        self.options = options
        self.isLoading = isLoading
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

    // Called by ClearSegmentedPicker while its indicator is dragged near an edge.
    private func autoScroll(by delta: CGFloat) {
        let maxOffset = max(scrollMetrics.contentWidth - scrollMetrics.containerWidth, 0)
        let target = min(max(scrollMetrics.offset + delta, 0), maxOffset)
        scrollPosition.scrollTo(x: target)
    }

    private var clearFadeMask: some View {
        HStack(spacing: 0) {
            LinearGradient(colors: [.clear, .black], startPoint: .leading, endPoint: .trailing)
                .frame(width: fade.leading)
            Color.black
            LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                .frame(width: fade.trailing)
        }
    }

    private var glassScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                ClearSegmentedPicker(selection: $selection, options: options, onAutoScroll: autoScroll(by:)).disabled(isLoading)
            }
            .background(colorScheme == .light ? Color(.systemGray4).opacity(0.3) : Color(.systemGray5).opacity(0.7), in: RoundedRectangle(cornerRadius: getCornerRadius()))
            .padding(.horizontal, 6)
            .scrollPosition($scrollPosition)
            .scrollClipDisabled()
            .scrollIndicators(.never)
            .onScrollGeometryChange(for: EdgeFade.self) { geometry in
                let offset = geometry.contentOffset.x + geometry.contentInsets.leading
                let maxOffset = geometry.contentSize.width - geometry.containerSize.width
                return EdgeFade(
                    leading: min(max(offset, 0), fadeLength),
                    trailing: min(max(maxOffset - offset, 0), fadeLength)
                )
            } action: { _, newValue in
                fade = newValue
            }
            .onScrollGeometryChange(for: CGSize.self) { geometry in
                // width = content offset, height unused; packed together to keep one callback per frame
                CGSize(width: geometry.contentOffset.x, height: 0)
            } action: { _, newValue in
                scrollMetrics.offset = newValue.width
            }
            .onScrollGeometryChange(for: CGSize.self) { geometry in
                CGSize(width: geometry.contentSize.width, height: geometry.containerSize.width)
            } action: { _, newValue in
                scrollMetrics.contentWidth = newValue.width
                scrollMetrics.containerWidth = newValue.height
            }
            .mask {
                clearFadeMask.padding(.vertical, -20)
            }
            .onScrollGeometryChange(for: Bool.self) { geometry in
                geometry.contentSize.width > 0 && geometry.containerSize.width > 0
            } action: { _, isReady in
                guard isReady, !didInitialScroll else { return }
                didInitialScroll = true
                Task { @MainActor in
                    proxy.scrollTo(selection, anchor: .center)
                }
            }
            .onChange(of: selection) {
                withAnimation { proxy.scrollTo(selection, anchor: .center) }
            }
            .sensoryFeedback(.impact(weight: .light), trigger: selection)
        }
    }

    private var legacyScrollView: some View {
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
                            .disabled(isLoading)
                            .onGeometryChange(for: CGRect.self) { geometry in
                                geometry.frame(in: .scrollView)
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
                    clearFadeMask
                }
                .background(Color(.systemGray4).opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: getCornerRadius()))
                .padding(.horizontal, getPadding())
                .onScrollGeometryChange(for: Bool.self) { geometry in
                    geometry.contentSize.width > 0 && geometry.containerSize.width > 0
                } action: { _, isReady in
                    guard isReady, !didInitialScroll else { return }
                    didInitialScroll = true
                    Task { @MainActor in
                        proxy.scrollTo(selection, anchor: .center)
                    }
                }
                .onChange(of: selection) {
                    withAnimation {
                        proxy.scrollTo(selection, anchor: .center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .sensoryFeedback(.impact(weight: .light), trigger: selection)
            }
        }
    }

    var body: some View {
        if screenSize.width > 650 { // width of ScrollableSegmentedControl
            TabPicker(selection: $selection, options: options.map { ($0.toString(), $0) })
                .disabled(isLoading)
        } else {
            if #available(iOS 26.2, *), horizontalSizeClass == .compact {
                glassScrollView
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
                    legacyScrollView
                }
                .frame(height: 42)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(5)
            }
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
        let control = NoDragGestureSegmentedControl(items: options.map { $0.toString() })
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

struct ClearSegmentedPicker: View {
    @Binding var selection: StatusEnum
    let options: [StatusEnum]
    var onAutoScroll: ((CGFloat) -> Void)?

    @State private var frames: [StatusEnum: CGRect] = [:]
    @State private var dragOffset: CGFloat = 0
    @State private var originX: CGFloat = 0 // this view's minX in the scroll view's viewport
    @State private var viewportWidth: CGFloat = 0
    @State private var isDragging = false
    @State private var hasMoved = false
    @State private var grabOffset: CGFloat = 0 // finger's x relative to the indicator's centre when grabbed
    @State private var fingerX: CGFloat = 0 // finger's x in the viewport
    @State private var edgeVelocity: CGFloat = 0 // -1...1, 0 when not near an edge

    private let space = "ClearSegmentedPicker"
    private let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    private let edgeZone: CGFloat = 40
    private let maxAutoScrollSpeed: CGFloat = 12 // points per frame at the very edge
    private let expandedScale = CGSize(width: 1.35, height: 1.6) // indicator "lens" size while pressed

    // While dragging, the indicator is centred on the finger and its width blends
    // between the widths of the segments it is passing over.
    private var indicatorFrame: CGRect? {
        guard let frame = frames[selection] else { return nil }
        guard dragOffset != 0 else { return frame }
        let center = frame.midX + dragOffset
        let width = interpolatedWidth(at: center) ?? frame.width
        return CGRect(x: center - width / 2, y: frame.minY, width: width, height: frame.height)
    }

    private var autoScrollDirection: Int {
        edgeVelocity == 0 ? 0 : (edgeVelocity > 0 ? 1 : -1)
    }

    // Places the indicator under the finger and works out whether to auto-scroll.
    private func updateDrag() {
        guard isDragging, let frame = frames[selection] else { return }
        let desiredCenter = (fingerX - originX) - grabOffset
        dragOffset = clampedOffset(desiredCenter - frame.midX)
        edgeVelocity = hasMoved ? velocity(forFingerAt: fingerX) : 0
    }

    private func velocity(forFingerAt x: CGFloat) -> CGFloat {
        guard viewportWidth > 0 else { return 0 }
        if x < edgeZone {
            return -min((edgeZone - x) / edgeZone, 1)
        }
        if x > viewportWidth - edgeZone {
            return min((x - (viewportWidth - edgeZone)) / edgeZone, 1)
        }
        return 0
    }

    // The offset moves the indicator's centre, which stays between the first and last
    // segment centres (so at either end the indicator exactly matches that segment).
    private func clampedOffset(_ offset: CGFloat) -> CGFloat {
        guard let current = frames[selection],
              let first = options.first.flatMap({ frames[$0] }),
              let last = options.last.flatMap({ frames[$0] }) else { return 0 }
        let lowerBound = first.midX - current.midX
        let upperBound = last.midX - current.midX
        return min(max(offset, lowerBound), upperBound)
    }

    // Linearly blends the widths of the two segments whose centres surround `center`.
    private func interpolatedWidth(at center: CGFloat) -> CGFloat? {
        let segments = options.compactMap { frames[$0] }
        guard let first = segments.first, let last = segments.last else { return nil }
        if center <= first.midX { return first.width }
        if center >= last.midX { return last.width }
        for (a, b) in zip(segments, segments.dropFirst()) where center <= b.midX {
            let t = (center - a.midX) / (b.midX - a.midX)
            return a.width + (b.width - a.width) * t
        }
        return last.width
    }

    private func snapToNearest() {
        guard let frame = indicatorFrame else { return }
        let target = options.min { a, b in
            abs((frames[a]?.midX ?? .infinity) - frame.midX) < abs((frames[b]?.midX ?? .infinity) - frame.midX)
        }
        withAnimation(spring) {
            if let target { selection = target }
            dragOffset = 0
        }
    }

    @ViewBuilder
    private var indicator: some View {
        if #available(iOS 26.0, *) {
            Color.clear
                .glassEffect(.clear, in: Capsule())
                .opacity(isDragging ? 0.8 : 0.5)
        } else {
            Capsule().fill(.background)
        }
    }

    private func label(for option: StatusEnum) -> some View {
        let isSelected = option == selection
        return Button {
            selection = option
        } label: {
            Text(option.toString())
                .font(.system(size: 13))
                .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 5)
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .named(space))
        } action: { newFrame in
            if frames[option] != newFrame { frames[option] = newFrame }
        }
    }

    // The gesture is measured in the scroll view's viewport space, so the finger position
    // stays meaningful while the content scrolls underneath it.
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .scrollView)
            .onChanged { value in
                guard let frame = frames[selection] else { return }
                if !isDragging {
                    isDragging = true
                    hasMoved = false
                    grabOffset = (value.startLocation.x - originX) - frame.midX
                }
                fingerX = value.location.x
                if !hasMoved, abs(value.translation.width) > 4 {
                    hasMoved = true
                }
                updateDrag()
            }
            .onEnded { _ in
                isDragging = false
                hasMoved = false
                edgeVelocity = 0
                snapToNearest()
            }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if let frame = indicatorFrame {
                indicator
                    .frame(width: frame.width, height: frame.height)
                    .scaleEffect(
                        x: isDragging ? expandedScale.width : 1,
                        y: isDragging ? expandedScale.height : 1
                    )
                    .animation(spring, value: isDragging)
                    .offset(x: frame.minX, y: frame.minY)
                    .allowsHitTesting(false)
            }
            HStack(spacing: 0) {
                ForEach(options, id: \.self) { option in
                    label(for: option)
                }
            }
            if let frame = indicatorFrame {
                Color.clear
                    .contentShape(Capsule())
                    .frame(width: frame.width, height: frame.height)
                    .offset(x: frame.minX, y: frame.minY)
                    .highPriorityGesture(dragGesture)
            }
        }
        .coordinateSpace(.named(space))
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.frame(in: .scrollView).minX
        } action: { originX = $0 }
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.bounds(of: .scrollView)?.width ?? 0
        } action: { viewportWidth = $0 }
        .task(id: autoScrollDirection) { @MainActor in
            guard autoScrollDirection != 0 else { return }
            while !Task.isCancelled {
                onAutoScroll?(edgeVelocity * maxAutoScrollSpeed)
                do { try await Task.sleep(for: .milliseconds(16)) } catch { break }
                // The content moved under a stationary finger, so re-derive the indicator.
                updateDrag()
            }
        }
        .animation(spring, value: selection)
        .padding(3)
    }
}
