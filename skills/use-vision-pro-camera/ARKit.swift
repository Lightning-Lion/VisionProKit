import ARKit.accessory_tracking
import ARKit.anchor
import ARKit.authorization
import ARKit.barcode_detection
import ARKit.camera_frame_provider
import ARKit.camera_region
import ARKit.data
import ARKit.data_provider
import ARKit.environment_light_estimation
import ARKit.error
import ARKit.hand_skeleton
import ARKit.hand_tracking
import ARKit.identifiers
import ARKit.image_tracking
import ARKit.object
import ARKit.object_tracking
import ARKit.plane_detection
import ARKit.room_tracking
import ARKit.scene_reconstruction
import ARKit.session
import ARKit.shared_coordinate_space
import ARKit.skeleton_joint
import ARKit.stereo_properties
import ARKit.strings_collection
import ARKit.transform_correction
import ARKit.world_tracking
import Foundation
import GameController
import Network
import Spatial
import simd

/// An object which represents an ARKit coordinate space.
@available(visionOS 26.0, *)
public struct ARKitCoordinateSpace : CoordinateSpace3DFloat {

    /// Returns the parent space of this ARKit coordinate space.
    public var ancestorSpace: WorldReferenceCoordinateSpace? { get }

    /// Returns the transformation to ancestor space from this ARKit coordinate space.
    public func ancestorFromSpaceTransformFloat() -> ProjectiveTransform3DFloat

    /// A correction type to apply on coordinate spaces returned from ARKit APIs.
    @frozen public enum Correction : CustomStringConvertible {

        /// Coordinate spaces are unaltered and represent actual locations.
        case none

        /// Coordinate spaces are corrected to render over physical objects in passthrough displays.
        case rendered

        /// Textual description of this correction type.
        public var description: String { get }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: ARKitCoordinateSpace.Correction, b: ARKitCoordinateSpace.Correction) -> Bool

        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: In your implementation of `hash(into:)`,
        ///   don't call `finalize()` on the `hasher` instance provided,
        ///   or replace it with a different instance.
        ///   Doing so may become a compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher)

        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
        ///   The compiler provides an implementation for `hashValue` for you.
        public var hashValue: Int { get }
    }

    @available(visionOS 26.0, *)
    public typealias AncestorCoordinateSpace = WorldReferenceCoordinateSpace
}

@available(visionOS 26.0, *)
extension ARKitCoordinateSpace.Correction : Equatable {
}

@available(visionOS 26.0, *)
extension ARKitCoordinateSpace.Correction : Hashable {
}

@available(visionOS 26.0, *)
extension ARKitCoordinateSpace.Correction : Sendable {
}

@available(visionOS 26.0, *)
extension ARKitCoordinateSpace.Correction : BitwiseCopyable {
}

/// A session for running data providers.
@available(visionOS 1.0, macOS 26.0, *)
final public class ARKitSession : CustomStringConvertible, @unchecked Sendable {

    /// A session error.
    public struct Error : LocalizedError, CustomStringConvertible, @unchecked Sendable {

        /// The data provider which encountered an error (if any).
        public let dataProvider: (any DataProvider)?

        /// Enumeration of all session error codes.
        public enum Code : CustomStringConvertible {

            /// Data provider is lacking one or more authorizations.
            @available(macOS, unavailable)
            case dataProviderNotAuthorized

            /// Data provider failed to run.
            case dataProviderFailedToRun

            /// A textual representation of the code.
            public var description: String { get }

            /// Returns a Boolean value indicating whether two values are equal.
            ///
            /// Equality is the inverse of inequality. For any values `a` and `b`,
            /// `a == b` implies that `a != b` is `false`.
            ///
            /// - Parameters:
            ///   - lhs: A value to compare.
            ///   - rhs: Another value to compare.
            public static func == (a: ARKitSession.Error.Code, b: ARKitSession.Error.Code) -> Bool

            /// Hashes the essential components of this value by feeding them into the
            /// given hasher.
            ///
            /// Implement this method to conform to the `Hashable` protocol. The
            /// components used for hashing must be the same as the components compared
            /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
            /// with each of these components.
            ///
            /// - Important: In your implementation of `hash(into:)`,
            ///   don't call `finalize()` on the `hasher` instance provided,
            ///   or replace it with a different instance.
            ///   Doing so may become a compile-time error in the future.
            ///
            /// - Parameter hasher: The hasher to use when combining the components
            ///   of this instance.
            public func hash(into hasher: inout Hasher)

            /// The hash value.
            ///
            /// Hash values are not guaranteed to be equal across different executions of
            /// your program. Do not save hash values to use during a future execution.
            ///
            /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
            ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
            ///   The compiler provides an implementation for `hashValue` for you.
            public var hashValue: Int { get }
        }

        /// A localized message describing the reason for the failure.
        public var failureReason: String? { get }

        /// A localized message describing how one might recover from the failure.
        public var recoverySuggestion: String? { get }

        /// A localized message describing what error occurred.
        public var errorDescription: String? { get }

        /// The error code.
        public var code: ARKitSession.Error.Code { get }

        /// A textual representation of this error.
        public var description: String { get }
    }

    /// A list of all data providers on this session.
    @available(visionOS 26.0, macOS 26.0, *)
    final public var dataProviders: [any DataProvider] { get }

    /// Run a collection of data providers.
    /// - Parameters:
    ///   - dataProviders: The data providers to run.
    ///
    /// - Throws: `ARKitSession.Error`
    final public func run(_ dataProviders: [any DataProvider]) async throws

    /// Stop all data providers running in this session.
    final public func stop()

    /// Enumeration of possible session events.
    public enum Event : CustomStringConvertible, Sendable {

        /// Authorization changed.
        /// - Parameters:
        ///   - type: The authorization type which changed.
        ///   - status: The new status of this authorization.
        @available(macOS, unavailable)
        case authorizationChanged(type: ARKitSession.AuthorizationType, status: ARKitSession.AuthorizationStatus)

        /// An event that represents a state change of one or more of the data providers associated with a session.
        ///
        /// - Parameters:
        ///   - dataProviders: The data providers whose state has changed.
        ///   - newState: The new data provider state, which triggered the event.
        ///   - error: An `ARKitSession.Error` associated with the state change, if any. This is only applicable to `DataProviderState.stopped` updates.
        ///
        case dataProviderStateChanged(dataProviders: [any DataProvider], newState: DataProviderState, error: ARKitSession.Error?)

        /// A textual representation of ARKitSession.Event
        public var description: String { get }
    }

    /// An async sequence of events that can occur on this session.
    final public var events: ARKitSession.Events { get }

    /// A sequence of events.
    public struct Events : AsyncSequence {

        /// The type of element produced by this asynchronous sequence: ARKitSession.Event.
        public typealias Element = ARKitSession.Event

        /// Creates an asynchronous iterator that produces `Event` elements on this asynchronous sequence.
        ///
        /// - Returns: An Iterator for `Events`
        public func makeAsyncIterator() -> ARKitSession.Events.Iterator

        /// An iterator over a sequence of session events.
        public struct Iterator : AsyncIteratorProtocol {

            /// Asynchronously retrieve the next Event.
            ///
            /// - Returns: The next Event if one has occurred since the last call to this function.
            ///            Otherwise suspends the caller until a new Event has occurred.
            ///            Returns `nil` (signals end of the sequence) if the session has been stopped.
            public mutating func next() async -> ARKitSession.Events.Element?

            @available(visionOS 1.0, macOS 26.0, *)
            public typealias Element = ARKitSession.Events.Element
        }

        /// The type of asynchronous iterator that produces elements of this
        /// asynchronous sequence.
        @available(visionOS 1.0, macOS 26.0, *)
        public typealias AsyncIterator = ARKitSession.Events.Iterator
    }

    /// Create a new session.
    @available(macOS, unavailable)
    public convenience init()

    @objc deinit

    /// Query the current status of authorizations (without requesting them).
    /// - Parameters:
    ///   - authorizationTypes: The types of authorization to query.
    ///
    /// - Returns: A dictionary containing one or more authorization results.
    @available(macOS, unavailable)
    final public func queryAuthorization(for authorizationTypes: [ARKitSession.AuthorizationType]) async -> [ARKitSession.AuthorizationType : ARKitSession.AuthorizationStatus]

    /// Request one or more authorizations.
    /// - Parameters:
    ///   - authorizationTypes: The types of authorization to request.
    ///
    /// - Returns: A dictionary containing one or more authorization results.
    @available(macOS, unavailable)
    final public func requestAuthorization(for authorizationTypes: [ARKitSession.AuthorizationType]) async -> [ARKitSession.AuthorizationType : ARKitSession.AuthorizationStatus]

    /// Enumeration of all possible authorization types.
    public enum AuthorizationType : CustomStringConvertible, Sendable {

        /// Hand tracking.
        case handTracking

        /// World sensing.
        case worldSensing

        /// Accessory Tracking
        @available(visionOS 26.0, *)
        case accessoryTracking

        /// Camera access
        @available(visionOS 2.0, *)
        case cameraAccess

        /// A textual representation of AuthorizationType
        public var description: String { get }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: ARKitSession.AuthorizationType, b: ARKitSession.AuthorizationType) -> Bool

        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: In your implementation of `hash(into:)`,
        ///   don't call `finalize()` on the `hasher` instance provided,
        ///   or replace it with a different instance.
        ///   Doing so may become a compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher)

        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
        ///   The compiler provides an implementation for `hashValue` for you.
        public var hashValue: Int { get }
    }

    /// Enumeration of all possible authorization statuses.
    @available(macOS, unavailable)
    public enum AuthorizationStatus : CustomStringConvertible, Sendable {

        /// The user has not yet granted permission.
        case notDetermined

        /// The user has explicitly granted permission.
        case allowed

        /// The user has explicitly denied permission.
        case denied

        /// A textual representation of AuthorizationStatus
        public var description: String { get }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: ARKitSession.AuthorizationStatus, b: ARKitSession.AuthorizationStatus) -> Bool

        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: In your implementation of `hash(into:)`,
        ///   don't call `finalize()` on the `hasher` instance provided,
        ///   or replace it with a different instance.
        ///   Doing so may become a compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher)

        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
        ///   The compiler provides an implementation for `hashValue` for you.
        public var hashValue: Int { get }
    }

    /// A textual representation of this session.
    final public var description: String { get }
}

@available(visionOS 1.0, macOS 26.0, *)
extension ARKitSession.AuthorizationType : Equatable {
}

@available(visionOS 1.0, macOS 26.0, *)
extension ARKitSession.AuthorizationType : Hashable {
}

@available(visionOS 1.0, *)
@available(macOS, unavailable)
extension ARKitSession.AuthorizationStatus : Equatable {
}

@available(visionOS 1.0, *)
@available(macOS, unavailable)
extension ARKitSession.AuthorizationStatus : Hashable {
}

@available(visionOS 1.0, macOS 26.0, *)
extension ARKitSession.Error.Code : Equatable {
}

@available(visionOS 1.0, macOS 26.0, *)
extension ARKitSession.Error.Code : Hashable {
}

/// Represents an accessory to be tracked.
@available(visionOS 26.0, *)
@available(macOS, unavailable)
public struct Accessory : CustomStringConvertible, @unchecked Sendable, Equatable, Identifiable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Accessory, rhs: Accessory) -> Bool

    /// Location names to fetch transforms defined on accessories.
    /// Some pre-defined location names that are common to accessories conforming to the OpenXR spec
    /// are provided as a convenience. These are not required to exist on all accessories.
    public struct LocationName : CustomStringConvertible, RawRepresentable, Hashable, Codable, Sendable {

        /// The location name string.
        public let rawValue: String

        /// Init with label (required by RawRepresentable).
        public init(rawValue: String)

        /// Init without label provided as a convenience.
        public init(_ rawValue: String)

        /// Grip surface for spatial gamepads.
        public static let gripSurface: Accessory.LocationName

        /// Grip for spatial gamepads.
        public static let grip: Accessory.LocationName

        /// Aim point for spatial gamepads and styluses.
        public static let aim: Accessory.LocationName

        /// Textual representation of this location name.
        public var description: String { get }

        /// The raw type that can be used to represent all values of the conforming
        /// type.
        ///
        /// Every distinct value of the conforming type has a corresponding unique
        /// value of the `RawValue` type, but there may be values of the `RawValue`
        /// type that don't have a corresponding value of the conforming type.
        @available(visionOS 26.0, *)
        @available(macOS, unavailable)
        public typealias RawValue = String
    }

    /// The hand which an accessory corresponds to.
    public enum Chirality : CustomStringConvertible {

        /// Unspecified (non-handed accessory, not associated with a hand).
        case unspecified

        /// Left-handed accessory, or non-handed accessory held in left hand.
        case left

        /// Right-handed accessory, or non-handed accessory held in right hand.
        case right

        /// A textual representation of Chirality
        public var description: String { get }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: Accessory.Chirality, b: Accessory.Chirality) -> Bool

        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: In your implementation of `hash(into:)`,
        ///   don't call `finalize()` on the `hasher` instance provided,
        ///   or replace it with a different instance.
        ///   Doing so may become a compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher)

        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
        ///   The compiler provides an implementation for `hashValue` for you.
        public var hashValue: Int { get }
    }

    /// Type of source an Accessory was loaded from.
    public enum Source : CustomStringConvertible {

        /// Device this accessory was initialized with.
        case device(any GCDevice)

        /// A textual representation of this Accessory.Source.
        public var description: String { get }
    }

    /// Initializes an accessory from a GCDevice.
    /// - Parameters:
    ///   - device: GCDevice to initialize accessory from.
    ///
    /// - Throws: `AccessoryTrackingProvider.Error`
    public init(device: any GCDevice) async throws

    /// The unique identifier of this accessory.
    public var id: UUID { get }

    /// The hand that this accessory is designed to be held in.
    public var inherentChirality: Accessory.Chirality { get }

    /// The name of the accessory.
    public var name: String { get }

    /// A list of locations on this accessory for which coordinate transforms are provided.
    public var locations: [Accessory.LocationName] { get }

    /// The input source used to create this accessory.
    public var source: Accessory.Source { get }

    /// USDZ file representing this accessory, if present.
    public var usdzFile: URL? { get }

    /// A textual representation of this accessory.
    public var description: String { get }

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    @available(visionOS 26.0, *)
    @available(macOS, unavailable)
    public typealias ID = UUID
}

@available(visionOS 26.0, *)
@available(macOS, unavailable)
extension Accessory.Chirality : Equatable {
}

@available(visionOS 26.0, *)
@available(macOS, unavailable)
extension Accessory.Chirality : Hashable {
}

/// Represents a tracked accessory.
@available(visionOS 26.0, *)
@available(macOS, unavailable)
public struct AccessoryAnchor : TrackableAnchor, @unchecked Sendable, Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: AccessoryAnchor, rhs: AccessoryAnchor) -> Bool

    /// Tracking state of accessory anchors.
    public enum TrackingState : CustomStringConvertible {

        /// Neither position nor orientation are tracked.
        case untracked

        /// Orientation is tracked.
        case orientationTracked

        /// Both position and orientation are tracked.
        case positionOrientationTracked

        /// Both position and orientation are tracked, but with low accuracy.
        case positionOrientationTrackedLowAccuracy

        /// A textual representation of this instance.
        ///
        /// Calling this property directly is discouraged. Instead, convert an
        /// instance of any type to a string by using the `String(describing:)`
        /// initializer. This initializer works with any type, and uses the custom
        /// `description` property for types that conform to
        /// `CustomStringConvertible`:
        ///
        ///     struct Point: CustomStringConvertible {
        ///         let x: Int, y: Int
        ///
        ///         var description: String {
        ///             return "(\(x), \(y))"
        ///         }
        ///     }
        ///
        ///     let p = Point(x: 21, y: 30)
        ///     let s = String(describing: p)
        ///     print(s)
        ///     // Prints "(21, 30)"
        ///
        /// The conversion of `p` to a string in the assignment to `s` uses the
        /// `Point` type's `description` property.
        public var description: String { get }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: AccessoryAnchor.TrackingState, b: AccessoryAnchor.TrackingState) -> Bool

        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: In your implementation of `hash(into:)`,
        ///   don't call `finalize()` on the `hasher` instance provided,
        ///   or replace it with a different instance.
        ///   Doing so may become a compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher)

        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
        ///   The compiler provides an implementation for `hashValue` for you.
        public var hashValue: Int { get }
    }

    /// The unique identifier of this anchor.
    public var id: UUID { get }

    /// The anchor coordinate space.
    /// - Parameters
    ///   - correction: Correction type to apply.
    /// - Returns: The anchor coordinate space.
    public func coordinateSpace(correction: ARKitCoordinateSpace.Correction) -> ARKitCoordinateSpace

    /// The coordinate space of a location on this accessory.
    /// - Parameters
    ///   - location: The location name.
    ///   - correction: Correction type to apply.
    /// - Returns: The coordinate space of the location.
    public func coordinateSpace(for location: Accessory.LocationName, correction: ARKitCoordinateSpace.Correction) -> ARKitCoordinateSpace

    /// The transform from the accessory anchor to the origin coordinate system.
    public var originFromAnchorTransform: simd_float4x4 { get }

    /// Whether this anchor is currently tracked or not.
    public var isTracked: Bool { get }

    /// Tracking state of this anchor.
    public var trackingState: AccessoryAnchor.TrackingState { get }

    /// Accessory tracked by this anchor.
    public var accessory: Accessory { get }

    /// Which hand the accessory is currently held in. Returns nil if the accessory is not held.
    public var heldChirality: Accessory.Chirality? { get }

    /// Velocity of the accessory in the local coordinate system [m/s].
    public var velocity: SIMD3<Float> { get }

    /// Angular velocity of the accessory in the local coordinate system [rad/s].
    public var angularVelocity: SIMD3<Float> { get }

    /// A textual representation of this anchor.
    public var description: String { get }

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    @available(visionOS 26.0, *)
    @available(macOS, unavailable)
    public typealias ID = UUID
}

@available(visionOS 26.0, *)
@available(macOS, unavailable)
extension AccessoryAnchor.TrackingState : Equatable {
}

@available(visionOS 26.0, *)
@available(macOS, unavailable)
extension AccessoryAnchor.TrackingState : Hashable {
}

/// Provides the real time position of accessories in the user's environment.
@available(visionOS 26.0, *)
@available(macOS, unavailable)
final public class AccessoryTrackingProvider : DataProvider, @unchecked Sendable {

    /// An accessory tracking error.
    public struct Error : LocalizedError, CustomStringConvertible, @unchecked Sendable {

        /// Source for an accessory if creating it failed.
        public let source: Accessory.Source?

        /// Enumeration of all error codes.
        public enum Code : CustomStringConvertible {

            /// Loading an accessory failed.
            case accessoryLoadingFailed

            /// A textual representation of the code.
            public var description: String { get }

            /// Returns a Boolean value indicating whether two values are equal.
            ///
            /// Equality is the inverse of inequality. For any values `a` and `b`,
            /// `a == b` implies that `a != b` is `false`.
            ///
            /// - Parameters:
            ///   - lhs: A value to compare.
            ///   - rhs: Another value to compare.
            public static func == (a: AccessoryTrackingProvider.Error.Code, b: AccessoryTrackingProvider.Error.Code) -> Bool

            /// Hashes the essential components of this value by feeding them into the
            /// given hasher.
            ///
            /// Implement this method to conform to the `Hashable` protocol. The
            /// components used for hashing must be the same as the components compared
            /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
            /// with each of these components.
            ///
            /// - Important: In your implementation of `hash(into:)`,
            ///   don't call `finalize()` on the `hasher` instance provided,
            ///   or replace it with a different instance.
            ///   Doing so may become a compile-time error in the future.
            ///
            /// - Parameter hasher: The hasher to use when combining the components
            ///   of this instance.
            public func hash(into hasher: inout Hasher)

            /// The hash value.
            ///
            /// Hash values are not guaranteed to be equal across different executions of
            /// your program. Do not save hash values to use during a future execution.
            ///
            /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
            ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
            ///   The compiler provides an implementation for `hashValue` for you.
            public var hashValue: Int { get }
        }

        /// A localized message describing the reason for the failure.
        public var failureReason: String? { get }

        /// A localized message describing how one might recover from the failure.
        public var recoverySuggestion: String? { get }

        /// A localized message describing what error occurred.
        public var errorDescription: String? { get }

        /// The error code.
        public var code: AccessoryTrackingProvider.Error.Code { get }

        /// A textual representation of this error.
        public var description: String { get }
    }

    /// Create an accessory tracking provider.
    /// - Parameters:
    ///   - accessories: Accessories to track.
    ///
    /// - Returns: The accessory tracking provider.
    public convenience init(accessories: [Accessory])

    @objc deinit

    /// An async sequence of all anchor updates.
    final public var anchorUpdates: AnchorUpdateSequence<AccessoryAnchor> { get }

    /// The latest accessory anchors updated with the most recent inertial data.
    ///
    /// These anchors provide higher frequency, lower latency and slightly lower accuracy than `anchorUpdates`.
    /// Use them directly or in combination with `predictAnchor(for:at:)`.
    ///
    /// The array may be empty if the provider is not running or no accessory is tracked at the moment.
    final public var latestAnchors: [AccessoryAnchor] { get }

    /// Predict an accessory anchor to a target timestamp.
    ///
    /// - Note: A large time offset from latest anchor timestamp could degrade accuracy. For accuracy sensitive use cases like drawing, use a small offset or `latestAnchors`.
    ///         Use a prediction timestamp smaller than the latest anchor timestamp for interpolation.
    ///
    /// - Parameters:
    ///   - anchor: A tracked anchor from `latestAnchors` to generate prediction for.
    ///   - timestamp: Target time for prediction. For rendering use cases with CompositorServices, use `drawable.frameTiming.trackableAnchorPredictionTime`.
    ///
    /// - Returns: The predicted anchor, or nil if prediction failed.
    final public func predictAnchor(for anchor: AccessoryAnchor, at timestamp: TimeInterval) -> AccessoryAnchor?

    /// The state of this accessory tracking provider.
    final public var state: DataProviderState { get }

    /// Determines whether this device supports the accessory tracking provider.
    public static var isSupported: Bool { get }

    /// The authorization type(s) required by the accessory tracking provider.
    public static var requiredAuthorizations: [ARKitSession.AuthorizationType] { get }

    /// A textual representation of this accessory tracking provider.
    final public var description: String { get }
}

@available(visionOS 26.0, *)
@available(macOS, unavailable)
extension AccessoryTrackingProvider.Error.Code : Equatable {
}

@available(visionOS 26.0, *)
@available(macOS, unavailable)
extension AccessoryTrackingProvider.Error.Code : Hashable {
}

/// An anchor represents a physical location and orientation in world space.
@available(visionOS 1.0, macOS 26.0, *)
public protocol Anchor : CustomStringConvertible, Identifiable, Sendable {

    /// The unique identifier of this anchor.
    var id: UUID { get }

    /// The transform from the anchor to the origin coordinate system.
    /// Note: In other words, the position + orientation of this anchor in the origin coordinate system.
    var originFromAnchorTransform: simd_float4x4 { get }

    /// The timestamp of this anchor
    @available(visionOS 2.0, *)
    var timestamp: TimeInterval { get }
}

extension Anchor {

    /// The timestamp of this anchor
    @available(visionOS 2.0, macOS 26.0, *)
    public var timestamp: TimeInterval { get }
}

/// An update for an anchor with a timestamp & event which caused the update.
@available(visionOS 1.0, *)
@available(macOS, unavailable)
public struct AnchorUpdate<AnchorType> : CustomStringConvertible, @unchecked Sendable where AnchorType : Anchor {

    /// Event indicating if this anchor was added, updated, or removed.
    @frozen public enum Event : CustomStringConvertible, Sendable {

        /// The anchor was added.
        case added

        /// The anchor was updated.
        case updated

        /// The anchor was removed.
        case removed

        /// A textual representation of AnchorUpdate.Event
        public var description: String { get }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: AnchorUpdate<AnchorType>.Event, b: AnchorUpdate<AnchorType>.Event) -> Bool

        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: In your implementation of `hash(into:)`,
        ///   don't call `finalize()` on the `hasher` instance provided,
        ///   or replace it with a different instance.
        ///   Doing so may become a compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher)

        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
        ///   The compiler provides an implementation for `hashValue` for you.
        public var hashValue: Int { get }
    }

    /// The event which caused the anchor to update.
    public let event: AnchorUpdate<AnchorType>.Event

    /// The updated anchor.
    public let anchor: AnchorType

    /// The timestamp of this update.
    public var timestamp: TimeInterval { get }

    /// A textual representation of this update.
    public var description: String { get }
}

@available(visionOS 1.0, *)
@available(macOS, unavailable)
extension AnchorUpdate.Event : Equatable {
}

@available(visionOS 1.0, *)
@available(macOS, unavailable)
extension AnchorUpdate.Event : Hashable {
}

@available(visionOS 1.0, *)
@available(macOS, unavailable)
extension AnchorUpdate.Event : BitwiseCopyable {
}

/// A sequence of updated anchors.
@available(visionOS 1.0, *)
@available(macOS, unavailable)
public struct AnchorUpdateSequence<AnchorType> : AsyncSequence where AnchorType : Anchor {

    /// The type of element produced by this asynchronous sequence.
    public typealias Element = AnchorUpdate<AnchorType>

    /// Creates the asynchronous iterator that produces elements of this
    /// asynchronous sequence.
    ///
    /// - Returns: An instance of the `AsyncIterator` type used to produce
    /// elements of the asynchronous sequence.
    public func makeAsyncIterator() -> AnchorUpdateSequence<AnchorType>.Iterator<AnchorType>

    /// An iterator over a sequence of updated anchors.
    public struct Iterator<TypeOfAnchor> : AsyncIteratorProtocol, @unchecked Sendable where TypeOfAnchor : Anchor {

        public typealias Element = AnchorUpdate<TypeOfAnchor>

        /// Asynchronously advances to the next element and returns it, or ends the
        /// sequence if there is no next element.
        ///
        /// - Returns: The next element, if it exists, or `nil` to signal the end of
        ///   the sequence.
        public mutating func next() async -> AnchorUpdateSequence<AnchorType>.Iterator<TypeOfAnchor>.Element?
    }

    /// The type of asynchronous iterator that produces elements of this
    /// asynchronous sequence.
    @available(visionOS 1.0, *)
    @available(macOS, unavailable)
    public typealias AsyncIterator = AnchorUpdateSequence<AnchorType>.Iterator<AnchorType>
}

/// Represents a detected barcode.
@available(visionOS 2.0, *)
@available(macOS, unavailable)
public struct BarcodeAnchor : Anchor, @unchecked Sendable {

    /// Enumeration of possible symbologies of a detected barcode.
    public enum Symbology : CustomStringConvertible, Sendable {

        /// Aztec symbology. Decodable at 40 cm distance when greater than 2.0 cm wide.
        case aztec

        /// Codabar symbology. Decodable at 40 cm distance when greater than 5.5 cm wide.
        case codabar

        /// Code 39 symbology. Decodable at 40 cm distance when greater than 6.5 cm wide.
        case code39

        /// Code 39 Checksum symbology. Decodable at 40 cm distance when greater than 6.5 cm wide.
        case code39Checksum

        /// Code 39 Full ASCII symbology. Decodable at 40 cm distance when greater than 3.0 cm wide.
        case code39FullAscii

        /// Code 39 Full ASCII Checksum symbology. Decodable at 40 cm distance when greater than 4.5 cm wide.
        case code39FullAsciiChecksum

        /// Code 93 symbology. Decodable at 40 cm distance when greater than 5.0 cm wide.
        case code93

        /// Code 93i symbology. Decodable at 40 cm distance when greater than 5.0 cm wide.
        case code93i

        /// Code 128 symbology. Decodable at 40 cm distance when greater than 2.5 cm wide.
        case code128

        /// Data Matrix symbology. Decodable at 40 cm distance when greater than 1.0 cm wide.
        case dataMatrix

        /// EAN-8 symbology. Decodable at 40 cm distance when greater than 3.0 cm wide.
        case ean8

        /// EAN-13 symbology. Decodable at 40 cm distance when greater than 4.0 cm wide.
        case ean13

        /// GS1 Databar symbology. Decodable at 40 cm distance when greater than 3.0 cm wide.
        case gs1DataBar

        /// GS1 Databar Expanded symbology. Decodable at 40 cm distance when greater than 6.5 cm wide.
        case gs1DataBarExpanded

        /// GS1 Databar Limited symbology. Decodable at 40 cm distance when greater than 3.0 cm wide.
        case gs1DataBarLimited

        /// ITF symbology. Decodable at 40 cm distance when greater than 3.5 cm wide.
        case itf

        /// ITF-14 symbology. Decodable at 40 cm distance when greater than 5.0 cm wide.
        case itf14

        /// ITF Checksum symbology. Decodable at 40 cm distance when greater than 3.5 cm wide.
        case itfChecksum

        /// MicroPDF417 symbology. Decodable at 40 cm distance when greater than 6.5 cm wide.
        case microPDF417

        /// MicroQR symbology. Decodable at 40 cm distance when greater than 2.0 cm wide.
        case microQR

        /// MSIPlessey symbology. Decodable at 40 cm distance when greater than 4.5 cm wide.
        case msiPlessey

        /// PDF417 symbology. Decodable at 40 cm distance when greater than 6.0 cm wide.
        case pdf417

        /// QR symbology. Decodable at 40 cm distance when greater than 1.5 cm wide.
        case qr

        /// UPC-E symbology. Decodable at 40 cm distance when greater than 2.5 cm wide.
        case upce

        /// A textual representation of BarcodeAnchor.Symbology
        public var description: String { get }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: BarcodeAnchor.Symbology, b: BarcodeAnchor.Symbology) -> Bool

        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: In your implementation of `hash(into:)`,
        ///   don't call `finalize()` on the `hasher` instance provided,
        ///   or replace it with a different instance.
        ///   Doing so may become a compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher)

        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
        ///   The compiler provides an implementation for `hashValue` for you.
        public var hashValue: Int { get }
    }

    /// The symbology of the detected barcode.
    public var symbology: BarcodeAnchor.Symbology { get }

    /// The decoded payload string value of the detected barcode.
    public var payloadString: String? { get }

    /// The encoded payload data of the detected barcode.
    public var payloadData: Data { get }

    /// The extent of the detected barcode's bounding box.
    /// The width of the detected barcode is the length along the X-axis, prior to rotation about the Y-axis.
    /// The height of the detected barcode is the length along the Z-axis, prior to rotation about the Y-axis.
    public var extent: SIMD3<Float> { get }

    /// The unique identifier of this anchor.
    public var id: UUID { get }

    /// The transform from the barcode anchor to the origin coordinate system.
    public var originFromAnchorTransform: simd_float4x4 { get }

    /// A textual representation of this anchor.
    public var description: String { get }

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    @available(visionOS 2.0, *)
    @available(macOS, unavailable)
    public typealias ID = UUID
}

@available(visionOS 2.0, *)
@available(macOS, unavailable)
extension BarcodeAnchor.Symbology : Equatable {
}

@available(visionOS 2.0, *)
@available(macOS, unavailable)
extension BarcodeAnchor.Symbology : Hashable {
}

/// Provides the real time position of barcodes detected in the user's environment.
@available(visionOS 2.0, *)
@available(macOS, unavailable)
final public class BarcodeDetectionProvider : DataProvider, @unchecked Sendable {

    /// Create a barcode detection provider.
    /// - Parameters:
    ///   - symbologies: The barcode symbologies to look for.
    ///
    /// - Returns: The barcode detection provider.
    public init(symbologies: [BarcodeAnchor.Symbology])

    /// An async sequence of all anchor updates.
    final public var anchorUpdates: AnchorUpdateSequence<BarcodeAnchor> { get }

    /// The state of this barcode detection provider.
    final public var state: DataProviderState { get }

    /// Determines whether this device supports the barcode detection provider.
    public static var isSupported: Bool { get }

    /// The authorization type(s) required by the barcode detection provider.
    public static var requiredAuthorizations: [ARKitSession.AuthorizationType] { get }

    @objc deinit

    /// A textual representation of this barcode detection provider.
    final public var description: String { get }
}

/// A camera frame.
@available(visionOS 2.0, *)
@available(macOS, unavailable)
public struct CameraFrame : @unchecked Sendable, CustomStringConvertible, Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: CameraFrame, rhs: CameraFrame) -> Bool

    /// A camera frame sample.
    public struct Sample : @unchecked Sendable, CustomStringConvertible, Equatable {

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (lhs: CameraFrame.Sample, rhs: CameraFrame.Sample) -> Bool

        /// Frame parameters.
        public struct Parameters : @unchecked Sendable, CustomStringConvertible, Equatable {

            /// Returns a Boolean value indicating whether two values are equal.
            ///
            /// Equality is the inverse of inequality. For any values `a` and `b`,
            /// `a == b` implies that `a != b` is `false`.
            ///
            /// - Parameters:
            ///   - lhs: A value to compare.
            ///   - rhs: Another value to compare.
            public static func == (lhs: CameraFrame.Sample.Parameters, rhs: CameraFrame.Sample.Parameters) -> Bool

            /// The camera intrinsics.
            public var intrinsics: simd_float3x3 { get }

            /// The camera extrinsics.
            public var extrinsics: simd_float4x4 { get }

            /// The capture timestamp.
            public var captureTimestamp: TimeInterval { get }

            /// The mid exposure timestamp.
            public var midExposureTimestamp: TimeInterval { get }

            /// The white balance correlated color temperature in kelvin.
            public var colorTemperature: Int { get }

            /// The camera frame exposure duration in seconds.
            public var exposureDuration: TimeInterval { get }

            /// The camera type.
            public var cameraType: CameraFrameProvider.CameraType { get }

            /// The camera position.
            public var cameraPosition: CameraFrameProvider.CameraPosition { get }

            /// A textual representation of these camera frame parameters.
            public var description: String { get }
        }

        /// The pixel buffer.
        /// - Note: Please use the `buffer` instead.
        @available(visionOS, introduced: 2.0, deprecated: 26.0, renamed: "buffer")
        public var pixelBuffer: CVPixelBuffer { get }

        /// The pixel buffer.
        @available(visionOS 26.0, *)
        public var buffer: CVReadOnlyPixelBuffer { get }

        /// The parameters.
        public var parameters: CameraFrame.Sample.Parameters { get }

        /// A textual representation of this camera frame sample.
        public var description: String { get }
    }

    /// Get the camera frame sample for a given camera position.
    /// - Parameters:
    ///   - position: The camera position to get the sample for.
    ///
    /// - Returns: The camera frame sample, or nil if no sample is available for the given camera position.
    public func sample(for position: CameraFrameProvider.CameraPosition) -> CameraFrame.Sample?

    /// Get the primary frame sample for this camera frame.
    public var primarySample: CameraFrame.Sample { get }

    /// All the camera frame samples on this frame.
    @available(visionOS 26.0, *)
    public var samples: [CameraFrame.Sample] { get }

    /// A textual representation of this camera frame.
    public var description: String { get }
}

/// Provides you with camera frames.
///  An enterprise license and/or entitlement is required to receive camera frames, and will otherwise be a no-op.
@available(visionOS 2.0, *)
@available(macOS, unavailable)
final public class CameraFrameProvider : DataProvider, @unchecked Sendable {

    /// Enumeration of possible camera types.
    public enum CameraType : CustomStringConvertible, Sendable {

        /// Main camera
        case main

        /// A textual representation of CameraFrameProvider.CameraType.
        public var description: String { get }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: CameraFrameProvider.CameraType, b: CameraFrameProvider.CameraType) -> Bool

        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: In your implementation of `hash(into:)`,
        ///   don't call `finalize()` on the `hasher` instance provided,
        ///   or replace it with a different instance.
        ///   Doing so may become a compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher)

        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
        ///   The compiler provides an implementation for `hashValue` for you.
        public var hashValue: Int { get }
    }

    /// Enumeration of possible camera positions.
    public enum CameraPosition : CustomStringConvertible, Sendable {

        /// Left camera.
        case left

        /// Right camera.
        @available(visionOS 26.0, *)
        case right

        /// A textual representation of CameraFrameProvider.CameraPosition
        public var description: String { get }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: CameraFrameProvider.CameraPosition, b: CameraFrameProvider.CameraPosition) -> Bool

        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: In your implementation of `hash(into:)`,
        ///   don't call `finalize()` on the `hasher` instance provided,
        ///   or replace it with a different instance.
        ///   Doing so may become a compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher)

        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
        ///   The compiler provides an implementation for `hashValue` for you.
        public var hashValue: Int { get }
    }

    /// Enumeration of possible camera rectification types.
    @available(visionOS 26.0, *)
    public enum CameraRectification : CustomStringConvertible, Sendable {

        /// Mono camera rectification.
        case mono

        /// Stereo corrected camera rectification.
        case stereoCorrected

        /// A textual representation of CameraFrameProvider.CameraRectification.
        public var description: String { get }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: CameraFrameProvider.CameraRectification, b: CameraFrameProvider.CameraRectification) -> Bool

        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: In your implementation of `hash(into:)`,
        ///   don't call `finalize()` on the `hasher` instance provided,
        ///   or replace it with a different instance.
        ///   Doing so may become a compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher)

        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
        ///   The compiler provides an implementation for `hashValue` for you.
        public var hashValue: Int { get }
    }

    /// Create a camera frame provider.
    /// - Parameters:
    ///   - formats: The camera formats to use.
    ///
    /// - Returns: The camera frame provider.
    public init()

    @objc deinit

    /// Get a sequence of camera frame updates for a given video format.
    /// 
    ///  An enterprise license and/or entitlement is required to receive camera frames, and will otherwise be a no-op.
    ///
    /// - Parameters:
    ///   - cameraVideoFormat: The camera video format to get updates for.
    ///
    /// - Returns: The sequence of camera frame updates. Will return nil if the video format is not supported.
    final public func cameraFrameUpdates(for cameraVideoFormat: CameraVideoFormat) -> CameraFrameProvider.CameraFrameUpdates?

    /// A sequence of camera frames.
    public struct CameraFrameUpdates : AsyncSequence {

        /// The type of element produced by this asynchronous sequence: CameraFrame.
        public typealias Element = CameraFrame

        /// Creates an asynchronous iterator that produces `CameraFrame` elements on this asynchronous sequence.
        ///
        /// - Returns: An Iterator for `Events`
        public func makeAsyncIterator() -> CameraFrameProvider.CameraFrameUpdates.Iterator

        /// An iterator over a sequence of camera frames.
        public struct Iterator : AsyncIteratorProtocol {

            /// Asynchronously retrieve the next camera frame.
            ///
            /// - Returns: The next camera frame if one has been captured since the last call to this function.
            ///            Otherwise suspends the caller until a new camera frame has been captured.
            ///            Returns `nil` (signals end of the sequence) if the provider has been stopped.
            public mutating func next() async -> CameraFrameProvider.CameraFrameUpdates.Element?

            @available(visionOS 2.0, *)
            @available(macOS, unavailable)
            public typealias Element = CameraFrameProvider.CameraFrameUpdates.Element
        }

        /// The type of asynchronous iterator that produces elements of this
        /// asynchronous sequence.
        @available(visionOS 2.0, *)
        @available(macOS, unavailable)
        public typealias AsyncIterator = CameraFrameProvider.CameraFrameUpdates.Iterator
    }

    /// Determines whether this device supports the camera frame provider.
    public static var isSupported: Bool { get }

    /// The authorization type(s) required by the camera frame provider.
    public static var requiredAuthorizations: [ARKitSession.AuthorizationType] { get }

    /// The state of this camera frame provider.
    final public var state: DataProviderState { get }

    /// A textual representation of this camera frame provider.
    final public var description: String { get }
}

@available(visionOS 2.0, *)
@available(macOS, unavailable)
extension CameraFrameProvider.CameraType : Equatable {
}

@available(visionOS 2.0, *)
@available(macOS, unavailable)
extension CameraFrameProvider.CameraType : Hashable {
}

@available(visionOS 2.0, *)
@available(macOS, unavailable)
extension CameraFrameProvider.CameraPosition : Equatable {
}

@available(visionOS 2.0, *)
@available(macOS, unavailable)
extension CameraFrameProvider.CameraPosition : Hashable {
}

@available(visionOS 26.0, *)
@available(macOS, unavailable)
extension CameraFrameProvider.CameraRectification : Equatable {
}

@available(visionOS 26.0, *)
@available(macOS, unavailable)
extension CameraFrameProvider.CameraRectification : Hashable {
}

/// Represents a region in space to capture a camera stream of.
@available(visionOS 26.0, *)
@available(macOS, unavailable)
public struct CameraRegionAnchor : Anchor, @unchecked Sendable, Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: CameraRegionAnchor, rhs: CameraRegionAnchor) -> Bool

    /// Enhancements to be used with each anchor.
    public enum CameraEnhancement : CustomStringConvertible, Sendable {

        /// Simple crop/zoom.
        case stabilization

        /// Contrast and vibrancy enhancement in addition to simple crop/zoom.
        case contrastAndVibrancy

        /// A textual representation of the camera enhancement.
        public var description: String { get }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: CameraRegionAnchor.CameraEnhancement, b: CameraRegionAnchor.CameraEnhancement) -> Bool

        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: In your implementation of `hash(into:)`,
        ///   don't call `finalize()` on the `hasher` instance provided,
        ///   or replace it with a different instance.
        ///   Doing so may become a compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher)

        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
        ///   The compiler provides an implementation for `hashValue` for you.
        public var hashValue: Int { get }
    }

    /// The unique identifier of this anchor.
    public var id: UUID { get }

    /// A textual representation of this anchor.
    public var description: String { get }

    /// The transform from the anchor to the origin coordinate system.
    public var originFromAnchorTransform: simd_float4x4 { get }

    /// The width of the region, in meters. This is [-width/2, width/2] from the center.
    public var width: Float { get }

    /// The height of the region, in meters. This is [-height/2, height/2] from the center.
    public var height: Float { get }

    /// The enhancement applied to this anchor's pixel buffer.
    public var cameraEnhancement: CameraRegionAnchor.CameraEnhancement { get }

    /// The pixel buffer.
    /// Can be nil, e.g. for anchors which have not yet been added to the provider.
    public var pixelBuffer: CVReadOnlyPixelBuffer? { get }

    /// Initialize a camera region anchor.
    /// - Parameters:
    ///   - originFromAnchorTransform: The transform from the anchor to the origin coordinate system.
    ///   - width: The width of the region, in meters.
    ///   - height: The height of the region, in meters.
    ///   - cameraEnhancement: The camera enhancement used with this anchor. This will affect the frame rate of the output.
    public init(originFromAnchorTransform: simd_float4x4, width: Float, height: Float, cameraEnhancement: CameraRegionAnchor.CameraEnhancement)

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    @available(visionOS 26.0, *)
    @available(macOS, unavailable)
    public typealias ID = UUID
}

@available(visionOS 26.0, *)
@available(macOS, unavailable)
extension CameraRegionAnchor.CameraEnhancement : Equatable {
}

@available(visionOS 26.0, *)
@available(macOS, unavailable)
extension CameraRegionAnchor.CameraEnhancement : Hashable {
}

/// A camera region provider.
/// An enterprise license is required to use the CameraRegionProvider. The provider will not deliver any data without it. The app must include the following entitlement:
///     `com.apple.developer.arkit.camera-region.allow`
@available(visionOS 26.0, *)
@available(macOS, unavailable)
final public class CameraRegionProvider : DataProvider, @unchecked Sendable {

    /// A camera region error.
    public struct Error : LocalizedError, CustomStringConvertible, @unchecked Sendable {

        /// The data provider which encountered an error (if any).
        public let dataProvider: (any DataProvider)?

        /// Enumeration of all possible camera region error codes.
        public enum Code : CustomStringConvertible {

            /// Adding a camera region anchor failed.
            case addAnchorFailed

            /// Adding a camera region anchor failed - an upper limit was reached for this specific camera enhancement type.
            case anchorLimitReached

            /// Removing a camera region anchor failed.
            case removeAnchorFailed

            /// A textual representation of the code.
            public var description: String { get }

            /// Returns a Boolean value indicating whether two values are equal.
            ///
            /// Equality is the inverse of inequality. For any values `a` and `b`,
            /// `a == b` implies that `a != b` is `false`.
            ///
            /// - Parameters:
            ///   - lhs: A value to compare.
            ///   - rhs: Another value to compare.
            public static func == (a: CameraRegionProvider.Error.Code, b: CameraRegionProvider.Error.Code) -> Bool

            /// Hashes the essential components of this value by feeding them into the
            /// given hasher.
            ///
            /// Implement this method to conform to the `Hashable` protocol. The
            /// components used for hashing must be the same as the components compared
            /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
            /// with each of these components.
            ///
            /// - Important: In your implementation of `hash(into:)`,
            ///   don't call `finalize()` on the `hasher` instance provided,
            ///   or replace it with a different instance.
            ///   Doing so may become a compile-time error in the future.
            ///
            /// - Parameter hasher: The hasher to use when combining the components
            ///   of this instance.
            public func hash(into hasher: inout Hasher)

            /// The hash value.
            ///
            /// Hash values are not guaranteed to be equal across different executions of
            /// your program. Do not save hash values to use during a future execution.
            ///
            /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
            ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
            ///   The compiler provides an implementation for `hashValue` for you.
            public var hashValue: Int { get }
        }

        /// A localized message describing the reason for the failure.
        public var failureReason: String? { get }

        /// A localized message describing how one might recover from the failure.
        public var recoverySuggestion: String? { get }

        /// A localized message describing what error occurred.
        public var errorDescription: String? { get }

        /// The error code.
        public var code: CameraRegionProvider.Error.Code { get }

        /// A textual representation of this error.
        public var description: String { get }
    }

    /// Create a camera region provider.
    ///
    /// - Returns: The camera region provider.
    public init()

    @objc deinit

    /// Add a camera region anchor.
    ///
    /// - Parameters:
    ///   - anchor: The anchor to add.
    ///
    /// - Throws: `CameraRegionProvider.Error`
    ///
    /// - Note: This could fail if the maximum anchors for the given camera enhancement has been reached.
    final public func addAnchor(_ anchor: CameraRegionAnchor) async throws

    /// Remove a camera region anchor.
    ///
    /// - Parameters:
    ///   - anchor: The anchor to remove.
    ///
    /// - Throws: `CameraRegionProvider.Error`
    final public func removeAnchor(_ anchor: CameraRegionAnchor) async throws

    /// Remove an anchor with a given ID from camera region.
    ///
    /// - Parameters:
    ///   - id: ID of the camera region anchor to remove.
    ///
    /// - Throws: `CameraRegionProvider.Error`
    final public func removeAnchor(forID id: UUID) async throws

    /// An async sequence of anchor updates for a specific anchor.
    ///
    /// - Parameters:
    ///   - forID: ID of the camera region anchor to get updates for.
    ///
    /// - Returns: An async sequence of updates for the given anchor.
    final public func anchorUpdates(forID id: UUID) -> AnchorUpdateSequence<CameraRegionAnchor>

    /// Determines whether this device supports the camera region provider.
    public static var isSupported: Bool { get }

    /// The authorization type(s) required by the camera region provider.
    public static var requiredAuthorizations: [ARKitSession.AuthorizationType] { get }

    /// The state of this camera region provider.
    final public var state: DataProviderState { get }

    /// A textual representation of this camera region provider.
    final public var description: String { get }
}

@available(visionOS 26.0, *)
@available(macOS, unavailable)
extension CameraRegionProvider.Error.Code : Equatable {
}

@available(visionOS 26.0, *)
@available(macOS, unavailable)
extension CameraRegionProvider.Error.Code : Hashable {
}

/// A camera video format.
@available(visionOS 2.0, *)
@available(macOS, unavailable)
public struct CameraVideoFormat : @unchecked Sendable, CustomStringConvertible, Equatable, Hashable {

    /// The minimum frame duration for this video format.
    public var minFrameDuration: Float { get }

    /// The maximum frame duration for this video format.
    public var maxFrameDuration: Float { get }

    /// The frame size for this video format.
    public var frameSize: CGSize { get }

    /// The pixel format for this video format.
    public var pixelFormat: OSType { get }

    /// The camera type for this video format.
    public var cameraType: CameraFrameProvider.CameraType { get }

    /// The camera positions for this video format.
    public var cameraPositions: [CameraFrameProvider.CameraPosition] { get }

    /// The camera rectification for this video format.
    @available(visionOS 26.0, *)
    public var cameraRectification: CameraFrameProvider.CameraRectification { get }

    /// A textual representation of this camera video format.
    public var description: String { get }

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: CameraVideoFormat, rhs: CameraVideoFormat) -> Bool

    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: In your implementation of `hash(into:)`,
    ///   don't call `finalize()` on the `hasher` instance provided,
    ///   or replace it with a different instance.
    ///   Doing so may become a compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    public func hash(into hasher: inout Hasher)

    /// Get the video formats supported by a given camera type.
    /// - Parameters:
    ///   - cameraType: The camera type.
    ///   - cameraPositions: The inclusive set of camera positions that the video formats must match.
    ///
    /// - Returns: The video formats supported by the given camera type
    public static func supportedVideoFormats(for cameraType: CameraFrameProvider.CameraType, cameraPositions: [CameraFrameProvider.CameraPosition]) -> [CameraVideoFormat]

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    ///   The compiler provides an implementation for `hashValue` for you.
    public var hashValue: Int { get }
}

/// A data provider is an interface for receiving data from ARKit.
///
/// Most data providers offer an async sequence which you can iterate over to receive data (updated anchors).
@available(visionOS 1.0, macOS 26.0, *)
public protocol DataProvider : AnyObject, CustomStringConvertible, Sendable {

    /// Determines whether this device supports this data provider.
    static var isSupported: Bool { get }

    /// The authorization type(s) required by this data provider.
    static var requiredAuthorizations: [ARKitSession.AuthorizationType] { get }

    /// The state of this data provider.
    var state: DataProviderState { get }
}

/// The state of a data provider.
@available(visionOS 1.0, macOS 26.0, *)
public enum DataProviderState : CustomStringConvertible, Sendable {

    /// The data provider is initialized.
    case initialized

    /// The data provider is paused.
    case paused

    /// The data provider is running.
    case running

    /// The data provider has been stopped.
    case stopped

    /// A textual representation of the state.
    public var description: String { get }

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: DataProviderState, b: DataProviderState) -> Bool

    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: In your implementation of `hash(into:)`,
    ///   don't call `finalize()` on the `hasher` instance provided,
    ///   or replace it with a different instance.
    ///   Doing so may become a compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    public func hash(into hasher: inout Hasher)

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    ///   The compiler provides an implementation for `hashValue` for you.
    public var hashValue: Int { get }
}

@available(visionOS 1.0, macOS 26.0, *)
extension DataProviderState : Equatable {
}

@available(visionOS 1.0, macOS 26.0, *)
extension DataProviderState : Hashable {
}

/// Represents the Vision device which the user is wearing.
@available(visionOS 1.0, macOS 26.0, *)
public struct DeviceAnchor : TrackableAnchor, @unchecked Sendable {

    /// The unique identifier of this anchor.
    public var id: UUID { get }

    /// The transform from the device anchor to the origin coordinate system.
    public var originFromAnchorTransform: simd_float4x4 { get }

    /// Whether this device anchor is currently tracked or not.
    public var isTracked: Bool { get }

    /// Tracking state of this anchor
    @available(visionOS 2.0, *)
    public var trackingState: DeviceAnchor.TrackingState { get }

    /// A textual representation of this anchor.
    public var description: String { get }

    /// Tracking states of a device anchor.
    @available(visionOS 2.0, *)
    public enum TrackingState : CustomStringConvertible, Sendable {

        /// The anchor is not tracked.
        case untracked

        /// Only orientation is currently tracked.
        case orientationTracked

        /// Both position and orientation are currently tracked.
        case tracked

        /// A textual representation of this instance.
        ///
        /// Calling this property directly is discouraged. Instead, convert an
        /// instance of any type to a string by using the `String(describing:)`
        /// initializer. This initializer works with any type, and uses the custom
        /// `description` property for types that conform to
        /// `CustomStringConvertible`:
        ///
        ///     struct Point: CustomStringConvertible {
        ///         let x: Int, y: Int
        ///
        ///         var description: String {
        ///             return "(\(x), \(y))"
        ///         }
        ///     }
        ///
        ///     let p = Point(x: 21, y: 30)
        ///     let s = String(describing: p)
        ///     print(s)
        ///     // Prints "(21, 30)"
        ///
        /// The conversion of `p` to a string in the assignment to `s` uses the
        /// `Point` type's `description` property.
        public var description: String { get }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: DeviceAnchor.TrackingState, b: DeviceAnchor.TrackingState) -> Bool

        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: In your implementation of `hash(into:)`,
        ///   don't call `finalize()` on the `hasher` instance provided,
        ///   or replace it with a different instance.
        ///   Doing so may become a compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher)

        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
        ///   The compiler provides an implementation for `hashValue` for you.
        public var hashValue: Int { get }
    }

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    @available(visionOS 1.0, macOS 26.0, *)
    public typealias ID = UUID
}

@available(macOS 26.0, visionOS 2.0, *)
extension DeviceAnchor.TrackingState : Equatable {
}

@available(macOS 26.0, visionOS 2.0, *)
extension DeviceAnchor.TrackingState : Hashable {
}

/// An environment light estimation provider.
@available(visionOS 2.0, *)
@available(macOS, unavailable)
final public class EnvironmentLightEstimationProvider : DataProvider, @unchecked Sendable {

    /// Create an environment light estimation provider.
    ///
    /// - Returns: The environment light estimation provider.
    @available(visionOS 2.0, *)
    public convenience init()

    @objc deinit

    /// The state of this environment light estimation provider.
    final public var state: DataProviderState { get }

    /// Determines whether this device supports the environment light estimation provider.
    public static var isSupported: Bool { get }

    /// The authorization type(s) required by the environment light estimation provider.
    public static var requiredAuthorizations: [ARKitSession.AuthorizationType] { get }

    /// An async sequence of all anchor updates.
    final public var anchorUpdates: AnchorUpdateSequence<EnvironmentProbeAnchor> { get }

    /// A textual representation of this environment light estimation provider.
    final public var description: String { get }
}

/// Represents an environment probe in the world.
/// @note The anchor is always positioned at the location of the Vision Pro device.
/// @discussion Environment probes are used to light virtual geometry by producing environment
/// textures from the probe's location in the world.
@available(visionOS 2.0, *)
@available(macOS, unavailable)
public struct EnvironmentProbeAnchor : Anchor, @unchecked Sendable, Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    @available(visionOS 2.0, *)
    public static func == (lhs: EnvironmentProbeAnchor, rhs: EnvironmentProbeAnchor) -> Bool

    /// The unique identifier of this anchor.
    public var id: UUID { get }

    /// The transform from the environment probe anchor to the origin coordinate system.
    public var originFromAnchorTransform: simd_float4x4 { get }

    /// The environment texture of this anchor.
    /// The texture stores floating point linear high-dynamic range rgb values in P3 color space.
    /// Textures could be nil if the person is not in a well-lit environment.
    public var environmentTexture: (any MTLTexture)? { get }

    /// The camera scale reference of this anchor.
    ///
    /// Returns the camera scale reference of a pixel with rgb value [1,1,1] in the environment texture.
    ///
    /// In order to have a consistent brightness between texture updates, the cameraScaleReference allows you to translate the local brightness from the current environment texture to the absolute brightness range from the camera.
    @available(visionOS 2.0, *)
    public var cameraScaleReference: Float { get }

    /// A textual representation of this anchor.
    public var description: String { get }

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    @available(visionOS 2.0, *)
    @available(macOS, unavailable)
    public typealias ID = UUID
}

/// A container for index data, such as vertex indices of a face.
@available(visionOS 1.0, *)
@available(macOS, unavailable)
public struct GeometryElement : CustomStringConvertible, @unchecked Sendable {

    /// Enumeration of possible geometry primitive types.
    public enum Primitive : CustomStringConvertible, Sendable {

        /// Two vertices that connect to form a line.
        case line

        /// Three vertices that connect to form a triangle.
        case triangle

        /// The number of indices for the `Primitive`.
        public var indexCount: Int { get }

        /// A textual representation of GeometryElement.Primitive
        public var description: String { get }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: GeometryElement.Primitive, b: GeometryElement.Primitive) -> Bool

        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: In your implementation of `hash(into:)`,
        ///   don't call `finalize()` on the `hasher` instance provided,
        ///   or replace it with a different instance.
        ///   Doing so may become a compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher)

        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
        ///   The compiler provides an implementation for `hashValue` for you.
        public var hashValue: Int { get }
    }

    /// Get a Metal buffer containing index data that defines the geometry.
    public var buffer: any MTLBuffer { get }

    /// Get the number of primitives in the buffer.
    public var count: Int { get }

    /// Get the number of bytes that represent an index value.
    public var bytesPerIndex: Int { get }

    /// Get the type of the geometry element.
    public var primitive: GeometryElement.Primitive { get }

    /// A textual representation of this geometry element.
    public var description: String { get }
}

@available(visionOS 2.0, *)
@available(macOS, unavailable)
extension GeometryElement : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: GeometryElement, rhs: GeometryElement) -> Bool
}

@available(visionOS 1.0, *)
@available(macOS, unavailable)
extension GeometryElement.Primitive : Equatable {
}

@available(visionOS 1.0, *)
@available(macOS, unavailable)
extension GeometryElement.Primitive : Hashable {
}

/// A container for vector data of a geometry.
@available(visionOS 1.0, *)
@available(macOS, unavailable)
public struct GeometrySource : CustomStringConvertible, @unchecked Sendable {

    /// Get a Metal buffer containing per-vector data for the source.
    public var buffer: any MTLBuffer { get }

    /// Get the number of vectors in the source.
    public var count: Int { get }

    /// Get the type of per-vector data in the buffer.
    public var format: MTLVertexFormat { get }

    /// Get the number of scalar components in each vector.
    public var componentsPerVector: Int { get }

    /// Get the offset (in bytes) from the beginning of the buffer.
    public var offset: Int { get }

    /// Get the number of bytes from a vector to the next one in the buffer.
    public var stride: Int { get }

    /// A textual representation of this geometry source.
    public var description: String { get }
}

@available(visionOS 2.0, *)
@available(macOS, unavailable)
extension GeometrySource : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: GeometrySource, rhs: GeometrySource) -> Bool
}

/// Represents a hand of the user.
@available(visionOS 1.0, *)
@available(macOS, unavailable)
public struct HandAnchor : TrackableAnchor, @unchecked Sendable {

    /// Enumeration to distinguish between left and right hands.
    @frozen public enum Chirality : CustomStringConvertible, Sendable {

        /// The right hand.
        case right

        /// The left hand.
        case left

        /// A textual representation of HandAnchor.Chirality
        public var description: String { get }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: HandAnchor.Chirality, b: HandAnchor.Chirality) -> Bool

        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: In your implementation of `hash(into:)`,
        ///   don't call `finalize()` on the `hasher` instance provided,
        ///   or replace it with a different instance.
        ///   Doing so may become a compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher)

        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
        ///   The compiler provides an implementation for `hashValue` for you.
        public var hashValue: Int { get }
    }

    /// Enumeration to distinguish hand fidelity
    @available(visionOS 26.0, *)
    public enum Fidelity : CustomStringConvertible, Sendable {

        /// Nominal fidelity.
        case nominal

        /// High fidelity.
        case high

        /// A textual representation of HandAnchor.Fidelity
        public var description: String { get }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: HandAnchor.Fidelity, b: HandAnchor.Fidelity) -> Bool

        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: In your implementation of `hash(into:)`,
        ///   don't call `finalize()` on the `hasher` instance provided,
        ///   or replace it with a different instance.
        ///   Doing so may become a compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher)

        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
        ///   The compiler provides an implementation for `hashValue` for you.
        public var hashValue: Int { get }
    }

    /// The unique identifier of this anchor.
    public var id: UUID { get }

    /// The transform from the hand's wrist to the origin coordinate system.
    public var originFromAnchorTransform: simd_float4x4 { get }

    /// The skeleton of this hand.
    public var handSkeleton: HandSkeleton? { get }

    /// The chirality of this hand.
    public var chirality: HandAnchor.Chirality { get }

    /// The fidelity of this hand.
    @available(visionOS 26.0, *)
    public var fidelity: HandAnchor.Fidelity { get }

    /// Whether this hand anchor is currently tracked or not.
    public var isTracked: Bool { get }

    /// A textual representation of this anchor.
    public var description: String { get }

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    @available(visionOS 1.0, *)
    @available(macOS, unavailable)
    public typealias ID = UUID
}

@available(visionOS 2.0, *)
@available(macOS, unavailable)
extension HandAnchor : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: HandAnchor, rhs: HandAnchor) -> Bool
}

@available(visionOS 1.0, *)
@available(macOS, unavailable)
extension HandAnchor.Chirality : Equatable {
}

@available(visionOS 1.0, *)
@available(macOS, unavailable)
extension HandAnchor.Chirality : Hashable {
}

@available(visionOS 1.0, *)
@available(macOS, unavailable)
extension HandAnchor.Chirality : BitwiseCopyable {
}

@available(visionOS 26.0, *)
@available(macOS, unavailable)
extension HandAnchor.Fidelity : Equatable {
}

@available(visionOS 26.0, *)
@available(macOS, unavailable)
extension HandAnchor.Fidelity : Hashable {
}

/// A hand skeleton.
@available(visionOS 1.0, *)
@available(macOS, unavailable)
public struct HandSkeleton : CustomStringConvertible, @unchecked Sendable {

    /// Get the skeleton of a hand in a neutral pose.
    public static var neutralPose: HandSkeleton { get }

    /// Get the joint of a given name.
    /// - Parameters:
    ///   - named: The joint name
    ///
    /// - Returns: The joint
    public func joint(_ named: HandSkeleton.JointName) -> HandSkeleton.Joint

    /// A textual representation of this Skeleton.
    public var description: String { get }

    /// All joints of this skeleton.
    public var allJoints: [HandSkeleton.Joint] { get }
}

@available(visionOS 2.0, *)
@available(macOS, unavailable)
extension HandSkeleton : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: HandSkeleton, rhs: HandSkeleton) -> Bool
}

@available(visionOS 1.0, *)
@available(macOS, unavailable)
extension HandSkeleton {

    /// A joint in a hand skeleton.
    @available(visionOS 1.0, *)
    public struct Joint : CustomStringConvertible, @unchecked Sendable {

        /// The parent joint of this joint.
        /// Note: The root joint has no parent.
        public var parentJoint: HandSkeleton.Joint? { get }

        /// The name of this joint.
        public var name: HandSkeleton.JointName { get }

        /// The transform from the joint to the parent joint coordinate system.
        /// Note: The root joint's parentFromJointTransform is an identity matrix.
        public var parentFromJointTransform: simd_float4x4 { get }

        /// The transform from the joint to the hand anchor coordinate system.
        public var anchorFromJointTransform: simd_float4x4 { get }

        /// The tracking status of this joint.
        public var isTracked: Bool { get }

        /// A textual representation of this joint.
        public var description: String { get }
    }

    /// A collection of names for hand skeleton joints.
    @available(visionOS 1.0, *)
    public enum JointName : CaseIterable, CustomStringConvertible, Hashable, @unchecked Sendable {

        /// The wrist joint of a hand skeleton.
        case wrist

        /// The thumb knuckle joint of a hand skeleton.
        case thumbKnuckle

        /// The thumb intermediate base joint of a hand skeleton.
        case thumbIntermediateBase

        /// The thumb intermediate tip joint of a hand skeleton.
        case thumbIntermediateTip

        /// The thumb tip joint of a hand skeleton.
        case thumbTip

        /// The index finger metacarpal joint of a hand skeleton.
        case indexFingerMetacarpal

        /// The index finger knuckle joint of a hand skeleton.
        case indexFingerKnuckle

        /// The index finger intermediate base joint of a hand skeleton.
        case indexFingerIntermediateBase

        /// The index finger intermediate tip joint of a hand skeleton.
        case indexFingerIntermediateTip

        /// The index finger tip joint of a hand skeleton.
        case indexFingerTip

        /// The middle finger metacarpal joint of a hand skeleton.
        case middleFingerMetacarpal

        /// The middle finger knuckle joint of a hand skeleton.
        case middleFingerKnuckle

        /// The middle finger intermediate base joint of a hand skeleton.
        case middleFingerIntermediateBase

        /// The middle finger intermediate tip joint of a hand skeleton.
        case middleFingerIntermediateTip

        /// The middle finger tip joint of a hand skeleton.
        case middleFingerTip

        /// The ring finger metacarpal joint of a hand skeleton.
        case ringFingerMetacarpal

        /// The ring finger knuckle joint of a hand skeleton.
        case ringFingerKnuckle

        /// The ring finger intermediate base joint of a hand skeleton.
        case ringFingerIntermediateBase

        /// The ring finger intermediate tip joint of a hand skeleton.
        case ringFingerIntermediateTip

        /// The ring finger tip joint of a hand skeleton.
        case ringFingerTip

        /// The little finger metacarpal joint of a hand skeleton.
        case littleFingerMetacarpal

        /// The little finger knuckle joint of a hand skeleton.
        case littleFingerKnuckle

        /// The little finger intermediate base joint of a hand skeleton.
        case littleFingerIntermediateBase

        /// The little finger intermediate tip joint of a hand skeleton.
        case littleFingerIntermediateTip

        /// The little finger tip joint of a hand skeleton.
        case littleFingerTip

        /// The wrist joint at the forearm of a hand skeleton.
        case forearmWrist

        /// The forearm joint of a hand skeleton.
        case forearmArm

        /// A textual representation of this joint name.
        public var description: String { get }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: HandSkeleton.JointName, b: HandSkeleton.JointName) -> Bool

        /// A type that can represent a collection of all values of this type.
        @available(visionOS 1.0, *)
        @available(macOS, unavailable)
        public typealias AllCases = [HandSkeleton.JointName]

        /// A collection of all values of this type.
        nonisolated public static var allCases: [HandSkeleton.JointName] { get }

        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: In your implementation of `hash(into:)`,
        ///   don't call `finalize()` on the `hasher` instance provided,
        ///   or replace it with a different instance.
        ///   Doing so may become a compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher)

        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
        ///   The compiler provides an implementation for `hashValue` for you.
        public var hashValue: Int { get }
    }
}

@available(visionOS 2.0, *)
@available(macOS, unavailable)
extension HandSkeleton.Joint : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: HandSkeleton.Joint, rhs: HandSkeleton.Joint) -> Bool
}

/// Provides you with data about the user's hands.
@available(visionOS 1.0, *)
@available(macOS, unavailable)
final public class HandTrackingProvider : DataProvider, @unchecked Sendable {

    /// Get the latest left and right hand anchors in a tuple.
    /// The anchors in the returned tuple will be nil if the provider is not running.
    ///
    /// @note: For apps compiled against visionOS 1.0 SDK, the returned anchors will also be nil if the hand anchor was not updated since you last accessed this variable.
    final public var latestAnchors: (leftHand: HandAnchor?, rightHand: HandAnchor?) { get }

    /// The state of this hand tracking provider.
    final public var state: DataProviderState { get }

    /// Create a hand tracking provider.
    ///
    /// - Returns: The hand tracking provider.
    public init()

    /// Determines whether this device supports the hand tracking provider.
    public static var isSupported: Bool { get }

    /// The authorization type(s) required by the hand tracking provider.
    public static var requiredAuthorizations: [ARKitSession.AuthorizationType] { get }

    @objc deinit

    /// An async sequence of all anchor updates.
    final public var anchorUpdates: AnchorUpdateSequence<HandAnchor> { get }

    /// Query for hand anchors given a target timestamp.
    /// - note: This function isn’t thread-safe; if you call this function on multiple threads at the same time, you must provide your own synchronization.
    /// Obtain the `timestamp` you provide to this function from `trackableAnchorPredictionTime` in `LayerRenderer.Frame.Timing`.
    /// - Parameters:
    ///   - timestamp: Target timestamp, mach absolute time in seconds.
    /// - returns: A tuple containing optional left and right anchors for the given time. Anchors will be nil if the hand tracking provider isn't running.
    @available(visionOS 2.0, *)
    final public func handAnchors(at timestamp: TimeInterval) -> (leftHand: HandAnchor?, rightHand: HandAnchor?)

    /// A textual representation of this hand tracking provider.
    final public var description: String { get }
}

/// Represents a tracked image.
@available(visionOS 1.0, *)
@available(macOS, unavailable)
public struct ImageAnchor : TrackableAnchor, @unchecked Sendable {

    /// The unique identifier of this anchor.
    public var id: UUID { get }

    /// The transform from the image anchor to the origin coordinate system.
    public var originFromAnchorTransform: simd_float4x4 { get }

    /// The estimated scale factor between the image's physical size and provided size.
    public var estimatedScaleFactor: Float { get }

    /// Whether this image anchor is currently tracked or not.
    public var isTracked: Bool { get }

    /// The reference image which this anchor corresponds to.
    public var referenceImage: ReferenceImage { get }

    /// A textual representation of this anchor.
    public var description: String { get }

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    @available(visionOS 1.0, *)
    @available(macOS, unavailable)
    public typealias ID = UUID
}

@available(visionOS 2.0, *)
@available(macOS, unavailable)
extension ImageAnchor : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: ImageAnchor, rhs: ImageAnchor) -> Bool
}

/// Provides the real time position of reference images in the user's environment.
@available(visionOS 1.0, *)
@available(macOS, unavailable)
final public class ImageTrackingProvider : DataProvider, @unchecked Sendable {

    /// The state of this image tracking provider.
    final public var state: DataProviderState { get }

    /// Create an image tracking provider.
    /// - Parameters:
    ///   - referenceImages: The reference images to look for.
    ///
    /// - Returns: The image tracking provider.
    public init(referenceImages: [ReferenceImage])

    /// Get all the image anchors
    @available(visionOS 2.0, *)
    final public var allAnchors: [ImageAnchor] { get }

    /// Determines whether this device supports the image tracking provider.
    public static var isSupported: Bool { get }

    /// The authorization type(s) required by the image tracking provider.
    public static var requiredAuthorizations: [ARKitSession.AuthorizationType] { get }

    @objc deinit

    /// An async sequence of all anchor updates.
    final public var anchorUpdates: AnchorUpdateSequence<ImageAnchor> { get }

    /// A textual representation of this image tracking provider.
    final public var description: String { get }
}

/// Represents a volume of space and the surfaces therein in the user's environment.
@available(visionOS 1.0, *)
@available(macOS, unavailable)
public struct MeshAnchor : Anchor, @unchecked Sendable {

    /// A value describing the classification of a mesh face of a MeshAnchor.Geometry.
    @available(visionOS, introduced: 1.0, deprecated: 26.0, renamed: "SurfaceClassification")
    public enum MeshClassification : NSInteger, Sendable {

        case none

        case wall

        case floor

        case ceiling

        case table

        case seat

        case window

        case door

        case stairs

        case bed

        case cabinet

        case homeAppliance

        case tv

        case plant

        /// Creates a new instance with the specified raw value.
        ///
        /// If there is no value of the type that corresponds with the specified raw
        /// value, this initializer returns `nil`. For example:
        ///
        ///     enum PaperSize: String {
        ///         case A4, A5, Letter, Legal
        ///     }
        ///
        ///     print(PaperSize(rawValue: "Legal"))
        ///     // Prints "Optional(PaperSize.Legal)"
        ///
        ///     print(PaperSize(rawValue: "Tabloid"))
        ///     // Prints "nil"
        ///
        /// - Parameter rawValue: The raw value to use for the new instance.
        public init?(rawValue: NSInteger)

        /// The raw type that can be used to represent all values of the conforming
        /// type.
        ///
        /// Every distinct value of the conforming type has a corresponding unique
        /// value of the `RawValue` type, but there may be values of the `RawValue`
        /// type that don't have a corresponding value of the conforming type.
        @available(visionOS, introduced: 1.0, deprecated: 26.0, renamed: "SurfaceClassification")
        @available(macOS, unavailable)
        public typealias RawValue = NSInteger

        /// The corresponding value of the raw type.
        ///
        /// A new instance initialized with `rawValue` will be equivalent to this
        /// instance. For example:
        ///
        ///     enum PaperSize: String {
        ///         case A4, A5, Letter, Legal
        ///     }
        ///
        ///     let selectedSize = PaperSize.Letter
        ///     print(selectedSize.rawValue)
        ///     // Prints "Letter"
        ///
        ///     print(selectedSize == PaperSize(rawValue: selectedSize.rawValue)!)
        ///     // Prints "true"
        public var rawValue: NSInteger { get }
    }

    /// A three-dimensional shape that represents the geometry of a mesh.
    public struct Geometry : CustomStringConvertible, @unchecked Sendable {

        /// Get the vertices of the mesh.
        public var vertices: GeometrySource { get }

        /// Get the normals of the mesh.
        public var normals: GeometrySource { get }

        /// Get the faces of the mesh.
        public var faces: GeometryElement { get }

        /// Get the classification for each face of the mesh.
        public var classifications: GeometrySource? { get }

        /// A textual representation of this geometry.
        public var description: String { get }
    }

    /// The unique identifier of this anchor.
    public var id: UUID { get }

    /// Get the geometry of the mesh in the anchor's coordinate system.
    public var geometry: MeshAnchor.Geometry { get }

    /// The transform from the mesh anchor to the origin coordinate system.
    public var originFromAnchorTransform: simd_float4x4 { get }

    /// A textual representation of this anchor.
    public var description: String { get }

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    @available(visionOS 1.0, *)
    @available(macOS, unavailable)
    public typealias ID = UUID
}

@available(visionOS 2.0, *)
@available(macOS, unavailable)
extension MeshAnchor : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: MeshAnchor, rhs: MeshAnchor) -> Bool
}

@available(macOS, unavailable)
@available(visionOS, introduced: 1.0, deprecated: 26.0, renamed: "SurfaceClassification")
extension MeshAnchor.MeshClassification : Equatable {
}

@available(macOS, unavailable)
@available(visionOS, introduced: 1.0, deprecated: 26.0, renamed: "SurfaceClassification")
extension MeshAnchor.MeshClassification : Hashable {
}

@available(macOS, unavailable)
@available(visionOS, introduced: 1.0, deprecated: 26.0, renamed: "SurfaceClassification")
extension MeshAnchor.MeshClassification : RawRepresentable {
}

@available(visionOS 2.0, *)
@available(macOS, unavailable)
extension MeshAnchor.Geometry : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: MeshAnchor.Geometry, rhs: MeshAnchor.Geometry) -> Bool
}

/// Represents a tracked reference object.
@available(visionOS 2.0, *)
@available(macOS, unavailable)
public struct ObjectAnchor : TrackableAnchor, @unchecked Sendable, Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: ObjectAnchor, rhs: ObjectAnchor) -> Bool

    /// The reference object which this anchor corresponds to.
    public var referenceObject: ReferenceObject { get }

    /// An axis-aligned bounding box.
    public struct AxisAlignedBoundingBox : @unchecked Sendable, Equatable {

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (lhs: ObjectAnchor.AxisAlignedBoundingBox, rhs: ObjectAnchor.AxisAlignedBoundingBox) -> Bool

        /// Minimum coordinates for bounding box.
        public var min: SIMD3<Float> { get }

        /// Maximum coordinates for bounding box.
        public var max: SIMD3<Float> { get }

        /// Center of bounding box.
        public var center: SIMD3<Float> { get }

        /// Extent of bounding box.
        public var extent: SIMD3<Float> { get }
    }

    /// The bounding box of this anchor.
    public var boundingBox: ObjectAnchor.AxisAlignedBoundingBox { get }

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    public typealias ID = UUID

    /// The unique identifier of this anchor.
    public var id: UUID { get }

    /// The transform from the object anchor to the origin coordinate system.
    public var originFromAnchorTransform: simd_float4x4 { get }

    /// Whether this object anchor is currently tracked or not.
    public var isTracked: Bool { get }

    /// A textual representation of this anchor.
    public var description: String { get }
}

/// Provides the real time position of reference objects in the user's environment.
@available(visionOS 2.0, *)
@available(macOS, unavailable)
final public class ObjectTrackingProvider : DataProvider, @unchecked Sendable {

    /// An object tracking error.
    public struct Error : LocalizedError, CustomStringConvertible, @unchecked Sendable {

        /// URL for the model which failed to load (if it was loaded from URL).
        public let url: URL?

        /// Name of model which failed to load (if it was loaded from bundle).
        public let name: String?

        /// Bundle for model which failed to load (if it was loaded from bundle).
        public let bundle: Bundle?

        /// Enumeration of all error codes.
        public enum Code : CustomStringConvertible {

            /// Loading a reference object failed.
            case referenceObjectLoadingFailed

            /// A textual representation of the code.
            public var description: String { get }

            /// Returns a Boolean value indicating whether two values are equal.
            ///
            /// Equality is the inverse of inequality. For any values `a` and `b`,
            /// `a == b` implies that `a != b` is `false`.
            ///
            /// - Parameters:
            ///   - lhs: A value to compare.
            ///   - rhs: Another value to compare.
            public static func == (a: ObjectTrackingProvider.Error.Code, b: ObjectTrackingProvider.Error.Code) -> Bool

            /// Hashes the essential components of this value by feeding them into the
            /// given hasher.
            ///
            /// Implement this method to conform to the `Hashable` protocol. The
            /// components used for hashing must be the same as the components compared
            /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
            /// with each of these components.
            ///
            /// - Important: In your implementation of `hash(into:)`,
            ///   don't call `finalize()` on the `hasher` instance provided,
            ///   or replace it with a different instance.
            ///   Doing so may become a compile-time error in the future.
            ///
            /// - Parameter hasher: The hasher to use when combining the components
            ///   of this instance.
            public func hash(into hasher: inout Hasher)

            /// The hash value.
            ///
            /// Hash values are not guaranteed to be equal across different executions of
            /// your program. Do not save hash values to use during a future execution.
            ///
            /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
            ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
            ///   The compiler provides an implementation for `hashValue` for you.
            public var hashValue: Int { get }
        }

        /// The error code.
        public var code: ObjectTrackingProvider.Error.Code { get }

        /// A localized message describing the reason for the failure.
        public var failureReason: String? { get }

        /// A localized message describing how one might recover from the failure.
        public var recoverySuggestion: String? { get }

        /// A localized message describing what error occurred.
        public var errorDescription: String? { get }

        /// A textual representation of this error.
        public var description: String { get }
    }

    /// A structure containing parameters to change object tracking behavior.
    /// An enterprise license is required to modify the tracking configuration, and will be a no-op otherwise.
    /// The app must include the following entitlement:
    ///  com.apple.developer.arkit.object-tracking-parameter-adjustment.allow
    public struct TrackingConfiguration : CustomStringConvertible {

        /// The total number of object instances that can be tracked at the same time (default 10).
        public var maximumTrackableInstances: Int

        /// How many instances of each reference object type to allow tracking at once (default 1).
        public var maximumInstancesPerReferenceObject: Int

        /// The frequency at which object detection runs, in Hz. Clamped between 0 and 30 Hz (default 2).
        public var detectionRate: Float

        /// The frequency at which object tracking runs for stationary objects, in Hz. Clamped between 0 and 30 Hz (default 5).
        public var stationaryObjectTrackingRate: Float

        /// The frequency at which object tracking runs for moving objects, in Hz. Clamped between 0 and 30 Hz (default 5).
        public var movingObjectTrackingRate: Float

        /// A textual representation of this tracking configuration.
        public var description: String { get }

        /// Initializes all parameters with default values.
        public init()
    }

    /// Create an object tracking provider.
    /// - Note:
    ///
    /// - Parameters:
    ///   - referenceObjects: The reference objects to look for.
    ///   - trackingConfiguration: Optional parameters for configuring object tracking. A set of default values will be applied if not provided.
    ///         Numeric parameter values for configuring tracking will be clamped if outside their supported range.
    ///
    /// - Returns: The object tracking provider.
    public init(referenceObjects: [ReferenceObject], trackingConfiguration: ObjectTrackingProvider.TrackingConfiguration? = nil)

    /// Returns the current parameters that are being used to configure object tracking.
    final public var trackingConfiguration: ObjectTrackingProvider.TrackingConfiguration { get }

    /// An async sequence of all anchor updates.
    final public var anchorUpdates: AnchorUpdateSequence<ObjectAnchor> { get }

    /// The state of this object tracking provider.
    final public var state: DataProviderState { get }

    /// Get all the object anchors
    final public var allAnchors: [ObjectAnchor] { get }

    /// Determines whether this device supports the object tracking provider.
    public static var isSupported: Bool { get }

    /// The authorization type(s) required by the object tracking provider.
    public static var requiredAuthorizations: [ARKitSession.AuthorizationType] { get }

    @objc deinit

    /// A textual representation of this object tracking provider.
    final public var description: String { get }
}

@available(visionOS 2.0, *)
@available(macOS, unavailable)
extension ObjectTrackingProvider.Error.Code : Equatable {
}

@available(visionOS 2.0, *)
@available(macOS, unavailable)
extension ObjectTrackingProvider.Error.Code : Hashable {
}

/// Represents a flat surface in the user's environment.
@available(visionOS 1.0, *)
@available(macOS, unavailable)
public struct PlaneAnchor : Anchor, @unchecked Sendable {

    /// Geometry of a plane.
    public struct Geometry : CustomStringConvertible, @unchecked Sendable {

        public struct Extent : CustomStringConvertible, @unchecked Sendable {

            /// The width of the plane extent.
            public var width: Float { get }

            /// The height of the plane extent.
            public var height: Float { get }

            /// Get the transform from the plane extent to the plane anchor’s coordinate system.
            public var anchorFromExtentTransform: simd_float4x4 { get }

            /// A textual representation of this extent.
            public var description: String { get }
        }

        /// The vertices of the plane mesh.
        public var meshVertices: GeometrySource { get }

        /// The faces of the plane mesh.
        public var meshFaces: GeometryElement { get }

        /// Get the extent of the plane geometry.
        public var extent: PlaneAnchor.Geometry.Extent { get }

        /// A textual representation of this geometry.
        public var description: String { get }
    }

    /// Enumeration of possible alignments of a detected plane.
    public enum Alignment : CustomStringConvertible, Sendable {

        /// Planes orthogonal to the gravity vector.
        case horizontal

        /// Planes parallel to the gravity vector.
        case vertical

        /// Planes that are neither horizontal nor vertical.
        @available(visionOS 2.0, *)
        case slanted

        /// A textual representation of PlaneAnchor.Alignment
        public var description: String { get }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: PlaneAnchor.Alignment, b: PlaneAnchor.Alignment) -> Bool

        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: In your implementation of `hash(into:)`,
        ///   don't call `finalize()` on the `hasher` instance provided,
        ///   or replace it with a different instance.
        ///   Doing so may become a compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher)

        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
        ///   The compiler provides an implementation for `hashValue` for you.
        public var hashValue: Int { get }
    }

    /// Enumeration of possible plane classifications.
    @available(visionOS, introduced: 1.0, deprecated: 26.0, renamed: "SurfaceClassification")
    public enum Classification : CustomStringConvertible, Sendable {

        /// Plane classification is currently unavailable.
        case notAvailable

        /// Plane classification has not yet been determined.
        case undetermined

        /// Plane classification is not any of the known classes.
        case unknown

        /// The classification is of type wall.
        case wall

        /// The classification is of type floor.
        case floor

        /// The classification is of type ceiling.
        case ceiling

        /// The classification is of type table.
        case table

        /// The classification is of type seat.
        case seat

        /// The classification is of type window.
        case window

        /// The classification is of type door.
        case door

        /// A textual representation of PlaneAnchor.Classification
        public var description: String { get }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: PlaneAnchor.Classification, b: PlaneAnchor.Classification) -> Bool

        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: In your implementation of `hash(into:)`,
        ///   don't call `finalize()` on the `hasher` instance provided,
        ///   or replace it with a different instance.
        ///   Doing so may become a compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher)

        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
        ///   The compiler provides an implementation for `hashValue` for you.
        public var hashValue: Int { get }
    }

    /// The unique identifier of this anchor.
    public var id: UUID { get }

    /// The transform from the plane anchor to the origin coordinate system.
    public var originFromAnchorTransform: simd_float4x4 { get }

    /// Get the alignment of this plane.
    public var alignment: PlaneAnchor.Alignment { get }

    /// Get the classification of this plane.
    @available(visionOS, introduced: 1.0, deprecated: 26.0, renamed: "surfaceClassification")
    public var classification: PlaneAnchor.Classification { get }

    /// Get the surface classification of this plane.
    @available(visionOS 26.0, *)
    public var surfaceClassification: SurfaceClassification { get }

    /// Get the geometry of the plane in the anchor's coordinate system.
    public var geometry: PlaneAnchor.Geometry { get }

    /// A textual representation of this anchor.
    public var description: String { get }

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    @available(visionOS 1.0, *)
    @available(macOS, unavailable)
    public typealias ID = UUID
}

@available(visionOS 2.0, *)
@available(macOS, unavailable)
extension PlaneAnchor : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: PlaneAnchor, rhs: PlaneAnchor) -> Bool
}

@available(visionOS 2.0, *)
@available(macOS, unavailable)
extension PlaneAnchor.Geometry : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: PlaneAnchor.Geometry, rhs: PlaneAnchor.Geometry) -> Bool
}

@available(visionOS 1.0, *)
@available(macOS, unavailable)
extension PlaneAnchor.Alignment : Equatable {
}

@available(visionOS 1.0, *)
@available(macOS, unavailable)
extension PlaneAnchor.Alignment : Hashable {
}

@available(macOS, unavailable)
@available(visionOS, introduced: 1.0, deprecated: 26.0, renamed: "SurfaceClassification")
extension PlaneAnchor.Classification : Equatable {
}

@available(macOS, unavailable)
@available(visionOS, introduced: 1.0, deprecated: 26.0, renamed: "SurfaceClassification")
extension PlaneAnchor.Classification : Hashable {
}

@available(visionOS 2.0, *)
@available(macOS, unavailable)
extension PlaneAnchor.Geometry.Extent : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: PlaneAnchor.Geometry.Extent, rhs: PlaneAnchor.Geometry.Extent) -> Bool
}

/// Provides planes detected from the user's environment.
@available(visionOS 1.0, *)
@available(macOS, unavailable)
final public class PlaneDetectionProvider : DataProvider, @unchecked Sendable {

    /// The alignments of planes to be detected.
    final public var alignments: [PlaneAnchor.Alignment] { get }

    /// The state of this plane detection provider.
    final public var state: DataProviderState { get }

    /// Create a plane detection provider.
    /// - Parameters:
    ///   - alignments: The alignments of planes to be detected. Defaults to detecting horizontal and vertical planes.
    ///
    /// - Returns: The plane detection provider.
    public init(alignments: [PlaneAnchor.Alignment] = [.horizontal, .vertical])

    /// Get all the plane anchors
    @available(visionOS 2.0, *)
    final public var allAnchors: [PlaneAnchor] { get }

    /// Determines whether this device supports the plane detection provider.
    public static var isSupported: Bool { get }

    /// The authorization type(s) required by the plane detection provider.
    public static var requiredAuthorizations: [ARKitSession.AuthorizationType] { get }

    @objc deinit

    /// An async sequence of all anchor updates.
    final public var anchorUpdates: AnchorUpdateSequence<PlaneAnchor> { get }

    /// A textual representation of this plane detection provider.
    final public var description: String { get }
}

/// Represents an image to be tracked.
@available(visionOS 1.0, *)
@available(macOS, unavailable)
public struct ReferenceImage : CustomStringConvertible, @unchecked Sendable {

    /// Load a group of reference images from a bundle.
    /// - Parameters:
    ///   - inGroupNamed: The name of the reference images resource group to add.
    ///   - bundle: (Optional) The bundle containing the image file or asset catalog. If nil, search the app’s main bundle.
    public static func loadReferenceImages(inGroupNamed groupName: String, bundle: Bundle? = nil) -> [ReferenceImage]

    /// The name of the reference image.
    public var name: String?

    /// The physical size of the printed reference image, in meters.
    public var physicalSize: CGSize { get }

    /// The resource group name of this image (if any).
    ///
    /// It will only be set if the reference image was loaded from a resource group.
    @available(visionOS 2.0, *)
    public var resourceGroupName: String? { get }

    /// Initialize a reference image from a given pixel buffer.
    /// - Parameters:
    ///   - pixelBuffer: The pixel buffer
    ///   - physicalSize: The size of the image in meters
    ///   - orientation: The image orientation
    public init(pixelBuffer: CVPixelBuffer, physicalSize: CGSize, orientation: CGImagePropertyOrientation = .up)

    /// Initialize a reference image from a given CGImage.
    /// - Parameters:
    ///   - cgimage: A CGImage
    ///   - physicalSize: The size of the image in meters
    ///   - orientation: The image orientation
    public init(cgimage: CGImage, physicalSize: CGSize, orientation: CGImagePropertyOrientation = .up)

    /// A textual representation of this reference image.
    public var description: String { get }
}

@available(visionOS 2.0, *)
@available(macOS, unavailable)
extension ReferenceImage : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: ReferenceImage, rhs: ReferenceImage) -> Bool
}

/// Represents an object to be tracked.
@available(visionOS 2.0, *)
@available(macOS, unavailable)
public struct ReferenceObject : CustomStringConvertible, @unchecked Sendable, Equatable, Identifiable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    @available(visionOS 2.0, *)
    public static func == (lhs: ReferenceObject, rhs: ReferenceObject) -> Bool

    /// Initializes a reference object from a URL.
    /// - Parameters:
    ///   - url: Local path to the reference object model.
    ///
    /// - Throws: `ObjectTrackingProvider.Error`
    public init(from url: URL) async throws

    /// Initializes a reference object from a bundle.
    /// - Parameters:
    ///   - named: Name of object to load in bundle.
    ///   - bundle: Bundle to load from. The main Bundle is used if unspecified.
    ///
    /// - Throws: `ObjectTrackingProvider.Error`
    public init(named: String, from bundle: Bundle? = nil) async throws

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    public typealias ID = UUID

    /// The unique identifier of this reference object.
    public var id: UUID { get }

    /// The input file used to load the reference object.
    public var inputFile: URL? { get }

    /// The trained USDZ file, if the reference object includes one.
    public var usdzFile: URL? { get }

    /// The name of the reference object.
    public var name: String { get }

    /// A textual representation of this reference object.
    public var description: String { get }
}

/// Represents a tracked room.
@available(visionOS 2.0, *)
@available(macOS, unavailable)
public struct RoomAnchor : Anchor, @unchecked Sendable, Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: RoomAnchor, rhs: RoomAnchor) -> Bool

    /// The unique identifier of this anchor.
    public var id: UUID { get }

    /// The transform from the room anchor to the origin coordinate system.
    public var originFromAnchorTransform: simd_float4x4 { get }

    /// Get the geometry of the mesh in the anchor's coordinate system.
    public var geometry: MeshAnchor.Geometry { get }

    /// Get the IDs of the plane anchors associated with this room.
    public var planeAnchorIDs: [UUID] { get }

    /// Get the IDs of the mesh anchors associated with this room.
    public var meshAnchorIDs: [UUID] { get }

    /// True if this is the room which a person is currently in.
    public var isCurrentRoom: Bool { get }

    /// Get disjoint mesh geometries of a given classification.
    @available(visionOS, introduced: 2.0, deprecated: 26.0, message: "Use geometries(classifiedAs: SurfaceClassification) instead.")
    public func geometries(of classification: MeshAnchor.MeshClassification) -> [MeshAnchor.Geometry]

    /// Get disjoint mesh geometries of a given surface classification.
    @available(visionOS 26.0, *)
    public func geometries(classifiedAs classification: SurfaceClassification) -> [MeshAnchor.Geometry]

    /// Check if this room contains a given point.
    /// - Parameters:
    ///   - point: The point to check.
    ///
    /// - Returns: True if this room contains the point, false otherwise.
    public func contains(_ point: SIMD3<Float>) -> Bool

    /// A textual representation of this anchor.
    public var description: String { get }

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    @available(visionOS 2.0, *)
    @available(macOS, unavailable)
    public typealias ID = UUID
}

/// Provides information about the rooms that a person has been in.
@available(visionOS 2.0, *)
@available(macOS, unavailable)
final public class RoomTrackingProvider : DataProvider, @unchecked Sendable {

    /// The state of this room tracking provider.
    final public var state: DataProviderState { get }

    /// Create a room tracking provider.
    ///
    /// - Returns: The room tracking provider.
    public init()

    /// Get all the room anchors.
    @available(visionOS 2.0, *)
    final public var allAnchors: [RoomAnchor] { get }

    /// Determines whether this device supports the room tracking provider.
    public static var isSupported: Bool { get }

    /// The authorization type(s) required by the room tracking provider.
    public static var requiredAuthorizations: [ARKitSession.AuthorizationType] { get }

    @objc deinit

    /// An async sequence of all anchor updates.
    final public var anchorUpdates: AnchorUpdateSequence<RoomAnchor> { get }

    /// The room which a person is currently in, if any.
    final public var currentRoomAnchor: RoomAnchor? { get }

    /// A textual representation of this room tracking provider.
    final public var description: String { get }
}

/// Provides a three dimensional understanding of the user's environment.
@available(visionOS 1.0, *)
@available(macOS, unavailable)
final public class SceneReconstructionProvider : DataProvider, @unchecked Sendable {

    /// Enumeration of all available scene reconstruction modes. A mesh is always generated. These are additional features.
    public enum Mode : CustomStringConvertible, Sendable {

        /// Scene reconstruction generates a classification for each face
        case classification

        /// A textual representation of SceneReconstructionProvider.Mode
        public var description: String { get }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: SceneReconstructionProvider.Mode, b: SceneReconstructionProvider.Mode) -> Bool

        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: In your implementation of `hash(into:)`,
        ///   don't call `finalize()` on the `hasher` instance provided,
        ///   or replace it with a different instance.
        ///   Doing so may become a compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher)

        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
        ///   The compiler provides an implementation for `hashValue` for you.
        public var hashValue: Int { get }
    }

    /// The scene reconstruction modes set on this scene reconstruction provider.
    final public let modes: [SceneReconstructionProvider.Mode]

    /// The state of this scene reconstruction provider.
    final public var state: DataProviderState { get }

    /// Create a scene reconstruction provider.
    /// - Parameters:
    ///   - modes: The scene reconstruction modes to use. By default, a mesh with no classification is reconstructed.
    ///
    /// - Returns: The scene reconstruction provider.
    public init(modes: [SceneReconstructionProvider.Mode] = [])

    /// Get all the mesh anchors
    @available(visionOS 2.0, *)
    final public var allAnchors: [MeshAnchor] { get }

    /// Determines whether this device supports the scene reconstruction provider.
    public static var isSupported: Bool { get }

    /// The authorization type(s) required by the scene reconstruction provider.
    public static var requiredAuthorizations: [ARKitSession.AuthorizationType] { get }

    @objc deinit

    /// An async sequence of all anchor updates.
    final public var anchorUpdates: AnchorUpdateSequence<MeshAnchor> { get }

    /// A textual representation of this scene reconstruction provider.
    final public var description: String { get }
}

@available(visionOS 1.0, *)
@available(macOS, unavailable)
extension SceneReconstructionProvider.Mode : Equatable {
}

@available(visionOS 1.0, *)
@available(macOS, unavailable)
extension SceneReconstructionProvider.Mode : Hashable {
}

/// Provides ability to establish a shared coordinate space among multiple participants.
@available(visionOS 26.0, *)
@available(macOS, unavailable)
final public class SharedCoordinateSpaceProvider : DataProvider, @unchecked Sendable {

    /// Create a shared coordinate space provider.
    ///
    /// - Returns: The shared coordinate space provider.
    public init()

    /// Get the next coordinate space data to be broadcast to all participants.
    @available(visionOS 26.0, *)
    final public var nextCoordinateSpaceData: SharedCoordinateSpaceProvider.CoordinateSpaceData? { get }

    /// Push data to shared coordinate space provider.
    final public func push(data: SharedCoordinateSpaceProvider.CoordinateSpaceData)

    /**
        A coordinate space data.
    
        @discussion The underlying data needs to be sent to each participant in the shared coordinate space.
        */
    public struct CoordinateSpaceData : @unchecked Sendable {

        /// Extract a `Data` object to be transported over network.
        public var data: Data { get }

        /// Participant identifiers of the intended recipient for this data. Data should be broadcast if the list is empty.
        public var recipientIdentifiers: [UUID] { get }

        /// Initialize a `CoordinateSpaceData` from a Data blob received over network.
        /// - Parameters:
        ///   - data: Data blob received over the network..
        public init?(data: Data)
    }

    /// Events that can occur in a shared coordinate space.
    public enum Event : CustomStringConvertible, Sendable {

        /// @discussion Provider has been enabled to produce data and the user is allowed to push data to the provider.
        case sharingEnabled

        /// @discussion Provider has been disabled to producing data and the user is not allowed to push data to the provider.
        case sharingDisabled

        /// Participants changed.
        /// - Parameters:
        ///   - participants: The connected participants.
        case connectedParticipantIdentifiers(participants: [UUID])

        /// A textual representation of this Event.
        public var description: String { get }
    }

    /// A sequence of events that have occurred.
    final public var eventUpdates: some AsyncSequence<SharedCoordinateSpaceProvider.Event, Never> { get }

    /// Get the identifier of the local participant.
    final public var participantIdentifier: UUID { get }

    /// Returns true if coordinate space sharing is enabled, false otherwise.
    @available(visionOS 26.4, *)
    final public var isSharingEnabled: Bool { get }

    /// The state of this shared coordinate space provider.
    final public var state: DataProviderState { get }

    /// Determines whether this device supports the shared coordinate space provider.
    public static var isSupported: Bool { get }

    /// The authorization type(s) required by the shared coordinate space provider.
    public static var requiredAuthorizations: [ARKitSession.AuthorizationType] { get }

    /// A textual representation of this SharedCoordinateSpaceProvider.
    final public var description: String { get }

    @objc deinit
}

/// The StereoPropertiesProvider serves the latest viewpoint properties on the device.
@available(visionOS 2.4, *)
@available(macOS, unavailable)
final public class StereoPropertiesProvider : DataProvider, @unchecked Sendable {

    /// Initialize the StereoPropertiesProvider.
    public init()

    /// Returns the latest viewpoint properties, if available.
    final public var latestViewpointProperties: ViewpointProperties? { get }

    /// The state of this stereo properties provider.
    final public var state: DataProviderState { get }

    /// Determines whether this device supports the stereo properties provider.
    public static var isSupported: Bool { get }

    /// The authorization type(s) required by the stereo properties provider.
    public static var requiredAuthorizations: [ARKitSession.AuthorizationType] { get }

    /// A textual representation of this stereo properties provider.
    final public var description: String { get }

    @objc deinit
}

/// A value describing the classification of a surface.
@available(visionOS 26.0, *)
@available(macOS, unavailable)
public enum SurfaceClassification : Int, Sendable, CustomStringConvertible {

    case none

    case wall

    case floor

    case ceiling

    case table

    case seat

    case window

    case door

    case stairs

    case bed

    case cabinet

    case homeAppliance

    case tv

    case plant

    /// A textual representation of the classification.
    public var description: String { get }

    /// Creates a new instance with the specified raw value.
    ///
    /// If there is no value of the type that corresponds with the specified raw
    /// value, this initializer returns `nil`. For example:
    ///
    ///     enum PaperSize: String {
    ///         case A4, A5, Letter, Legal
    ///     }
    ///
    ///     print(PaperSize(rawValue: "Legal"))
    ///     // Prints "Optional(PaperSize.Legal)"
    ///
    ///     print(PaperSize(rawValue: "Tabloid"))
    ///     // Prints "nil"
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.
    public init?(rawValue: Int)

    /// The raw type that can be used to represent all values of the conforming
    /// type.
    ///
    /// Every distinct value of the conforming type has a corresponding unique
    /// value of the `RawValue` type, but there may be values of the `RawValue`
    /// type that don't have a corresponding value of the conforming type.
    @available(visionOS 26.0, *)
    @available(macOS, unavailable)
    public typealias RawValue = Int

    /// The corresponding value of the raw type.
    ///
    /// A new instance initialized with `rawValue` will be equivalent to this
    /// instance. For example:
    ///
    ///     enum PaperSize: String {
    ///         case A4, A5, Letter, Legal
    ///     }
    ///
    ///     let selectedSize = PaperSize.Letter
    ///     print(selectedSize.rawValue)
    ///     // Prints "Letter"
    ///
    ///     print(selectedSize == PaperSize(rawValue: selectedSize.rawValue)!)
    ///     // Prints "true"
    public var rawValue: Int { get }
}

@available(visionOS 26.0, *)
@available(macOS, unavailable)
extension SurfaceClassification : Equatable {
}

@available(visionOS 26.0, *)
@available(macOS, unavailable)
extension SurfaceClassification : Hashable {
}

@available(visionOS 26.0, *)
@available(macOS, unavailable)
extension SurfaceClassification : RawRepresentable {
}

/// Protocol for trackable anchors.
@available(visionOS 1.0, macOS 26.0, *)
public protocol TrackableAnchor : Anchor {

    /// Whether this anchor is currently tracked or not.
    var isTracked: Bool { get }
}

/// The ViewpointProperties is a record of render camera transforms at some particular time.
@available(visionOS 2.4, *)
@available(macOS, unavailable)
public struct ViewpointProperties : @unchecked Sendable, CustomStringConvertible {

    /// The transformation matrix that converts from the left viewpoint to the device’s coordinate space.
    public var deviceFromLeftViewpointTransform: simd_float4x4 { get }

    /// The transformation matrix that converts from the left viewpoint to the device’s coordinate space.
    public var deviceFromRightViewpointTransform: simd_float4x4 { get }

    /// Textual representation of the viewpoint properties.
    public var description: String { get }
}

/// Represents a fixed location in the user's environment.
@available(visionOS 1.0, *)
@available(macOS, unavailable)
public struct WorldAnchor : TrackableAnchor, @unchecked Sendable {

    /// Whether this world anchor is currently tracked or not.
    public var isTracked: Bool { get }

    /// The unique identifier of this anchor.
    public var id: UUID { get }

    /// Check if a world anchor is shared with nearby participants.
    @available(visionOS 26.0, *)
    public var isSharedWithNearbyParticipants: Bool { get }

    /// The transform from the world anchor to the origin coordinate system.
    public var originFromAnchorTransform: simd_float4x4 { get }

    /// Initialize a world anchor with a transform.
    /// - Parameters:
    ///   - originFromAnchorTransform: The transform from the world anchor to the origin coordinate system.
    public init(originFromAnchorTransform: simd_float4x4)

    /// Initialize a world anchor with a transform and indicate if it should be shared with nearby participants.
    /// - Parameters:
    ///   - originFromAnchorTransform: The transform from the world anchor to the origin coordinate system.
    ///   - sharedWithNearbyParticipants: Indicate if the anchor should be shared with nearby participants.
    ///
    /// - Note:
    ///     - Nearby participants refer to participants that are nearby to the local participant in a SharePlay session.
    ///     - World anchors that are marked for sharing do not get persisted and their lifetime is limited to that of the SharePlay session.
    ///
    @available(visionOS 26.0, *)
    public init(originFromAnchorTransform: simd_float4x4, sharedWithNearbyParticipants: Bool)

    /// A textual representation of this anchor.
    public var description: String { get }

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    @available(visionOS 1.0, *)
    @available(macOS, unavailable)
    public typealias ID = UUID
}

@available(visionOS 2.0, *)
@available(macOS, unavailable)
extension WorldAnchor : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: WorldAnchor, rhs: WorldAnchor) -> Bool
}

/// Provides placement of anchors in the user's environment and access to the device pose.
@available(visionOS 1.0, macOS 26.0, *)
final public class WorldTrackingProvider : DataProvider, @unchecked Sendable {

    /// A world tracking error.
    @available(macOS, unavailable)
    public struct Error : LocalizedError, CustomStringConvertible, @unchecked Sendable {

        /// The anchor for which this error occurred (if any).
        public let anchor: WorldAnchor?

        /// Enumeration of all possible world tracking error codes.
        public enum Code : CustomStringConvertible {

            /// Adding a world anchor failed.
            case addWorldAnchorFailed

            /// Adding a world anchor failed  - an upper limit was reached.
            case worldAnchorLimitReached

            /// Removing a world anchor failed.
            case removeWorldAnchorFailed

            /// A textual representation of the code.
            public var description: String { get }

            /// Returns a Boolean value indicating whether two values are equal.
            ///
            /// Equality is the inverse of inequality. For any values `a` and `b`,
            /// `a == b` implies that `a != b` is `false`.
            ///
            /// - Parameters:
            ///   - lhs: A value to compare.
            ///   - rhs: Another value to compare.
            public static func == (a: WorldTrackingProvider.Error.Code, b: WorldTrackingProvider.Error.Code) -> Bool

            /// Hashes the essential components of this value by feeding them into the
            /// given hasher.
            ///
            /// Implement this method to conform to the `Hashable` protocol. The
            /// components used for hashing must be the same as the components compared
            /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
            /// with each of these components.
            ///
            /// - Important: In your implementation of `hash(into:)`,
            ///   don't call `finalize()` on the `hasher` instance provided,
            ///   or replace it with a different instance.
            ///   Doing so may become a compile-time error in the future.
            ///
            /// - Parameter hasher: The hasher to use when combining the components
            ///   of this instance.
            public func hash(into hasher: inout Hasher)

            /// The hash value.
            ///
            /// Hash values are not guaranteed to be equal across different executions of
            /// your program. Do not save hash values to use during a future execution.
            ///
            /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
            ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
            ///   The compiler provides an implementation for `hashValue` for you.
            public var hashValue: Int { get }
        }

        /// A localized message describing the reason for the failure.
        public var failureReason: String? { get }

        /// A localized message describing how one might recover from the failure.
        public var recoverySuggestion: String? { get }

        /// A localized message describing what error occurred.
        public var errorDescription: String? { get }

        /// The error code.
        public var code: WorldTrackingProvider.Error.Code { get }

        /// A textual representation of this error.
        public var description: String { get }
    }

    /// The state of this world tracking provider.
    final public var state: DataProviderState { get }

    /// Enumeration indicating the availability of world anchor sharing.
    @available(visionOS 26.0, *)
    public enum WorldAnchorSharingAvailability : CustomStringConvertible, Sendable {

        /// World anchors can be shared with nearby participants.
        /// Indicates that the device is in a SharePlay session with nearby participants.
        case available

        /// World anchors cannot be shared with nearby participants.
        /// This indicates that either there’s no SharePlay session or the session has ended.
        case unavailable

        /// A textual representation of this instance.
        ///
        /// Calling this property directly is discouraged. Instead, convert an
        /// instance of any type to a string by using the `String(describing:)`
        /// initializer. This initializer works with any type, and uses the custom
        /// `description` property for types that conform to
        /// `CustomStringConvertible`:
        ///
        ///     struct Point: CustomStringConvertible {
        ///         let x: Int, y: Int
        ///
        ///         var description: String {
        ///             return "(\(x), \(y))"
        ///         }
        ///     }
        ///
        ///     let p = Point(x: 21, y: 30)
        ///     let s = String(describing: p)
        ///     print(s)
        ///     // Prints "(21, 30)"
        ///
        /// The conversion of `p` to a string in the assignment to `s` uses the
        /// `Point` type's `description` property.
        public var description: String { get }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: WorldTrackingProvider.WorldAnchorSharingAvailability, b: WorldTrackingProvider.WorldAnchorSharingAvailability) -> Bool

        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: In your implementation of `hash(into:)`,
        ///   don't call `finalize()` on the `hasher` instance provided,
        ///   or replace it with a different instance.
        ///   Doing so may become a compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher)

        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
        ///   The compiler provides an implementation for `hashValue` for you.
        public var hashValue: Int { get }
    }

    /// A sequence of world anchor sharing availability changes.
    @available(visionOS 26.0, *)
    final public var worldAnchorSharingAvailability: some AsyncSequence<WorldTrackingProvider.WorldAnchorSharingAvailability, Never> { get }

    /// Add a world anchor to the world tracking provider. This anchor will be persisted across device restarts unless explicitly removed.
    ///
    /// - Parameters:
    ///   - worldAnchor: The world anchor to add.
    ///
    /// - Throws: `WorldTrackingProvider.Error`
    @available(macOS, unavailable)
    final public func addAnchor(_ worldAnchor: WorldAnchor) async throws

    /// Remove an anchor from world tracking.
    ///
    /// - Parameters:
    ///   - worldAnchor: The world anchor to remove.
    ///
    /// - Throws: `WorldTrackingProvider.Error`
    @available(macOS, unavailable)
    final public func removeAnchor(_ worldAnchor: WorldAnchor) async throws

    /// Remove an anchor with a given ID from world tracking.
    ///
    /// - Parameters:
    ///   - id: ID of the world anchor to remove.
    ///
    /// - Throws: `WorldTrackingProvider.Error`
    @available(macOS, unavailable)
    final public func removeAnchor(forID id: UUID) async throws

    /// Removes all known world anchors from world tracking.
    ///
    /// - Throws: `WorldTrackingProvider.Error`
    /// - Returns: All removed world anchors.
    @available(visionOS 26.0, *)
    @available(macOS, unavailable)
    final public func removeAllAnchors() async throws

    /// Get all known world anchors from the world tracking provider.
    ///
    /// - Returns: All known world anchors. Returns nil if data provider is not running and for other errors.
    @available(visionOS 2.0, *)
    @available(macOS, unavailable)
    final public var allAnchors: [WorldAnchor]? { get async }

    /// Query the device anchor at a given timestamp.
    /// - Parameters:
    ///   - timestamp: The timestamp for predicting the device anchor's transform. The timestamp should be provided as mach absolute time in seconds.
    ///   When rendering with CompositorServices this should be `drawable.frameTiming.presentationTime`.
    ///
    /// - Returns: The device anchor, or nil if prediction failed.
    final public func queryDeviceAnchor(atTimestamp timestamp: TimeInterval) -> DeviceAnchor?

    /// Create a world tracking provider.
    ///
    /// - Returns: The world tracking provider.
    public init()

    /// Determines whether this device supports the world tracking provider.
    public static var isSupported: Bool { get }

    /// The authorization type(s) required by the world tracking provider.
    public static var requiredAuthorizations: [ARKitSession.AuthorizationType] { get }

    @objc deinit

    /// An async sequence of all anchor updates. It is triggered whenever there are updates to world anchors. That includes persisted world anchors from previous runs of the app.
    ///
    /// Note: This handler will also be called for persisted world anchors from previous runs of the app, once the device
    /// has successfully relocalized to the anchor's environment. World anchors persist across device restarts until they
    /// are explicitly removed. Identify the anchors you want to react to by calling `.id`.
    @available(macOS, unavailable)
    final public var anchorUpdates: AnchorUpdateSequence<WorldAnchor> { get }

    /// A textual representation of this world tracking provider.
    final public var description: String { get }
}

@available(macOS 26.0, visionOS 26.0, *)
extension WorldTrackingProvider.WorldAnchorSharingAvailability : Equatable {
}

@available(macOS 26.0, visionOS 26.0, *)
extension WorldTrackingProvider.WorldAnchorSharingAvailability : Hashable {
}

@available(visionOS 1.0, *)
@available(macOS, unavailable)
extension WorldTrackingProvider.Error.Code : Equatable {
}

@available(visionOS 1.0, *)
@available(macOS, unavailable)
extension WorldTrackingProvider.Error.Code : Hashable {
}

