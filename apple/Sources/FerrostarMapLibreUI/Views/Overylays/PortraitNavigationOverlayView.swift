import FerrostarCore
import FerrostarSwiftUI
import MapKit
import MapLibre
import MapLibreSwiftDSL
import MapLibreSwiftUI
import SwiftUI

struct PortraitNavigationOverlayView<T: SpokenInstructionObserver & ObservableObject>: View,
    CustomizableNavigatingInnerGridView
{
    @Environment(\.navigationFormatterCollection) var formatterCollection: any FormatterCollection

    private let navigationState: NavigationState?

    @State private var isInstructionViewExpanded: Bool = false
    @State private var instructionsViewSizeWhenNotExpanded: CGSize = .zero

    var topCenter: (() -> AnyView)?
    var topTrailing: (() -> AnyView)?
    var midLeading: (() -> AnyView)?
    var bottomLeading: (() -> AnyView)?
    var bottomTrailing: (() -> AnyView)?

    var speedLimit: Measurement<UnitSpeed>?
    var speedLimitStyle: SpeedLimitView.SignageStyle?

    var showZoom: Bool
    var onZoomIn: () -> Void
    var onZoomOut: () -> Void

    var cameraControlState: CameraControlState

    var onTapExit: (() -> Void)?
    let currentRoadNameView: AnyView?

    let showMute: Bool
    let isMuted: Bool
    let onMute: () -> Void

    init(
        navigationState: NavigationState?,
        speedLimit: Measurement<UnitSpeed>? = nil,
        speedLimitStyle: SpeedLimitView.SignageStyle? = nil,
        isMuted: Bool,
        showMute: Bool = true,
        onMute: @escaping () -> Void,
        showZoom: Bool = false,
        onZoomIn: @escaping () -> Void = {},
        onZoomOut: @escaping () -> Void = {},
        cameraControlState: CameraControlState = .hidden,
        onTapExit: (() -> Void)? = nil,
        currentRoadNameView: AnyView?
    ) {
        self.navigationState = navigationState
        self.speedLimit = speedLimit
        self.speedLimitStyle = speedLimitStyle
        self.isMuted = isMuted
        self.showMute = showMute
        self.showZoom = showZoom
        self.onMute = onMute
        self.onZoomIn = onZoomIn
        self.onZoomOut = onZoomOut
        self.cameraControlState = cameraControlState
        self.onTapExit = onTapExit
        self.currentRoadNameView = currentRoadNameView
    }

    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                Spacer()

                // The inner content is displayed vertically full screen
                // when both the visualInstructions and progress are nil.
                // It will automatically reduce height if and when either
                // view appears
                NavigatingInnerGridView(
                    speedLimit: speedLimit,
                    speedLimitStyle: speedLimitStyle,
                    isMuted: isMuted,
                    showMute: showMute,
                    onMute: onMute,
                    showZoom: showZoom,
                    onZoomIn: onZoomIn,
                    onZoomOut: onZoomOut,
                    cameraControlState: cameraControlState
                )
                .innerGrid {
                    topCenter?()
                } topTrailing: {
                    topTrailing?()
                } midLeading: {
                    midLeading?()
                } bottomLeading: {
                    bottomLeading?()
                } bottomTrailing: {
                    bottomTrailing?()
                }

                if case .navigating = navigationState?.tripState,
                   let progress = navigationState?.currentProgress
                {
                    VStack {
                        if case .showRouteOverview = cameraControlState {
                            currentRoadNameView
                        }

                        TripProgressView(
                            progress: progress,
                            onTapExit: onTapExit
                        )
                    }
                }
            }
            .padding(.top, instructionsViewSizeWhenNotExpanded.height + 16)

            if case .navigating = navigationState?.tripState,
               let visualInstruction = navigationState?.currentVisualInstruction,
               let progress = navigationState?.currentProgress,
               let remainingSteps = navigationState?.remainingSteps
            {
                InstructionsView(
                    visualInstruction: visualInstruction,
                    distanceFormatter: formatterCollection.distanceFormatter,
                    distanceToNextManeuver: progress.distanceToNextManeuver,
                    remainingSteps: remainingSteps,
                    isExpanded: $isInstructionViewExpanded,
                    sizeWhenNotExpanded: $instructionsViewSizeWhenNotExpanded
                )
            }
        }
    }
}
