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
import UIKit.UIGestureRecognizerSubclass

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

// Runs the `glassLens` Metal shader (GlassLens.metal) over the labels. The lens rect and strength
// are animatable, so the refraction follows the glass indicator through spring animations
// (shader arguments are not interpolated by SwiftUI on their own).
private struct LensRefraction: ViewModifier, Animatable {
    var rect: CGRect
    var strength: CGFloat
    var pad: CGFloat // extra space around the labels so the lens can grow beyond their bounds

    var animatableData: AnimatablePair<CGRect.AnimatableData, CGFloat> {
        get { AnimatablePair(rect.animatableData, strength) }
        set {
            rect.animatableData = newValue.first
            strength = newValue.second
        }
    }

    func body(content: Content) -> some View {
        content.layerEffect(
            ShaderLibrary.glassLens(
                .float4(rect.minX + pad, rect.minY + pad, rect.width, rect.height),
                .float(strength)
            ),
            maxSampleOffset: CGSize(width: 30, height: 30)
        )
    }
}

private final class PressureRecognizer: UIGestureRecognizer, UIGestureRecognizerDelegate {
    weak var referenceView: UIView?
    var hitFrame: CGRect? // in referenceView's coordinates
    var onBegan: ((CGFloat) -> Void)?
    var onChanged: ((CGFloat) -> Void)?
    var onEnded: (() -> Void)?

    private var tracked: UITouch?
    private var smoothed: CGFloat = 1
    private var lastReported: CGFloat = 1

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        cancelsTouchesInView = false
        delaysTouchesBegan = false
        delaysTouchesEnded = false
        delegate = self
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        true
    }

    private func isOnIndicator(_ touch: UITouch) -> Bool {
        guard let view = referenceView, let window = view.window, let frame = hitFrame else { return false }
        guard frame.contains(touch.location(in: view)) else { return false }
        // Ignore touches that land on something covering the picker from another presentation (e.g. a sheet).
        var root: UIView = view
        while let parent = root.superview, parent !== window { root = parent }
        guard let hit = window.hitTest(touch.location(in: window), with: nil) else { return false }
        return hit.isDescendant(of: root)
    }

    // 0...1. Only hardware that really measures force (Apple Pencil, 3D Touch iPhones) gets a proportional value.
    // Everything else reports 1, so the indicator always reaches its full size instead of being capped by a guess.
    private func pressure(for touch: UITouch) -> CGFloat {
        let hasForce = touch.type == .pencil || referenceView?.traitCollection.forceTouchCapability == .available
        guard hasForce, touch.maximumPossibleForce > 0 else { return 1 }
        return min(touch.force / touch.maximumPossibleForce, 1)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard tracked == nil else { return } // already following a finger; ignore extra ones
        guard let touch = touches.first, isOnIndicator(touch) else {
            state = .failed
            return
        }
        tracked = touch
        let initial = pressure(for: touch)
        smoothed = initial
        lastReported = initial
        onBegan?(initial)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let touch = tracked, touches.contains(touch) else { return }
        smoothed += (pressure(for: touch) - smoothed) * 0.35
        if abs(smoothed - lastReported) > 0.02 {
            lastReported = smoothed
            onChanged?(smoothed)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        finish(touches)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        finish(touches)
    }

    private func finish(_ touches: Set<UITouch>) {
        guard let touch = tracked, touches.contains(touch) else { return }
        tracked = nil
        onEnded?()
        state = .failed
    }

    override func reset() {
        if tracked != nil {
            tracked = nil
            onEnded?()
        }
    }
}

private final class PressureObserverView: UIView {
    let recognizer = PressureRecognizer(target: nil, action: nil)

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false // never intercepts SwiftUI's hit testing
        recognizer.referenceView = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // The recognizer lives on the window so it hears every touch, including ones SwiftUI's gestures are still deciding on.
    override func didMoveToWindow() {
        super.didMoveToWindow()
        recognizer.view?.removeGestureRecognizer(recognizer)
        window?.addGestureRecognizer(recognizer)
    }

    deinit {
        recognizer.view?.removeGestureRecognizer(recognizer)
    }
}

private struct PressureObserver: UIViewRepresentable {
    var hitFrame: CGRect? // only touches that start inside this frame (this view's coordinates) are reported
    var onBegan: (CGFloat) -> Void
    var onChanged: (CGFloat) -> Void
    var onEnded: () -> Void

    func makeUIView(context: Context) -> PressureObserverView {
        PressureObserverView()
    }

    func updateUIView(_ view: PressureObserverView, context: Context) {
        let recognizer = view.recognizer
        recognizer.hitFrame = hitFrame
        recognizer.onBegan = onBegan
        recognizer.onChanged = onChanged
        recognizer.onEnded = onEnded
    }
}

struct ClearSegmentedPicker: View {
    @Environment(\.isEnabled) private var isEnabled
    @Binding var selection: StatusEnum
    let options: [StatusEnum]
    var onAutoScroll: ((CGFloat) -> Void)?

    @State private var frames: [StatusEnum: CGRect] = [:]
    @State private var dragOffset: CGFloat = 0
    @State private var originX: CGFloat = 0 // this view's minX in the scroll view's viewport
    @State private var viewportWidth: CGFloat = 0
    @State private var isDragging = false
    @State private var isPressed = false // finger is down on the indicator (reported instantly by PressureObserver)
    @State private var pressure: CGFloat = 0 // 0...1
    @State private var hasMoved = false
    @State private var grabOffset: CGFloat = 0 // finger's x relative to the indicator's centre when grabbed
    @State private var fingerX: CGFloat = 0 // finger's x in the viewport
    @State private var edgeVelocity: CGFloat = 0 // -1...1, 0 when not near an edge

    private let space = "ClearSegmentedPicker"
    private let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    private let pressAnimation = Animation.spring(response: 0.18, dampingFraction: 0.75) // snappy, for touch-down
    private let edgeZone: CGFloat = 40
    private let maxAutoScrollSpeed: CGFloat = 12 // points per frame at the very edge
    private let expandedScale = CGSize(width: 1.3, height: 1.65) // indicator "lens" size at full pressure
    private let minExpansion: CGFloat = 0.6 // share of expandedScale you get on a feather-light touch
    private let lensPad: CGFloat = 16 // room around the labels for the expanded lens
    private let restLensStrength: CGFloat = 0 // no refraction while the solid capsule is showing
    private let pressedLensStrength: CGFloat = 1.0 // full edge refraction at full pressure
    private let idleIndicatorColor = Color(.systemGray) // solid capsule when not dragging
    private let dragGlassOpacity: CGFloat = 0.2 // opacity of the glass while pressed/dragging

    private var isActive: Bool { isPressed || isDragging }

    // 0 when idle. While touched it starts at minExpansion and rises to 1 with pressure.
    private var expansion: CGFloat {
        guard isActive else { return 0 }
        // If the press observer didn't fire (so there's no pressure reading), a drag still gets the full size.
        let effectivePressure = isPressed ? pressure : 1
        return minExpansion + (1 - minExpansion) * effectivePressure
    }

    // While dragging, the indicator is centred on the finger and its width blends
    // between the widths of the segments it is passing over.
    private var indicatorFrame: CGRect? {
        guard let frame = frames[selection] else { return nil }
        guard dragOffset != 0 else { return frame }
        let center = frame.midX + dragOffset
        let width = interpolatedWidth(at: center) ?? frame.width
        return CGRect(x: center - width / 2, y: frame.minY, width: width, height: frame.height)
    }

    // The indicator's frame including the pressed growth. The glass and the shader lens both use this,
    // and it is resized as a frame (not with scaleEffect) so the glass is re-rendered crisply at the new size.
    private var lensFrame: CGRect? {
        guard let frame = indicatorFrame else { return nil }
        let width = frame.width * (1 + (expandedScale.width - 1) * expansion)
        let height = frame.height * (1 + (expandedScale.height - 1) * expansion)
        return CGRect(x: frame.midX - width / 2, y: frame.midY - height / 2, width: width, height: height)
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

    private func label(for option: StatusEnum) -> some View {
        Button {
            selection = option
        } label: {
            Text(option.toString())
                .font(.system(size: 13, weight: .medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 5)
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .named(space))
        } action: { newFrame in
            if frames[option] != newFrame { frames[option] = newFrame }
        }
    }

    private var labelsRow: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                label(for: option)
            }
        }
    }

    // The gesture is measured in the scroll view's viewport space, so the finger position
    // stays meaningful while the content scrolls underneath it.
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .scrollView)
            .onChanged { value in
                guard let frame = frames[selection] else { return }
                if !isDragging {
                    withAnimation(pressAnimation) { isDragging = true }
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
                withAnimation(spring) { isDragging = false }
                hasMoved = false
                edgeVelocity = 0
                snapToNearest()
            }
    }

    @ViewBuilder
    private var labelsLayer: some View {
        if #available(iOS 26.0, *) {
            labelsRow
                .padding(lensPad)
                .modifier(LensRefraction(
                    rect: lensFrame ?? .zero,
                    strength: lensFrame == nil ? 0 : (isActive ? pressedLensStrength * expansion : restLensStrength),
                    pad: lensPad
                ))
                .padding(-lensPad)
        } else {
            labelsRow
        }
    }

    @ViewBuilder
    private var solidIndicator: some View {
        if #available(iOS 26.0, *), let frame = lensFrame {
            Capsule()
                .fill(idleIndicatorColor)
                .opacity(0.6)
                .frame(width: frame.width, height: frame.height)
                .offset(x: frame.minX, y: frame.minY)
                .opacity(isActive ? 0 : 1)
                .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private var indicatorOverlay: some View {
        ZStack(alignment: .topLeading) {
            // Always in the hierarchy and faded with opacity, so it doesn't have to be built when the finger lands.
            if #available(iOS 26.0, *), let frame = lensFrame {
                Color.clear
                    .glassEffect(.clear, in: Capsule())
                    .opacity(isActive ? dragGlassOpacity : 0)
                    .frame(width: frame.width, height: frame.height)
                    .offset(x: frame.minX, y: frame.minY)
                    .allowsHitTesting(false)
            }
            if let frame = indicatorFrame {
                Color.clear
                    .contentShape(Capsule())
                    .frame(width: frame.width, height: frame.height)
                    .offset(x: frame.minX, y: frame.minY)
                    .highPriorityGesture(dragGesture)
            }
        }
    }

    var body: some View {
        labelsLayer
            .background(alignment: .topLeading) { solidIndicator }
            .overlay(alignment: .topLeading) { indicatorOverlay }
            .background {
                PressureObserver(
                    hitFrame: isEnabled ? indicatorFrame : nil,
                    onBegan: { value in
                        withAnimation(pressAnimation) {
                            pressure = value
                            isPressed = true
                        }
                    },
                    onChanged: { value in
                        withAnimation(pressAnimation) { pressure = value }
                    },
                    onEnded: {
                        withAnimation(spring) {
                            isPressed = false
                            pressure = 0
                        }
                    }
                )
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
