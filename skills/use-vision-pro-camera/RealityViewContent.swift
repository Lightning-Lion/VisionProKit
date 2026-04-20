// Available when SwiftUI is imported with RealityKit
@available(visionOS 1.0, *)
@available(macOS, unavailable)
@available(macCatalyst, unavailable)
@available(iOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
extension RealityViewContent {

    /// The default view contents of a reality view, using reality view content.
    ///
    /// You don't create this type directly. ``RealityView`` creates values for
    /// you.
    @MainActor @preconcurrency public struct Body<Placeholder> : View where Placeholder : View {

        /// The content and behavior of the view.
        ///
        /// When you implement a custom view, you must implement a computed
        /// `body` property to provide the content for your view. Return a view
        /// that's composed of built-in views that SwiftUI provides, plus other
        /// composite views that you've already defined:
        ///
        ///     struct MyView: View {
        ///         var body: some View {
        ///             Text("Hello, World!")
        ///         }
        ///     }
        ///
        /// For more information about composing views and a view hierarchy,
        /// see <doc:Declaring-a-Custom-View>.
        @MainActor @preconcurrency public var body: some View { get }

        /// The type of view representing the body of this view.
        ///
        /// When you create a custom view, Swift infers this type from your
        /// implementation of the required ``View/body-swift.property`` property.
        @available(visionOS 1.0, *)
        @available(iOS, unavailable)
        @available(tvOS, unavailable)
        @available(watchOS, unavailable)
        @available(macOS, unavailable)
        @available(macCatalyst, unavailable)
        public typealias Body = some View
    }
}

// Available when SwiftUI is imported with RealityKit
/// An implicit animation closure that can be used in `RealityView.update`.
/// This function initiates an implicit animation *indirectly*, relying on a RealityView transaction
/// triggered when a SwiftUI animation is associated with a RealityView state change. The implicit
/// animation is applied to any animatable component properties that are changed in the closure body.
/// The following built-in RealityKit component types have properties that can be implicitly animated:
///
/// * Transform
/// * OpacityComponent
/// * ModelComponent
/// * ParticleEmitterComponent
/// * BillboardComponent
/// * DirectionalLightComponent
/// * PointLightComponent
/// * SpotLightComponent
///
/// The optional completion closure executes when the animation completes. The completion closure
/// for an interrupted animation executes if the animation is replaced by a new animation; however,
/// if the interrupted animation is combined so that it plays concurrently with the new animation
/// then the completion closure for the interrupted animation executes when the interrupted
/// animation completes.
@available(visionOS 26.0, *)
@available(macOS, unavailable)
@available(macCatalyst, unavailable)
@available(iOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
@MainActor extension RealityViewContent {

    @MainActor public func animate(body: () -> Void, completion: (() -> Void)? = nil)
}

// Available when SwiftUI is imported with RealityKit
@available(visionOS 1.0, *)
@available(macOS, unavailable)
@available(macCatalyst, unavailable)
@available(iOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
extension RealityViewContent : RealityCoordinateSpaceConverting, RealityCoordinateSpace {

    public func transform(from: some RealityCoordinateSpace, to: some CoordinateSpaceProtocol) -> AffineTransform3D

    public func transform(from: some CoordinateSpaceProtocol, to: some RealityCoordinateSpace) -> AffineTransform3D
}

// Available when SwiftUI is imported with RealityKit
@available(visionOS 1.0, *)
@available(macOS, unavailable)
@available(macCatalyst, unavailable)
@available(iOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
extension RealityViewContent.Body : Sendable {
}

// Available when SwiftUI is imported with RealityKit
/// A protocol representing the content of a reality view.
///
/// Do not interface with this protocol directly. Instead, use ``RealityViewContent``
/// with your ``RealityView``.
@available(visionOS 1.0, macOS 15.0, iOS 18.0, tvOS 26.0, *)
@available(watchOS, unavailable)
public protocol RealityViewContentProtocol {

    /// The type of collection used for `entities`.
    associatedtype Entities : EntityCollection

    /// A collection of RealityKit entities that this view content
    /// renders within the scene.
    var entities: Self.Entities { get nonmutating set }

    /// Subscribes to an event type, optionally limited to
    /// events affecting a source entity or scene,
    /// or a specific component type for component events.
    ///
    /// - Parameters:
    ///   - event: The event type to subscribe to.
    ///     For example, ``SceneEvents/Update`` or ``ComponentEvents/DidActivate``.
    ///   - sourceObject: An optional source for the event, such as an entity or a scene.
    ///     Set to `nil` to listen for all events of the event type within the ``RealityViewContent``.
    ///   - componentType: An optional component type to filter events to if the event is of the type ``ComponentEvents``.
    ///     Set to `nil` to listen for all events of the event type within the view content.
    ///   - handler: A closure that runs when the `event` occurs.
    ///
    /// - Returns: An object that represents the subscription to this event stream.
    func subscribe<E>(to event: E.Type, on sourceObject: (any EventSource)?, componentType: (any Component.Type)?, _ handler: @escaping (E) -> Void) -> EventSubscription where E : Event
}

// Available when SwiftUI is imported with RealityKit
@available(visionOS 1.0, macOS 15.0, iOS 18.0, tvOS 26.0, *)
@available(watchOS, unavailable)
extension RealityViewContentProtocol {

    /// Subscribes to an event type, optionally limited to
    /// events affecting a source entity or scene.
    ///
    /// - Parameters:
    ///   - event: The event type to subscribe to.
    ///     For example, ``SceneEvents/Update`` or ``ComponentEvents/DidActivate``.
    ///   - sourceObject: An optional source for the event, such as an entity or a scene.
    ///     Set to `nil` to listen for all events of the event type within the view content.
    ///   - handler: A closure that runs when the `event` occurs.
    ///
    /// - Returns: An object that represents the subscription to this event stream.
    public func subscribe<E>(to event: E.Type, on sourceObject: (any EventSource)?, _ handler: @escaping (E) -> Void) -> EventSubscription where E : Event

    /// Subscribes to an event type, optionally limited to
    /// a specific component type for component events.
    ///
    /// Events you can subscribe to including scene updates,
    /// ``SceneEvents/Update``, or when an animation
    /// ends, ``AnimationEvents/PlaybackCompleted``.
    ///
    /// - Parameters:
    ///   - event: The event type to subscribe to.
    ///     For example, ``SceneEvents/Update`` or ``ComponentEvents/DidActivate``.
    ///   - componentType: An optional component type to filter events to if the event is of the type ``ComponentEvents``.
    ///     Set to `nil` to listen for all events of the event type within the view content.
    ///   - handler: A closure that runs when the `event` occurs.
    ///
    /// - Returns: An object that represents the subscription to this event stream.
    public func subscribe<E>(to event: E.Type, componentType: (any Component.Type)? = nil, _ handler: @escaping (E) -> Void) -> EventSubscription where E : Event
}

// Available when SwiftUI is imported with RealityKit
@available(visionOS 1.0, macOS 15.0, iOS 18.0, tvOS 26.0, *)
@available(watchOS, unavailable)
extension RealityViewContentProtocol {

    /// Adds an entity to this content.
    public func add(_ entity: Entity)

    /// Removes an entity from this content, if present.
    public func remove(_ entity: Entity)
}