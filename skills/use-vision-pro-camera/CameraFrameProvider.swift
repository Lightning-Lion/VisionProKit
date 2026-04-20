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