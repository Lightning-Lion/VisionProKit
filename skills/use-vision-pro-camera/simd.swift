/** @abstract A matrix with 2 rows and 2 columns.                             */
public struct simd_half2x2 {

    public init()

    public init(columns: (simd_half2, simd_half2))

    public var columns: (simd_half2, simd_half2)
}

/** @abstract A matrix with 2 rows and 3 columns.                             */
public struct simd_half3x2 {

    public init()

    public init(columns: (simd_half2, simd_half2, simd_half2))

    public var columns: (simd_half2, simd_half2, simd_half2)
}

/** @abstract A matrix with 2 rows and 4 columns.                             */
public struct simd_half4x2 {

    public init()

    public init(columns: (simd_half2, simd_half2, simd_half2, simd_half2))

    public var columns: (simd_half2, simd_half2, simd_half2, simd_half2)
}

/** @abstract A matrix with 3 rows and 2 columns.                             */
public struct simd_half2x3 {

    public init()

    public init(columns: (simd_half3, simd_half3))

    public var columns: (simd_half3, simd_half3)
}

/** @abstract A matrix with 3 rows and 3 columns.                             */
public struct simd_half3x3 {

    public init()

    public init(columns: (simd_half3, simd_half3, simd_half3))

    public var columns: (simd_half3, simd_half3, simd_half3)
}

/** @abstract A matrix with 3 rows and 4 columns.                             */
public struct simd_half4x3 {

    public init()

    public init(columns: (simd_half3, simd_half3, simd_half3, simd_half3))

    public var columns: (simd_half3, simd_half3, simd_half3, simd_half3)
}

/** @abstract A matrix with 4 rows and 2 columns.                             */
public struct simd_half2x4 {

    public init()

    public init(columns: (simd_half4, simd_half4))

    public var columns: (simd_half4, simd_half4)
}

/** @abstract A matrix with 4 rows and 3 columns.                             */
public struct simd_half3x4 {

    public init()

    public init(columns: (simd_half4, simd_half4, simd_half4))

    public var columns: (simd_half4, simd_half4, simd_half4)
}

/** @abstract A matrix with 4 rows and 4 columns.                             */
public struct simd_half4x4 {

    public init()

    public init(columns: (simd_half4, simd_half4, simd_half4, simd_half4))

    public var columns: (simd_half4, simd_half4, simd_half4, simd_half4)
}

/** @abstract A matrix with 2 rows and 2 columns.                             */
public struct simd_float2x2 {

    public init()

    public init(columns: (simd_float2, simd_float2))

    public var columns: (simd_float2, simd_float2)
}

extension simd_float2x2 {

    /// Initialize matrix to have `scalar` on main diagonal, zeros elsewhere.
    public init(_ scalar: Float)

    /// Initialize matrix to have specified `diagonal`, and zeros elsewhere.
    public init(diagonal: SIMD2<Float>)

    /// Initialize matrix to have specified `columns`.
    public init(_ columns: [SIMD2<Float>])

    /// Initialize matrix to have specified `rows`.
    public init(rows: [SIMD2<Float>])

    /// Initialize matrix to have specified `columns`.
    public init(_ col0: SIMD2<Float>, _ col1: SIMD2<Float>)

    /// Initialize matrix from corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This conversion is no longer necessary; use `cmatrix` directly.")
    public init(_ cmatrix: simd_float2x2)

    /// Get the matrix as the corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This property is no longer needed; use the matrix itself.")
    public var cmatrix: simd_float2x2 { get }

    /// Access to individual columns.
    public subscript(column: Int) -> SIMD2<Float>

    /// Access to individual elements.
    public subscript(column: Int, row: Int) -> Float
}

extension simd_float2x2 : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(reflecting:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `debugDescription` property for types that conform to
    /// `CustomDebugStringConvertible`:
    ///
    ///     struct Point: CustomDebugStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var debugDescription: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(reflecting: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `debugDescription` property.
    @inlinable public var debugDescription: String { get }
}

extension simd_float2x2 : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: simd_float2x2, rhs: simd_float2x2) -> Bool
}

extension simd_float2x2 {

    /// Transpose of the matrix.
    public var transpose: float2x2 { get }

    /// Inverse of the matrix if it exists, otherwise the contents of the
    /// resulting matrix are undefined.
    @available(macOS 10.10, iOS 8.0, tvOS 10.0, watchOS 3.0, *)
    public var inverse: simd_float2x2 { get }

    /// Determinant of the matrix.
    public var determinant: Float { get }

    /// Sum of two matrices.
    public static func + (lhs: simd_float2x2, rhs: simd_float2x2) -> simd_float2x2

    /// Negation of a matrix.
    prefix public static func - (rhs: simd_float2x2) -> simd_float2x2

    /// Difference of two matrices.
    public static func - (lhs: simd_float2x2, rhs: simd_float2x2) -> simd_float2x2

    public static func += (lhs: inout simd_float2x2, rhs: simd_float2x2)

    public static func -= (lhs: inout simd_float2x2, rhs: simd_float2x2)

    /// Scalar-Matrix multiplication.
    public static func * (lhs: Float, rhs: simd_float2x2) -> simd_float2x2

    /// Matrix-Scalar multiplication.
    public static func * (lhs: simd_float2x2, rhs: Float) -> simd_float2x2

    public static func *= (lhs: inout simd_float2x2, rhs: Float)

    /// Matrix-Vector multiplication.  Keep in mind that matrix types are named
    /// `FloatNxM` where `N` is the number of *columns* and `M` is the number of
    /// *rows*, so we multiply a `Float3x2 * Float3` to get a `Float2`, for
    /// example.
    public static func * (lhs: simd_float2x2, rhs: SIMD2<Float>) -> SIMD2<Float>

    /// Vector-Matrix multiplication.
    public static func * (lhs: SIMD2<Float>, rhs: simd_float2x2) -> SIMD2<Float>

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float2x2, rhs: float2x2) -> float2x2

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float2x2, rhs: float3x2) -> float3x2

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float2x2, rhs: float4x2) -> float4x2

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func *= (lhs: inout simd_float2x2, rhs: float2x2)
}

/** @abstract A matrix with 2 rows and 3 columns.                             */
public struct simd_float3x2 {

    public init()

    public init(columns: (simd_float2, simd_float2, simd_float2))

    public var columns: (simd_float2, simd_float2, simd_float2)
}

extension simd_float3x2 {

    /// Initialize matrix to have `scalar` on main diagonal, zeros elsewhere.
    public init(_ scalar: Float)

    /// Initialize matrix to have specified `diagonal`, and zeros elsewhere.
    public init(diagonal: SIMD2<Float>)

    /// Initialize matrix to have specified `columns`.
    public init(_ columns: [SIMD2<Float>])

    /// Initialize matrix to have specified `rows`.
    public init(rows: [SIMD3<Float>])

    /// Initialize matrix to have specified `columns`.
    public init(_ col0: SIMD2<Float>, _ col1: SIMD2<Float>, _ col2: SIMD2<Float>)

    /// Initialize matrix from corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This conversion is no longer necessary; use `cmatrix` directly.")
    public init(_ cmatrix: simd_float3x2)

    /// Get the matrix as the corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This property is no longer needed; use the matrix itself.")
    public var cmatrix: simd_float3x2 { get }

    /// Access to individual columns.
    public subscript(column: Int) -> SIMD2<Float>

    /// Access to individual elements.
    public subscript(column: Int, row: Int) -> Float
}

extension simd_float3x2 : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(reflecting:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `debugDescription` property for types that conform to
    /// `CustomDebugStringConvertible`:
    ///
    ///     struct Point: CustomDebugStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var debugDescription: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(reflecting: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `debugDescription` property.
    @inlinable public var debugDescription: String { get }
}

extension simd_float3x2 : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: simd_float3x2, rhs: simd_float3x2) -> Bool
}

extension simd_float3x2 {

    /// Transpose of the matrix.
    public var transpose: float2x3 { get }

    /// Sum of two matrices.
    public static func + (lhs: simd_float3x2, rhs: simd_float3x2) -> simd_float3x2

    /// Negation of a matrix.
    prefix public static func - (rhs: simd_float3x2) -> simd_float3x2

    /// Difference of two matrices.
    public static func - (lhs: simd_float3x2, rhs: simd_float3x2) -> simd_float3x2

    public static func += (lhs: inout simd_float3x2, rhs: simd_float3x2)

    public static func -= (lhs: inout simd_float3x2, rhs: simd_float3x2)

    /// Scalar-Matrix multiplication.
    public static func * (lhs: Float, rhs: simd_float3x2) -> simd_float3x2

    /// Matrix-Scalar multiplication.
    public static func * (lhs: simd_float3x2, rhs: Float) -> simd_float3x2

    public static func *= (lhs: inout simd_float3x2, rhs: Float)

    /// Matrix-Vector multiplication.  Keep in mind that matrix types are named
    /// `FloatNxM` where `N` is the number of *columns* and `M` is the number of
    /// *rows*, so we multiply a `Float3x2 * Float3` to get a `Float2`, for
    /// example.
    public static func * (lhs: simd_float3x2, rhs: SIMD3<Float>) -> SIMD2<Float>

    /// Vector-Matrix multiplication.
    public static func * (lhs: SIMD2<Float>, rhs: simd_float3x2) -> SIMD3<Float>

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float3x2, rhs: float2x3) -> float2x2

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float3x2, rhs: float3x3) -> float3x2

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float3x2, rhs: float4x3) -> float4x2

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func *= (lhs: inout simd_float3x2, rhs: float3x3)
}

/** @abstract A matrix with 2 rows and 4 columns.                             */
public struct simd_float4x2 {

    public init()

    public init(columns: (simd_float2, simd_float2, simd_float2, simd_float2))

    public var columns: (simd_float2, simd_float2, simd_float2, simd_float2)
}

extension simd_float4x2 {

    /// Initialize matrix to have `scalar` on main diagonal, zeros elsewhere.
    public init(_ scalar: Float)

    /// Initialize matrix to have specified `diagonal`, and zeros elsewhere.
    public init(diagonal: SIMD2<Float>)

    /// Initialize matrix to have specified `columns`.
    public init(_ columns: [SIMD2<Float>])

    /// Initialize matrix to have specified `rows`.
    public init(rows: [SIMD4<Float>])

    /// Initialize matrix to have specified `columns`.
    public init(_ col0: SIMD2<Float>, _ col1: SIMD2<Float>, _ col2: SIMD2<Float>, _ col3: SIMD2<Float>)

    /// Initialize matrix from corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This conversion is no longer necessary; use `cmatrix` directly.")
    public init(_ cmatrix: simd_float4x2)

    /// Get the matrix as the corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This property is no longer needed; use the matrix itself.")
    public var cmatrix: simd_float4x2 { get }

    /// Access to individual columns.
    public subscript(column: Int) -> SIMD2<Float>

    /// Access to individual elements.
    public subscript(column: Int, row: Int) -> Float
}

extension simd_float4x2 : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(reflecting:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `debugDescription` property for types that conform to
    /// `CustomDebugStringConvertible`:
    ///
    ///     struct Point: CustomDebugStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var debugDescription: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(reflecting: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `debugDescription` property.
    @inlinable public var debugDescription: String { get }
}

extension simd_float4x2 : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: simd_float4x2, rhs: simd_float4x2) -> Bool
}

extension simd_float4x2 {

    /// Transpose of the matrix.
    public var transpose: float2x4 { get }

    /// Sum of two matrices.
    public static func + (lhs: simd_float4x2, rhs: simd_float4x2) -> simd_float4x2

    /// Negation of a matrix.
    prefix public static func - (rhs: simd_float4x2) -> simd_float4x2

    /// Difference of two matrices.
    public static func - (lhs: simd_float4x2, rhs: simd_float4x2) -> simd_float4x2

    public static func += (lhs: inout simd_float4x2, rhs: simd_float4x2)

    public static func -= (lhs: inout simd_float4x2, rhs: simd_float4x2)

    /// Scalar-Matrix multiplication.
    public static func * (lhs: Float, rhs: simd_float4x2) -> simd_float4x2

    /// Matrix-Scalar multiplication.
    public static func * (lhs: simd_float4x2, rhs: Float) -> simd_float4x2

    public static func *= (lhs: inout simd_float4x2, rhs: Float)

    /// Matrix-Vector multiplication.  Keep in mind that matrix types are named
    /// `FloatNxM` where `N` is the number of *columns* and `M` is the number of
    /// *rows*, so we multiply a `Float3x2 * Float3` to get a `Float2`, for
    /// example.
    public static func * (lhs: simd_float4x2, rhs: SIMD4<Float>) -> SIMD2<Float>

    /// Vector-Matrix multiplication.
    public static func * (lhs: SIMD2<Float>, rhs: simd_float4x2) -> SIMD4<Float>

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float4x2, rhs: float2x4) -> float2x2

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float4x2, rhs: float3x4) -> float3x2

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float4x2, rhs: float4x4) -> float4x2

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func *= (lhs: inout simd_float4x2, rhs: float4x4)
}

/** @abstract A matrix with 3 rows and 2 columns.                             */
public struct simd_float2x3 {

    public init()

    public init(columns: (simd_float3, simd_float3))

    public var columns: (simd_float3, simd_float3)
}

extension simd_float2x3 {

    /// Initialize matrix to have `scalar` on main diagonal, zeros elsewhere.
    public init(_ scalar: Float)

    /// Initialize matrix to have specified `diagonal`, and zeros elsewhere.
    public init(diagonal: SIMD2<Float>)

    /// Initialize matrix to have specified `columns`.
    public init(_ columns: [SIMD3<Float>])

    /// Initialize matrix to have specified `rows`.
    public init(rows: [SIMD2<Float>])

    /// Initialize matrix to have specified `columns`.
    public init(_ col0: SIMD3<Float>, _ col1: SIMD3<Float>)

    /// Initialize matrix from corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This conversion is no longer necessary; use `cmatrix` directly.")
    public init(_ cmatrix: simd_float2x3)

    /// Get the matrix as the corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This property is no longer needed; use the matrix itself.")
    public var cmatrix: simd_float2x3 { get }

    /// Access to individual columns.
    public subscript(column: Int) -> SIMD3<Float>

    /// Access to individual elements.
    public subscript(column: Int, row: Int) -> Float
}

extension simd_float2x3 : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(reflecting:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `debugDescription` property for types that conform to
    /// `CustomDebugStringConvertible`:
    ///
    ///     struct Point: CustomDebugStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var debugDescription: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(reflecting: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `debugDescription` property.
    @inlinable public var debugDescription: String { get }
}

extension simd_float2x3 : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: simd_float2x3, rhs: simd_float2x3) -> Bool
}

extension simd_float2x3 {

    /// Transpose of the matrix.
    public var transpose: float3x2 { get }

    /// Sum of two matrices.
    public static func + (lhs: simd_float2x3, rhs: simd_float2x3) -> simd_float2x3

    /// Negation of a matrix.
    prefix public static func - (rhs: simd_float2x3) -> simd_float2x3

    /// Difference of two matrices.
    public static func - (lhs: simd_float2x3, rhs: simd_float2x3) -> simd_float2x3

    public static func += (lhs: inout simd_float2x3, rhs: simd_float2x3)

    public static func -= (lhs: inout simd_float2x3, rhs: simd_float2x3)

    /// Scalar-Matrix multiplication.
    public static func * (lhs: Float, rhs: simd_float2x3) -> simd_float2x3

    /// Matrix-Scalar multiplication.
    public static func * (lhs: simd_float2x3, rhs: Float) -> simd_float2x3

    public static func *= (lhs: inout simd_float2x3, rhs: Float)

    /// Matrix-Vector multiplication.  Keep in mind that matrix types are named
    /// `FloatNxM` where `N` is the number of *columns* and `M` is the number of
    /// *rows*, so we multiply a `Float3x2 * Float3` to get a `Float2`, for
    /// example.
    public static func * (lhs: simd_float2x3, rhs: SIMD2<Float>) -> SIMD3<Float>

    /// Vector-Matrix multiplication.
    public static func * (lhs: SIMD3<Float>, rhs: simd_float2x3) -> SIMD2<Float>

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float2x3, rhs: float2x2) -> float2x3

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float2x3, rhs: float3x2) -> float3x3

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float2x3, rhs: float4x2) -> float4x3

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func *= (lhs: inout simd_float2x3, rhs: float2x2)
}

/** @abstract A matrix with 3 rows and 3 columns.                             */
public struct simd_float3x3 {

    public init()

    public init(columns: (simd_float3, simd_float3, simd_float3))

    public var columns: (simd_float3, simd_float3, simd_float3)
}

extension simd_float3x3 {

    /// Initialize matrix to have `scalar` on main diagonal, zeros elsewhere.
    public init(_ scalar: Float)

    /// Initialize matrix to have specified `diagonal`, and zeros elsewhere.
    public init(diagonal: SIMD3<Float>)

    /// Initialize matrix to have specified `columns`.
    public init(_ columns: [SIMD3<Float>])

    /// Initialize matrix to have specified `rows`.
    public init(rows: [SIMD3<Float>])

    /// Initialize matrix to have specified `columns`.
    public init(_ col0: SIMD3<Float>, _ col1: SIMD3<Float>, _ col2: SIMD3<Float>)

    /// Initialize matrix from corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This conversion is no longer necessary; use `cmatrix` directly.")
    public init(_ cmatrix: simd_float3x3)

    /// Get the matrix as the corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This property is no longer needed; use the matrix itself.")
    public var cmatrix: simd_float3x3 { get }

    /// Access to individual columns.
    public subscript(column: Int) -> SIMD3<Float>

    /// Access to individual elements.
    public subscript(column: Int, row: Int) -> Float
}

extension simd_float3x3 : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(reflecting:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `debugDescription` property for types that conform to
    /// `CustomDebugStringConvertible`:
    ///
    ///     struct Point: CustomDebugStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var debugDescription: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(reflecting: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `debugDescription` property.
    @inlinable public var debugDescription: String { get }
}

extension simd_float3x3 : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: simd_float3x3, rhs: simd_float3x3) -> Bool
}

extension simd_float3x3 {

    /// Transpose of the matrix.
    public var transpose: float3x3 { get }

    /// Inverse of the matrix if it exists, otherwise the contents of the
    /// resulting matrix are undefined.
    @available(macOS 10.10, iOS 8.0, tvOS 10.0, watchOS 3.0, *)
    public var inverse: simd_float3x3 { get }

    /// Determinant of the matrix.
    public var determinant: Float { get }

    /// Sum of two matrices.
    public static func + (lhs: simd_float3x3, rhs: simd_float3x3) -> simd_float3x3

    /// Negation of a matrix.
    prefix public static func - (rhs: simd_float3x3) -> simd_float3x3

    /// Difference of two matrices.
    public static func - (lhs: simd_float3x3, rhs: simd_float3x3) -> simd_float3x3

    public static func += (lhs: inout simd_float3x3, rhs: simd_float3x3)

    public static func -= (lhs: inout simd_float3x3, rhs: simd_float3x3)

    /// Scalar-Matrix multiplication.
    public static func * (lhs: Float, rhs: simd_float3x3) -> simd_float3x3

    /// Matrix-Scalar multiplication.
    public static func * (lhs: simd_float3x3, rhs: Float) -> simd_float3x3

    public static func *= (lhs: inout simd_float3x3, rhs: Float)

    /// Matrix-Vector multiplication.  Keep in mind that matrix types are named
    /// `FloatNxM` where `N` is the number of *columns* and `M` is the number of
    /// *rows*, so we multiply a `Float3x2 * Float3` to get a `Float2`, for
    /// example.
    public static func * (lhs: simd_float3x3, rhs: SIMD3<Float>) -> SIMD3<Float>

    /// Vector-Matrix multiplication.
    public static func * (lhs: SIMD3<Float>, rhs: simd_float3x3) -> SIMD3<Float>

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float3x3, rhs: float2x3) -> float2x3

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float3x3, rhs: float3x3) -> float3x3

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float3x3, rhs: float4x3) -> float4x3

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func *= (lhs: inout simd_float3x3, rhs: float3x3)
}

extension simd_float3x3 {

    /// Construct a 3x3 matrix from `quaternion`.
    public init(_ quaternion: simd_quatf)
}

/** @abstract A matrix with 3 rows and 4 columns.                             */
public struct simd_float4x3 {

    public init()

    public init(columns: (simd_float3, simd_float3, simd_float3, simd_float3))

    public var columns: (simd_float3, simd_float3, simd_float3, simd_float3)
}

extension simd_float4x3 {

    /// Initialize matrix to have `scalar` on main diagonal, zeros elsewhere.
    public init(_ scalar: Float)

    /// Initialize matrix to have specified `diagonal`, and zeros elsewhere.
    public init(diagonal: SIMD3<Float>)

    /// Initialize matrix to have specified `columns`.
    public init(_ columns: [SIMD3<Float>])

    /// Initialize matrix to have specified `rows`.
    public init(rows: [SIMD4<Float>])

    /// Initialize matrix to have specified `columns`.
    public init(_ col0: SIMD3<Float>, _ col1: SIMD3<Float>, _ col2: SIMD3<Float>, _ col3: SIMD3<Float>)

    /// Initialize matrix from corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This conversion is no longer necessary; use `cmatrix` directly.")
    public init(_ cmatrix: simd_float4x3)

    /// Get the matrix as the corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This property is no longer needed; use the matrix itself.")
    public var cmatrix: simd_float4x3 { get }

    /// Access to individual columns.
    public subscript(column: Int) -> SIMD3<Float>

    /// Access to individual elements.
    public subscript(column: Int, row: Int) -> Float
}

extension simd_float4x3 : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(reflecting:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `debugDescription` property for types that conform to
    /// `CustomDebugStringConvertible`:
    ///
    ///     struct Point: CustomDebugStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var debugDescription: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(reflecting: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `debugDescription` property.
    @inlinable public var debugDescription: String { get }
}

extension simd_float4x3 : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: simd_float4x3, rhs: simd_float4x3) -> Bool
}

extension simd_float4x3 {

    /// Transpose of the matrix.
    public var transpose: float3x4 { get }

    /// Sum of two matrices.
    public static func + (lhs: simd_float4x3, rhs: simd_float4x3) -> simd_float4x3

    /// Negation of a matrix.
    prefix public static func - (rhs: simd_float4x3) -> simd_float4x3

    /// Difference of two matrices.
    public static func - (lhs: simd_float4x3, rhs: simd_float4x3) -> simd_float4x3

    public static func += (lhs: inout simd_float4x3, rhs: simd_float4x3)

    public static func -= (lhs: inout simd_float4x3, rhs: simd_float4x3)

    /// Scalar-Matrix multiplication.
    public static func * (lhs: Float, rhs: simd_float4x3) -> simd_float4x3

    /// Matrix-Scalar multiplication.
    public static func * (lhs: simd_float4x3, rhs: Float) -> simd_float4x3

    public static func *= (lhs: inout simd_float4x3, rhs: Float)

    /// Matrix-Vector multiplication.  Keep in mind that matrix types are named
    /// `FloatNxM` where `N` is the number of *columns* and `M` is the number of
    /// *rows*, so we multiply a `Float3x2 * Float3` to get a `Float2`, for
    /// example.
    public static func * (lhs: simd_float4x3, rhs: SIMD4<Float>) -> SIMD3<Float>

    /// Vector-Matrix multiplication.
    public static func * (lhs: SIMD3<Float>, rhs: simd_float4x3) -> SIMD4<Float>

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float4x3, rhs: float2x4) -> float2x3

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float4x3, rhs: float3x4) -> float3x3

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float4x3, rhs: float4x4) -> float4x3

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func *= (lhs: inout simd_float4x3, rhs: float4x4)
}

/** @abstract A matrix with 4 rows and 2 columns.                             */
public struct simd_float2x4 {

    public init()

    public init(columns: (simd_float4, simd_float4))

    public var columns: (simd_float4, simd_float4)
}

extension simd_float2x4 {

    /// Initialize matrix to have `scalar` on main diagonal, zeros elsewhere.
    public init(_ scalar: Float)

    /// Initialize matrix to have specified `diagonal`, and zeros elsewhere.
    public init(diagonal: SIMD2<Float>)

    /// Initialize matrix to have specified `columns`.
    public init(_ columns: [SIMD4<Float>])

    /// Initialize matrix to have specified `rows`.
    public init(rows: [SIMD2<Float>])

    /// Initialize matrix to have specified `columns`.
    public init(_ col0: SIMD4<Float>, _ col1: SIMD4<Float>)

    /// Initialize matrix from corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This conversion is no longer necessary; use `cmatrix` directly.")
    public init(_ cmatrix: simd_float2x4)

    /// Get the matrix as the corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This property is no longer needed; use the matrix itself.")
    public var cmatrix: simd_float2x4 { get }

    /// Access to individual columns.
    public subscript(column: Int) -> SIMD4<Float>

    /// Access to individual elements.
    public subscript(column: Int, row: Int) -> Float
}

extension simd_float2x4 : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(reflecting:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `debugDescription` property for types that conform to
    /// `CustomDebugStringConvertible`:
    ///
    ///     struct Point: CustomDebugStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var debugDescription: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(reflecting: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `debugDescription` property.
    @inlinable public var debugDescription: String { get }
}

extension simd_float2x4 : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: simd_float2x4, rhs: simd_float2x4) -> Bool
}

extension simd_float2x4 {

    /// Transpose of the matrix.
    public var transpose: float4x2 { get }

    /// Sum of two matrices.
    public static func + (lhs: simd_float2x4, rhs: simd_float2x4) -> simd_float2x4

    /// Negation of a matrix.
    prefix public static func - (rhs: simd_float2x4) -> simd_float2x4

    /// Difference of two matrices.
    public static func - (lhs: simd_float2x4, rhs: simd_float2x4) -> simd_float2x4

    public static func += (lhs: inout simd_float2x4, rhs: simd_float2x4)

    public static func -= (lhs: inout simd_float2x4, rhs: simd_float2x4)

    /// Scalar-Matrix multiplication.
    public static func * (lhs: Float, rhs: simd_float2x4) -> simd_float2x4

    /// Matrix-Scalar multiplication.
    public static func * (lhs: simd_float2x4, rhs: Float) -> simd_float2x4

    public static func *= (lhs: inout simd_float2x4, rhs: Float)

    /// Matrix-Vector multiplication.  Keep in mind that matrix types are named
    /// `FloatNxM` where `N` is the number of *columns* and `M` is the number of
    /// *rows*, so we multiply a `Float3x2 * Float3` to get a `Float2`, for
    /// example.
    public static func * (lhs: simd_float2x4, rhs: SIMD2<Float>) -> SIMD4<Float>

    /// Vector-Matrix multiplication.
    public static func * (lhs: SIMD4<Float>, rhs: simd_float2x4) -> SIMD2<Float>

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float2x4, rhs: float2x2) -> float2x4

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float2x4, rhs: float3x2) -> float3x4

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float2x4, rhs: float4x2) -> float4x4

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func *= (lhs: inout simd_float2x4, rhs: float2x2)
}

/** @abstract A matrix with 4 rows and 3 columns.                             */
public struct simd_float3x4 {

    public init()

    public init(columns: (simd_float4, simd_float4, simd_float4))

    public var columns: (simd_float4, simd_float4, simd_float4)
}

extension simd_float3x4 {

    /// Initialize matrix to have `scalar` on main diagonal, zeros elsewhere.
    public init(_ scalar: Float)

    /// Initialize matrix to have specified `diagonal`, and zeros elsewhere.
    public init(diagonal: SIMD3<Float>)

    /// Initialize matrix to have specified `columns`.
    public init(_ columns: [SIMD4<Float>])

    /// Initialize matrix to have specified `rows`.
    public init(rows: [SIMD3<Float>])

    /// Initialize matrix to have specified `columns`.
    public init(_ col0: SIMD4<Float>, _ col1: SIMD4<Float>, _ col2: SIMD4<Float>)

    /// Initialize matrix from corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This conversion is no longer necessary; use `cmatrix` directly.")
    public init(_ cmatrix: simd_float3x4)

    /// Get the matrix as the corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This property is no longer needed; use the matrix itself.")
    public var cmatrix: simd_float3x4 { get }

    /// Access to individual columns.
    public subscript(column: Int) -> SIMD4<Float>

    /// Access to individual elements.
    public subscript(column: Int, row: Int) -> Float
}

extension simd_float3x4 : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(reflecting:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `debugDescription` property for types that conform to
    /// `CustomDebugStringConvertible`:
    ///
    ///     struct Point: CustomDebugStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var debugDescription: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(reflecting: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `debugDescription` property.
    @inlinable public var debugDescription: String { get }
}

extension simd_float3x4 : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: simd_float3x4, rhs: simd_float3x4) -> Bool
}

extension simd_float3x4 {

    /// Transpose of the matrix.
    public var transpose: float4x3 { get }

    /// Sum of two matrices.
    public static func + (lhs: simd_float3x4, rhs: simd_float3x4) -> simd_float3x4

    /// Negation of a matrix.
    prefix public static func - (rhs: simd_float3x4) -> simd_float3x4

    /// Difference of two matrices.
    public static func - (lhs: simd_float3x4, rhs: simd_float3x4) -> simd_float3x4

    public static func += (lhs: inout simd_float3x4, rhs: simd_float3x4)

    public static func -= (lhs: inout simd_float3x4, rhs: simd_float3x4)

    /// Scalar-Matrix multiplication.
    public static func * (lhs: Float, rhs: simd_float3x4) -> simd_float3x4

    /// Matrix-Scalar multiplication.
    public static func * (lhs: simd_float3x4, rhs: Float) -> simd_float3x4

    public static func *= (lhs: inout simd_float3x4, rhs: Float)

    /// Matrix-Vector multiplication.  Keep in mind that matrix types are named
    /// `FloatNxM` where `N` is the number of *columns* and `M` is the number of
    /// *rows*, so we multiply a `Float3x2 * Float3` to get a `Float2`, for
    /// example.
    public static func * (lhs: simd_float3x4, rhs: SIMD3<Float>) -> SIMD4<Float>

    /// Vector-Matrix multiplication.
    public static func * (lhs: SIMD4<Float>, rhs: simd_float3x4) -> SIMD3<Float>

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float3x4, rhs: float2x3) -> float2x4

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float3x4, rhs: float3x3) -> float3x4

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float3x4, rhs: float4x3) -> float4x4

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func *= (lhs: inout simd_float3x4, rhs: float3x3)
}

/** @abstract A matrix with 4 rows and 4 columns.                             */
public struct simd_float4x4 {

    public init()

    public init(columns: (simd_float4, simd_float4, simd_float4, simd_float4))

    public var columns: (simd_float4, simd_float4, simd_float4, simd_float4)
}

extension simd_float4x4 {

    /// Initialize matrix to have `scalar` on main diagonal, zeros elsewhere.
    public init(_ scalar: Float)

    /// Initialize matrix to have specified `diagonal`, and zeros elsewhere.
    public init(diagonal: SIMD4<Float>)

    /// Initialize matrix to have specified `columns`.
    public init(_ columns: [SIMD4<Float>])

    /// Initialize matrix to have specified `rows`.
    public init(rows: [SIMD4<Float>])

    /// Initialize matrix to have specified `columns`.
    public init(_ col0: SIMD4<Float>, _ col1: SIMD4<Float>, _ col2: SIMD4<Float>, _ col3: SIMD4<Float>)

    /// Initialize matrix from corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This conversion is no longer necessary; use `cmatrix` directly.")
    public init(_ cmatrix: simd_float4x4)

    /// Get the matrix as the corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This property is no longer needed; use the matrix itself.")
    public var cmatrix: simd_float4x4 { get }

    /// Access to individual columns.
    public subscript(column: Int) -> SIMD4<Float>

    /// Access to individual elements.
    public subscript(column: Int, row: Int) -> Float
}

extension simd_float4x4 : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(reflecting:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `debugDescription` property for types that conform to
    /// `CustomDebugStringConvertible`:
    ///
    ///     struct Point: CustomDebugStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var debugDescription: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(reflecting: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `debugDescription` property.
    @inlinable public var debugDescription: String { get }
}

extension simd_float4x4 : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: simd_float4x4, rhs: simd_float4x4) -> Bool
}

extension simd_float4x4 {

    /// Transpose of the matrix.
    public var transpose: float4x4 { get }

    /// Inverse of the matrix if it exists, otherwise the contents of the
    /// resulting matrix are undefined.
    @available(macOS 10.10, iOS 8.0, tvOS 10.0, watchOS 3.0, *)
    public var inverse: simd_float4x4 { get }

    /// Determinant of the matrix.
    public var determinant: Float { get }

    /// Sum of two matrices.
    public static func + (lhs: simd_float4x4, rhs: simd_float4x4) -> simd_float4x4

    /// Negation of a matrix.
    prefix public static func - (rhs: simd_float4x4) -> simd_float4x4

    /// Difference of two matrices.
    public static func - (lhs: simd_float4x4, rhs: simd_float4x4) -> simd_float4x4

    public static func += (lhs: inout simd_float4x4, rhs: simd_float4x4)

    public static func -= (lhs: inout simd_float4x4, rhs: simd_float4x4)

    /// Scalar-Matrix multiplication.
    public static func * (lhs: Float, rhs: simd_float4x4) -> simd_float4x4

    /// Matrix-Scalar multiplication.
    public static func * (lhs: simd_float4x4, rhs: Float) -> simd_float4x4

    public static func *= (lhs: inout simd_float4x4, rhs: Float)

    /// Matrix-Vector multiplication.  Keep in mind that matrix types are named
    /// `FloatNxM` where `N` is the number of *columns* and `M` is the number of
    /// *rows*, so we multiply a `Float3x2 * Float3` to get a `Float2`, for
    /// example.
    public static func * (lhs: simd_float4x4, rhs: SIMD4<Float>) -> SIMD4<Float>

    /// Vector-Matrix multiplication.
    public static func * (lhs: SIMD4<Float>, rhs: simd_float4x4) -> SIMD4<Float>

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float4x4, rhs: float2x4) -> float2x4

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float4x4, rhs: float3x4) -> float3x4

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_float4x4, rhs: float4x4) -> float4x4

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func *= (lhs: inout simd_float4x4, rhs: float4x4)
}

extension simd_float4x4 {

    /// Construct a 4x4 matrix from `quaternion`.
    public init(_ quaternion: simd_quatf)
}

/** @abstract A matrix with 2 rows and 2 columns.                             */
public struct simd_double2x2 {

    public init()

    public init(columns: (simd_double2, simd_double2))

    public var columns: (simd_double2, simd_double2)
}

extension simd_double2x2 {

    /// Initialize matrix to have `scalar` on main diagonal, zeros elsewhere.
    public init(_ scalar: Double)

    /// Initialize matrix to have specified `diagonal`, and zeros elsewhere.
    public init(diagonal: SIMD2<Double>)

    /// Initialize matrix to have specified `columns`.
    public init(_ columns: [SIMD2<Double>])

    /// Initialize matrix to have specified `rows`.
    public init(rows: [SIMD2<Double>])

    /// Initialize matrix to have specified `columns`.
    public init(_ col0: SIMD2<Double>, _ col1: SIMD2<Double>)

    /// Initialize matrix from corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This conversion is no longer necessary; use `cmatrix` directly.")
    public init(_ cmatrix: simd_double2x2)

    /// Get the matrix as the corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This property is no longer needed; use the matrix itself.")
    public var cmatrix: simd_double2x2 { get }

    /// Access to individual columns.
    public subscript(column: Int) -> SIMD2<Double>

    /// Access to individual elements.
    public subscript(column: Int, row: Int) -> Double
}

extension simd_double2x2 : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(reflecting:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `debugDescription` property for types that conform to
    /// `CustomDebugStringConvertible`:
    ///
    ///     struct Point: CustomDebugStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var debugDescription: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(reflecting: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `debugDescription` property.
    @inlinable public var debugDescription: String { get }
}

extension simd_double2x2 : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: simd_double2x2, rhs: simd_double2x2) -> Bool
}

extension simd_double2x2 {

    /// Transpose of the matrix.
    public var transpose: double2x2 { get }

    /// Inverse of the matrix if it exists, otherwise the contents of the
    /// resulting matrix are undefined.
    @available(macOS 10.10, iOS 8.0, tvOS 10.0, watchOS 3.0, *)
    public var inverse: simd_double2x2 { get }

    /// Determinant of the matrix.
    public var determinant: Double { get }

    /// Sum of two matrices.
    public static func + (lhs: simd_double2x2, rhs: simd_double2x2) -> simd_double2x2

    /// Negation of a matrix.
    prefix public static func - (rhs: simd_double2x2) -> simd_double2x2

    /// Difference of two matrices.
    public static func - (lhs: simd_double2x2, rhs: simd_double2x2) -> simd_double2x2

    public static func += (lhs: inout simd_double2x2, rhs: simd_double2x2)

    public static func -= (lhs: inout simd_double2x2, rhs: simd_double2x2)

    /// Scalar-Matrix multiplication.
    public static func * (lhs: Double, rhs: simd_double2x2) -> simd_double2x2

    /// Matrix-Scalar multiplication.
    public static func * (lhs: simd_double2x2, rhs: Double) -> simd_double2x2

    public static func *= (lhs: inout simd_double2x2, rhs: Double)

    /// Matrix-Vector multiplication.  Keep in mind that matrix types are named
    /// `DoubleNxM` where `N` is the number of *columns* and `M` is the number of
    /// *rows*, so we multiply a `Double3x2 * Double3` to get a `Double2`, for
    /// example.
    public static func * (lhs: simd_double2x2, rhs: SIMD2<Double>) -> SIMD2<Double>

    /// Vector-Matrix multiplication.
    public static func * (lhs: SIMD2<Double>, rhs: simd_double2x2) -> SIMD2<Double>

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double2x2, rhs: double2x2) -> double2x2

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double2x2, rhs: double3x2) -> double3x2

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double2x2, rhs: double4x2) -> double4x2

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func *= (lhs: inout simd_double2x2, rhs: double2x2)
}

/** @abstract A matrix with 2 rows and 3 columns.                             */
public struct simd_double3x2 {

    public init()

    public init(columns: (simd_double2, simd_double2, simd_double2))

    public var columns: (simd_double2, simd_double2, simd_double2)
}

extension simd_double3x2 {

    /// Initialize matrix to have `scalar` on main diagonal, zeros elsewhere.
    public init(_ scalar: Double)

    /// Initialize matrix to have specified `diagonal`, and zeros elsewhere.
    public init(diagonal: SIMD2<Double>)

    /// Initialize matrix to have specified `columns`.
    public init(_ columns: [SIMD2<Double>])

    /// Initialize matrix to have specified `rows`.
    public init(rows: [SIMD3<Double>])

    /// Initialize matrix to have specified `columns`.
    public init(_ col0: SIMD2<Double>, _ col1: SIMD2<Double>, _ col2: SIMD2<Double>)

    /// Initialize matrix from corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This conversion is no longer necessary; use `cmatrix` directly.")
    public init(_ cmatrix: simd_double3x2)

    /// Get the matrix as the corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This property is no longer needed; use the matrix itself.")
    public var cmatrix: simd_double3x2 { get }

    /// Access to individual columns.
    public subscript(column: Int) -> SIMD2<Double>

    /// Access to individual elements.
    public subscript(column: Int, row: Int) -> Double
}

extension simd_double3x2 : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(reflecting:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `debugDescription` property for types that conform to
    /// `CustomDebugStringConvertible`:
    ///
    ///     struct Point: CustomDebugStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var debugDescription: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(reflecting: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `debugDescription` property.
    @inlinable public var debugDescription: String { get }
}

extension simd_double3x2 : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: simd_double3x2, rhs: simd_double3x2) -> Bool
}

extension simd_double3x2 {

    /// Transpose of the matrix.
    public var transpose: double2x3 { get }

    /// Sum of two matrices.
    public static func + (lhs: simd_double3x2, rhs: simd_double3x2) -> simd_double3x2

    /// Negation of a matrix.
    prefix public static func - (rhs: simd_double3x2) -> simd_double3x2

    /// Difference of two matrices.
    public static func - (lhs: simd_double3x2, rhs: simd_double3x2) -> simd_double3x2

    public static func += (lhs: inout simd_double3x2, rhs: simd_double3x2)

    public static func -= (lhs: inout simd_double3x2, rhs: simd_double3x2)

    /// Scalar-Matrix multiplication.
    public static func * (lhs: Double, rhs: simd_double3x2) -> simd_double3x2

    /// Matrix-Scalar multiplication.
    public static func * (lhs: simd_double3x2, rhs: Double) -> simd_double3x2

    public static func *= (lhs: inout simd_double3x2, rhs: Double)

    /// Matrix-Vector multiplication.  Keep in mind that matrix types are named
    /// `DoubleNxM` where `N` is the number of *columns* and `M` is the number of
    /// *rows*, so we multiply a `Double3x2 * Double3` to get a `Double2`, for
    /// example.
    public static func * (lhs: simd_double3x2, rhs: SIMD3<Double>) -> SIMD2<Double>

    /// Vector-Matrix multiplication.
    public static func * (lhs: SIMD2<Double>, rhs: simd_double3x2) -> SIMD3<Double>

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double3x2, rhs: double2x3) -> double2x2

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double3x2, rhs: double3x3) -> double3x2

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double3x2, rhs: double4x3) -> double4x2

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func *= (lhs: inout simd_double3x2, rhs: double3x3)
}

/** @abstract A matrix with 2 rows and 4 columns.                             */
public struct simd_double4x2 {

    public init()

    public init(columns: (simd_double2, simd_double2, simd_double2, simd_double2))

    public var columns: (simd_double2, simd_double2, simd_double2, simd_double2)
}

extension simd_double4x2 {

    /// Initialize matrix to have `scalar` on main diagonal, zeros elsewhere.
    public init(_ scalar: Double)

    /// Initialize matrix to have specified `diagonal`, and zeros elsewhere.
    public init(diagonal: SIMD2<Double>)

    /// Initialize matrix to have specified `columns`.
    public init(_ columns: [SIMD2<Double>])

    /// Initialize matrix to have specified `rows`.
    public init(rows: [SIMD4<Double>])

    /// Initialize matrix to have specified `columns`.
    public init(_ col0: SIMD2<Double>, _ col1: SIMD2<Double>, _ col2: SIMD2<Double>, _ col3: SIMD2<Double>)

    /// Initialize matrix from corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This conversion is no longer necessary; use `cmatrix` directly.")
    public init(_ cmatrix: simd_double4x2)

    /// Get the matrix as the corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This property is no longer needed; use the matrix itself.")
    public var cmatrix: simd_double4x2 { get }

    /// Access to individual columns.
    public subscript(column: Int) -> SIMD2<Double>

    /// Access to individual elements.
    public subscript(column: Int, row: Int) -> Double
}

extension simd_double4x2 : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(reflecting:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `debugDescription` property for types that conform to
    /// `CustomDebugStringConvertible`:
    ///
    ///     struct Point: CustomDebugStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var debugDescription: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(reflecting: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `debugDescription` property.
    @inlinable public var debugDescription: String { get }
}

extension simd_double4x2 : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: simd_double4x2, rhs: simd_double4x2) -> Bool
}

extension simd_double4x2 {

    /// Transpose of the matrix.
    public var transpose: double2x4 { get }

    /// Sum of two matrices.
    public static func + (lhs: simd_double4x2, rhs: simd_double4x2) -> simd_double4x2

    /// Negation of a matrix.
    prefix public static func - (rhs: simd_double4x2) -> simd_double4x2

    /// Difference of two matrices.
    public static func - (lhs: simd_double4x2, rhs: simd_double4x2) -> simd_double4x2

    public static func += (lhs: inout simd_double4x2, rhs: simd_double4x2)

    public static func -= (lhs: inout simd_double4x2, rhs: simd_double4x2)

    /// Scalar-Matrix multiplication.
    public static func * (lhs: Double, rhs: simd_double4x2) -> simd_double4x2

    /// Matrix-Scalar multiplication.
    public static func * (lhs: simd_double4x2, rhs: Double) -> simd_double4x2

    public static func *= (lhs: inout simd_double4x2, rhs: Double)

    /// Matrix-Vector multiplication.  Keep in mind that matrix types are named
    /// `DoubleNxM` where `N` is the number of *columns* and `M` is the number of
    /// *rows*, so we multiply a `Double3x2 * Double3` to get a `Double2`, for
    /// example.
    public static func * (lhs: simd_double4x2, rhs: SIMD4<Double>) -> SIMD2<Double>

    /// Vector-Matrix multiplication.
    public static func * (lhs: SIMD2<Double>, rhs: simd_double4x2) -> SIMD4<Double>

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double4x2, rhs: double2x4) -> double2x2

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double4x2, rhs: double3x4) -> double3x2

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double4x2, rhs: double4x4) -> double4x2

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func *= (lhs: inout simd_double4x2, rhs: double4x4)
}

/** @abstract A matrix with 3 rows and 2 columns.                             */
public struct simd_double2x3 {

    public init()

    public init(columns: (simd_double3, simd_double3))

    public var columns: (simd_double3, simd_double3)
}

extension simd_double2x3 {

    /// Initialize matrix to have `scalar` on main diagonal, zeros elsewhere.
    public init(_ scalar: Double)

    /// Initialize matrix to have specified `diagonal`, and zeros elsewhere.
    public init(diagonal: SIMD2<Double>)

    /// Initialize matrix to have specified `columns`.
    public init(_ columns: [SIMD3<Double>])

    /// Initialize matrix to have specified `rows`.
    public init(rows: [SIMD2<Double>])

    /// Initialize matrix to have specified `columns`.
    public init(_ col0: SIMD3<Double>, _ col1: SIMD3<Double>)

    /// Initialize matrix from corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This conversion is no longer necessary; use `cmatrix` directly.")
    public init(_ cmatrix: simd_double2x3)

    /// Get the matrix as the corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This property is no longer needed; use the matrix itself.")
    public var cmatrix: simd_double2x3 { get }

    /// Access to individual columns.
    public subscript(column: Int) -> SIMD3<Double>

    /// Access to individual elements.
    public subscript(column: Int, row: Int) -> Double
}

extension simd_double2x3 : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(reflecting:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `debugDescription` property for types that conform to
    /// `CustomDebugStringConvertible`:
    ///
    ///     struct Point: CustomDebugStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var debugDescription: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(reflecting: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `debugDescription` property.
    @inlinable public var debugDescription: String { get }
}

extension simd_double2x3 : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: simd_double2x3, rhs: simd_double2x3) -> Bool
}

extension simd_double2x3 {

    /// Transpose of the matrix.
    public var transpose: double3x2 { get }

    /// Sum of two matrices.
    public static func + (lhs: simd_double2x3, rhs: simd_double2x3) -> simd_double2x3

    /// Negation of a matrix.
    prefix public static func - (rhs: simd_double2x3) -> simd_double2x3

    /// Difference of two matrices.
    public static func - (lhs: simd_double2x3, rhs: simd_double2x3) -> simd_double2x3

    public static func += (lhs: inout simd_double2x3, rhs: simd_double2x3)

    public static func -= (lhs: inout simd_double2x3, rhs: simd_double2x3)

    /// Scalar-Matrix multiplication.
    public static func * (lhs: Double, rhs: simd_double2x3) -> simd_double2x3

    /// Matrix-Scalar multiplication.
    public static func * (lhs: simd_double2x3, rhs: Double) -> simd_double2x3

    public static func *= (lhs: inout simd_double2x3, rhs: Double)

    /// Matrix-Vector multiplication.  Keep in mind that matrix types are named
    /// `DoubleNxM` where `N` is the number of *columns* and `M` is the number of
    /// *rows*, so we multiply a `Double3x2 * Double3` to get a `Double2`, for
    /// example.
    public static func * (lhs: simd_double2x3, rhs: SIMD2<Double>) -> SIMD3<Double>

    /// Vector-Matrix multiplication.
    public static func * (lhs: SIMD3<Double>, rhs: simd_double2x3) -> SIMD2<Double>

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double2x3, rhs: double2x2) -> double2x3

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double2x3, rhs: double3x2) -> double3x3

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double2x3, rhs: double4x2) -> double4x3

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func *= (lhs: inout simd_double2x3, rhs: double2x2)
}

/** @abstract A matrix with 3 rows and 3 columns.                             */
public struct simd_double3x3 {

    public init()

    public init(columns: (simd_double3, simd_double3, simd_double3))

    public var columns: (simd_double3, simd_double3, simd_double3)
}

extension simd_double3x3 {

    /// Initialize matrix to have `scalar` on main diagonal, zeros elsewhere.
    public init(_ scalar: Double)

    /// Initialize matrix to have specified `diagonal`, and zeros elsewhere.
    public init(diagonal: SIMD3<Double>)

    /// Initialize matrix to have specified `columns`.
    public init(_ columns: [SIMD3<Double>])

    /// Initialize matrix to have specified `rows`.
    public init(rows: [SIMD3<Double>])

    /// Initialize matrix to have specified `columns`.
    public init(_ col0: SIMD3<Double>, _ col1: SIMD3<Double>, _ col2: SIMD3<Double>)

    /// Initialize matrix from corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This conversion is no longer necessary; use `cmatrix` directly.")
    public init(_ cmatrix: simd_double3x3)

    /// Get the matrix as the corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This property is no longer needed; use the matrix itself.")
    public var cmatrix: simd_double3x3 { get }

    /// Access to individual columns.
    public subscript(column: Int) -> SIMD3<Double>

    /// Access to individual elements.
    public subscript(column: Int, row: Int) -> Double
}

extension simd_double3x3 : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(reflecting:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `debugDescription` property for types that conform to
    /// `CustomDebugStringConvertible`:
    ///
    ///     struct Point: CustomDebugStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var debugDescription: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(reflecting: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `debugDescription` property.
    @inlinable public var debugDescription: String { get }
}

extension simd_double3x3 : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: simd_double3x3, rhs: simd_double3x3) -> Bool
}

extension simd_double3x3 {

    /// Transpose of the matrix.
    public var transpose: double3x3 { get }

    /// Inverse of the matrix if it exists, otherwise the contents of the
    /// resulting matrix are undefined.
    @available(macOS 10.10, iOS 8.0, tvOS 10.0, watchOS 3.0, *)
    public var inverse: simd_double3x3 { get }

    /// Determinant of the matrix.
    public var determinant: Double { get }

    /// Sum of two matrices.
    public static func + (lhs: simd_double3x3, rhs: simd_double3x3) -> simd_double3x3

    /// Negation of a matrix.
    prefix public static func - (rhs: simd_double3x3) -> simd_double3x3

    /// Difference of two matrices.
    public static func - (lhs: simd_double3x3, rhs: simd_double3x3) -> simd_double3x3

    public static func += (lhs: inout simd_double3x3, rhs: simd_double3x3)

    public static func -= (lhs: inout simd_double3x3, rhs: simd_double3x3)

    /// Scalar-Matrix multiplication.
    public static func * (lhs: Double, rhs: simd_double3x3) -> simd_double3x3

    /// Matrix-Scalar multiplication.
    public static func * (lhs: simd_double3x3, rhs: Double) -> simd_double3x3

    public static func *= (lhs: inout simd_double3x3, rhs: Double)

    /// Matrix-Vector multiplication.  Keep in mind that matrix types are named
    /// `DoubleNxM` where `N` is the number of *columns* and `M` is the number of
    /// *rows*, so we multiply a `Double3x2 * Double3` to get a `Double2`, for
    /// example.
    public static func * (lhs: simd_double3x3, rhs: SIMD3<Double>) -> SIMD3<Double>

    /// Vector-Matrix multiplication.
    public static func * (lhs: SIMD3<Double>, rhs: simd_double3x3) -> SIMD3<Double>

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double3x3, rhs: double2x3) -> double2x3

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double3x3, rhs: double3x3) -> double3x3

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double3x3, rhs: double4x3) -> double4x3

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func *= (lhs: inout simd_double3x3, rhs: double3x3)
}

extension simd_double3x3 {

    /// Construct a 3x3 matrix from `quaternion`.
    public init(_ quaternion: simd_quatd)
}

/** @abstract A matrix with 3 rows and 4 columns.                             */
public struct simd_double4x3 {

    public init()

    public init(columns: (simd_double3, simd_double3, simd_double3, simd_double3))

    public var columns: (simd_double3, simd_double3, simd_double3, simd_double3)
}

extension simd_double4x3 {

    /// Initialize matrix to have `scalar` on main diagonal, zeros elsewhere.
    public init(_ scalar: Double)

    /// Initialize matrix to have specified `diagonal`, and zeros elsewhere.
    public init(diagonal: SIMD3<Double>)

    /// Initialize matrix to have specified `columns`.
    public init(_ columns: [SIMD3<Double>])

    /// Initialize matrix to have specified `rows`.
    public init(rows: [SIMD4<Double>])

    /// Initialize matrix to have specified `columns`.
    public init(_ col0: SIMD3<Double>, _ col1: SIMD3<Double>, _ col2: SIMD3<Double>, _ col3: SIMD3<Double>)

    /// Initialize matrix from corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This conversion is no longer necessary; use `cmatrix` directly.")
    public init(_ cmatrix: simd_double4x3)

    /// Get the matrix as the corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This property is no longer needed; use the matrix itself.")
    public var cmatrix: simd_double4x3 { get }

    /// Access to individual columns.
    public subscript(column: Int) -> SIMD3<Double>

    /// Access to individual elements.
    public subscript(column: Int, row: Int) -> Double
}

extension simd_double4x3 : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(reflecting:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `debugDescription` property for types that conform to
    /// `CustomDebugStringConvertible`:
    ///
    ///     struct Point: CustomDebugStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var debugDescription: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(reflecting: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `debugDescription` property.
    @inlinable public var debugDescription: String { get }
}

extension simd_double4x3 : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: simd_double4x3, rhs: simd_double4x3) -> Bool
}

extension simd_double4x3 {

    /// Transpose of the matrix.
    public var transpose: double3x4 { get }

    /// Sum of two matrices.
    public static func + (lhs: simd_double4x3, rhs: simd_double4x3) -> simd_double4x3

    /// Negation of a matrix.
    prefix public static func - (rhs: simd_double4x3) -> simd_double4x3

    /// Difference of two matrices.
    public static func - (lhs: simd_double4x3, rhs: simd_double4x3) -> simd_double4x3

    public static func += (lhs: inout simd_double4x3, rhs: simd_double4x3)

    public static func -= (lhs: inout simd_double4x3, rhs: simd_double4x3)

    /// Scalar-Matrix multiplication.
    public static func * (lhs: Double, rhs: simd_double4x3) -> simd_double4x3

    /// Matrix-Scalar multiplication.
    public static func * (lhs: simd_double4x3, rhs: Double) -> simd_double4x3

    public static func *= (lhs: inout simd_double4x3, rhs: Double)

    /// Matrix-Vector multiplication.  Keep in mind that matrix types are named
    /// `DoubleNxM` where `N` is the number of *columns* and `M` is the number of
    /// *rows*, so we multiply a `Double3x2 * Double3` to get a `Double2`, for
    /// example.
    public static func * (lhs: simd_double4x3, rhs: SIMD4<Double>) -> SIMD3<Double>

    /// Vector-Matrix multiplication.
    public static func * (lhs: SIMD3<Double>, rhs: simd_double4x3) -> SIMD4<Double>

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double4x3, rhs: double2x4) -> double2x3

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double4x3, rhs: double3x4) -> double3x3

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double4x3, rhs: double4x4) -> double4x3

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func *= (lhs: inout simd_double4x3, rhs: double4x4)
}

/** @abstract A matrix with 4 rows and 2 columns.                             */
public struct simd_double2x4 {

    public init()

    public init(columns: (simd_double4, simd_double4))

    public var columns: (simd_double4, simd_double4)
}

extension simd_double2x4 {

    /// Initialize matrix to have `scalar` on main diagonal, zeros elsewhere.
    public init(_ scalar: Double)

    /// Initialize matrix to have specified `diagonal`, and zeros elsewhere.
    public init(diagonal: SIMD2<Double>)

    /// Initialize matrix to have specified `columns`.
    public init(_ columns: [SIMD4<Double>])

    /// Initialize matrix to have specified `rows`.
    public init(rows: [SIMD2<Double>])

    /// Initialize matrix to have specified `columns`.
    public init(_ col0: SIMD4<Double>, _ col1: SIMD4<Double>)

    /// Initialize matrix from corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This conversion is no longer necessary; use `cmatrix` directly.")
    public init(_ cmatrix: simd_double2x4)

    /// Get the matrix as the corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This property is no longer needed; use the matrix itself.")
    public var cmatrix: simd_double2x4 { get }

    /// Access to individual columns.
    public subscript(column: Int) -> SIMD4<Double>

    /// Access to individual elements.
    public subscript(column: Int, row: Int) -> Double
}

extension simd_double2x4 : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(reflecting:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `debugDescription` property for types that conform to
    /// `CustomDebugStringConvertible`:
    ///
    ///     struct Point: CustomDebugStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var debugDescription: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(reflecting: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `debugDescription` property.
    @inlinable public var debugDescription: String { get }
}

extension simd_double2x4 : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: simd_double2x4, rhs: simd_double2x4) -> Bool
}

extension simd_double2x4 {

    /// Transpose of the matrix.
    public var transpose: double4x2 { get }

    /// Sum of two matrices.
    public static func + (lhs: simd_double2x4, rhs: simd_double2x4) -> simd_double2x4

    /// Negation of a matrix.
    prefix public static func - (rhs: simd_double2x4) -> simd_double2x4

    /// Difference of two matrices.
    public static func - (lhs: simd_double2x4, rhs: simd_double2x4) -> simd_double2x4

    public static func += (lhs: inout simd_double2x4, rhs: simd_double2x4)

    public static func -= (lhs: inout simd_double2x4, rhs: simd_double2x4)

    /// Scalar-Matrix multiplication.
    public static func * (lhs: Double, rhs: simd_double2x4) -> simd_double2x4

    /// Matrix-Scalar multiplication.
    public static func * (lhs: simd_double2x4, rhs: Double) -> simd_double2x4

    public static func *= (lhs: inout simd_double2x4, rhs: Double)

    /// Matrix-Vector multiplication.  Keep in mind that matrix types are named
    /// `DoubleNxM` where `N` is the number of *columns* and `M` is the number of
    /// *rows*, so we multiply a `Double3x2 * Double3` to get a `Double2`, for
    /// example.
    public static func * (lhs: simd_double2x4, rhs: SIMD2<Double>) -> SIMD4<Double>

    /// Vector-Matrix multiplication.
    public static func * (lhs: SIMD4<Double>, rhs: simd_double2x4) -> SIMD2<Double>

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double2x4, rhs: double2x2) -> double2x4

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double2x4, rhs: double3x2) -> double3x4

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double2x4, rhs: double4x2) -> double4x4

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func *= (lhs: inout simd_double2x4, rhs: double2x2)
}

/** @abstract A matrix with 4 rows and 3 columns.                             */
public struct simd_double3x4 {

    public init()

    public init(columns: (simd_double4, simd_double4, simd_double4))

    public var columns: (simd_double4, simd_double4, simd_double4)
}

extension simd_double3x4 {

    /// Initialize matrix to have `scalar` on main diagonal, zeros elsewhere.
    public init(_ scalar: Double)

    /// Initialize matrix to have specified `diagonal`, and zeros elsewhere.
    public init(diagonal: SIMD3<Double>)

    /// Initialize matrix to have specified `columns`.
    public init(_ columns: [SIMD4<Double>])

    /// Initialize matrix to have specified `rows`.
    public init(rows: [SIMD3<Double>])

    /// Initialize matrix to have specified `columns`.
    public init(_ col0: SIMD4<Double>, _ col1: SIMD4<Double>, _ col2: SIMD4<Double>)

    /// Initialize matrix from corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This conversion is no longer necessary; use `cmatrix` directly.")
    public init(_ cmatrix: simd_double3x4)

    /// Get the matrix as the corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This property is no longer needed; use the matrix itself.")
    public var cmatrix: simd_double3x4 { get }

    /// Access to individual columns.
    public subscript(column: Int) -> SIMD4<Double>

    /// Access to individual elements.
    public subscript(column: Int, row: Int) -> Double
}

extension simd_double3x4 : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(reflecting:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `debugDescription` property for types that conform to
    /// `CustomDebugStringConvertible`:
    ///
    ///     struct Point: CustomDebugStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var debugDescription: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(reflecting: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `debugDescription` property.
    @inlinable public var debugDescription: String { get }
}

extension simd_double3x4 : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: simd_double3x4, rhs: simd_double3x4) -> Bool
}

extension simd_double3x4 {

    /// Transpose of the matrix.
    public var transpose: double4x3 { get }

    /// Sum of two matrices.
    public static func + (lhs: simd_double3x4, rhs: simd_double3x4) -> simd_double3x4

    /// Negation of a matrix.
    prefix public static func - (rhs: simd_double3x4) -> simd_double3x4

    /// Difference of two matrices.
    public static func - (lhs: simd_double3x4, rhs: simd_double3x4) -> simd_double3x4

    public static func += (lhs: inout simd_double3x4, rhs: simd_double3x4)

    public static func -= (lhs: inout simd_double3x4, rhs: simd_double3x4)

    /// Scalar-Matrix multiplication.
    public static func * (lhs: Double, rhs: simd_double3x4) -> simd_double3x4

    /// Matrix-Scalar multiplication.
    public static func * (lhs: simd_double3x4, rhs: Double) -> simd_double3x4

    public static func *= (lhs: inout simd_double3x4, rhs: Double)

    /// Matrix-Vector multiplication.  Keep in mind that matrix types are named
    /// `DoubleNxM` where `N` is the number of *columns* and `M` is the number of
    /// *rows*, so we multiply a `Double3x2 * Double3` to get a `Double2`, for
    /// example.
    public static func * (lhs: simd_double3x4, rhs: SIMD3<Double>) -> SIMD4<Double>

    /// Vector-Matrix multiplication.
    public static func * (lhs: SIMD4<Double>, rhs: simd_double3x4) -> SIMD3<Double>

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double3x4, rhs: double2x3) -> double2x4

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double3x4, rhs: double3x3) -> double3x4

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double3x4, rhs: double4x3) -> double4x4

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func *= (lhs: inout simd_double3x4, rhs: double3x3)
}

/** @abstract A matrix with 4 rows and 4 columns.                             */
public struct simd_double4x4 {

    public init()

    public init(columns: (simd_double4, simd_double4, simd_double4, simd_double4))

    public var columns: (simd_double4, simd_double4, simd_double4, simd_double4)
}

extension simd_double4x4 {

    /// Initialize matrix to have `scalar` on main diagonal, zeros elsewhere.
    public init(_ scalar: Double)

    /// Initialize matrix to have specified `diagonal`, and zeros elsewhere.
    public init(diagonal: SIMD4<Double>)

    /// Initialize matrix to have specified `columns`.
    public init(_ columns: [SIMD4<Double>])

    /// Initialize matrix to have specified `rows`.
    public init(rows: [SIMD4<Double>])

    /// Initialize matrix to have specified `columns`.
    public init(_ col0: SIMD4<Double>, _ col1: SIMD4<Double>, _ col2: SIMD4<Double>, _ col3: SIMD4<Double>)

    /// Initialize matrix from corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This conversion is no longer necessary; use `cmatrix` directly.")
    public init(_ cmatrix: simd_double4x4)

    /// Get the matrix as the corresponding C matrix type.
    @available(swift, deprecated: 4, message: "This property is no longer needed; use the matrix itself.")
    public var cmatrix: simd_double4x4 { get }

    /// Access to individual columns.
    public subscript(column: Int) -> SIMD4<Double>

    /// Access to individual elements.
    public subscript(column: Int, row: Int) -> Double
}

extension simd_double4x4 : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(reflecting:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `debugDescription` property for types that conform to
    /// `CustomDebugStringConvertible`:
    ///
    ///     struct Point: CustomDebugStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var debugDescription: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(reflecting: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `debugDescription` property.
    @inlinable public var debugDescription: String { get }
}

extension simd_double4x4 : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: simd_double4x4, rhs: simd_double4x4) -> Bool
}

extension simd_double4x4 {

    /// Transpose of the matrix.
    public var transpose: double4x4 { get }

    /// Inverse of the matrix if it exists, otherwise the contents of the
    /// resulting matrix are undefined.
    @available(macOS 10.10, iOS 8.0, tvOS 10.0, watchOS 3.0, *)
    public var inverse: simd_double4x4 { get }

    /// Determinant of the matrix.
    public var determinant: Double { get }

    /// Sum of two matrices.
    public static func + (lhs: simd_double4x4, rhs: simd_double4x4) -> simd_double4x4

    /// Negation of a matrix.
    prefix public static func - (rhs: simd_double4x4) -> simd_double4x4

    /// Difference of two matrices.
    public static func - (lhs: simd_double4x4, rhs: simd_double4x4) -> simd_double4x4

    public static func += (lhs: inout simd_double4x4, rhs: simd_double4x4)

    public static func -= (lhs: inout simd_double4x4, rhs: simd_double4x4)

    /// Scalar-Matrix multiplication.
    public static func * (lhs: Double, rhs: simd_double4x4) -> simd_double4x4

    /// Matrix-Scalar multiplication.
    public static func * (lhs: simd_double4x4, rhs: Double) -> simd_double4x4

    public static func *= (lhs: inout simd_double4x4, rhs: Double)

    /// Matrix-Vector multiplication.  Keep in mind that matrix types are named
    /// `DoubleNxM` where `N` is the number of *columns* and `M` is the number of
    /// *rows*, so we multiply a `Double3x2 * Double3` to get a `Double2`, for
    /// example.
    public static func * (lhs: simd_double4x4, rhs: SIMD4<Double>) -> SIMD4<Double>

    /// Vector-Matrix multiplication.
    public static func * (lhs: SIMD4<Double>, rhs: simd_double4x4) -> SIMD4<Double>

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double4x4, rhs: double2x4) -> double2x4

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double4x4, rhs: double3x4) -> double3x4

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func * (lhs: simd_double4x4, rhs: double4x4) -> double4x4

    /// Matrix multiplication (the "usual" matrix product, not the elementwise
    /// product).
    public static func *= (lhs: inout simd_double4x4, rhs: double4x4)
}

extension simd_double4x4 {

    /// Construct a 4x4 matrix from `quaternion`.
    public init(_ quaternion: simd_quatd)
}

/** @abstract A half-precision quaternion.                                  */
public struct simd_quath {

    public init()

    public init(vector: simd_half4)

    public var vector: simd_half4
}

/** @abstract A single-precision quaternion.                                  */
public struct simd_quatf {

    public init()

    public init(vector: simd_float4)

    public var vector: simd_float4
}

extension simd_quatf {

    /// Construct a quaternion from components.
    ///
    /// - Parameters:
    ///   - ix: The x-component of the imaginary (vector) part.
    ///   - iy: The y-component of the imaginary (vector) part.
    ///   - iz: The z-component of the imaginary (vector) part.
    ///   - r: The real (scalar) part.
    public init(ix: Float, iy: Float, iz: Float, r: Float)

    /// Construct a quaternion from real and imaginary parts.
    public init(real: Float, imag: SIMD3<Float>)

    /// A quaternion whose action is a rotation by `angle` radians about `axis`.
    ///
    /// - Parameters:
    ///   - angle: The angle to rotate by measured in radians.
    ///   - axis: The axis to rotate around.
    public init(angle: Float, axis: SIMD3<Float>)

    /// A quaternion whose action rotates the vector `from` onto the vector `to`.
    public init(from: SIMD3<Float>, to: SIMD3<Float>)

    /// Construct a quaternion from `rotationMatrix`.
    public init(_ rotationMatrix: simd_float3x3)

    /// Construct a quaternion from `rotationMatrix`.
    public init(_ rotationMatrix: simd_float4x4)

    /// The real (scalar) part of `self`.
    public var real: Float

    /// The imaginary (vector) part of `self`.
    public var imag: SIMD3<Float>

    /// The angle (in radians) by which `self`'s action rotates.
    public var angle: Float { get }

    /// The normalized axis about which `self`'s action rotates.
    public var axis: SIMD3<Float> { get }

    /// The conjugate of `self`.
    public var conjugate: simd_quatf { get }

    /// The inverse of `self`.
    public var inverse: simd_quatf { get }

    /// The unit quaternion obtained by normalizing `self`.
    public var normalized: simd_quatf { get }

    /// The length of the quaternion interpreted as a 4d vector.
    public var length: Float { get }

    /// Applies the rotation represented by a unit quaternion to the vector and
    /// returns the result.
    public func act(_ vector: SIMD3<Float>) -> SIMD3<Float>
}

extension simd_quatf : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(reflecting:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `debugDescription` property for types that conform to
    /// `CustomDebugStringConvertible`:
    ///
    ///     struct Point: CustomDebugStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var debugDescription: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(reflecting: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `debugDescription` property.
    public var debugDescription: String { get }
}

extension simd_quatf : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: simd_quatf, rhs: simd_quatf) -> Bool
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension simd_quatf : Hashable {

    /// Hashes the essential components of this value by feeding them into the given hasher.
    ///
    /// A quaternion and its negation hash identically.
    /// - Parameter hasher: The hasher to use when combining the components of this instance.
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

extension simd_quatf : @unchecked Sendable {
}

extension simd_quatf {

    /// The sum of `lhs` and `rhs`.
    public static func + (lhs: simd_quatf, rhs: simd_quatf) -> simd_quatf

    /// Add `rhs` to `lhs`.
    public static func += (lhs: inout simd_quatf, rhs: simd_quatf)

    /// The difference of `lhs` and `rhs`.
    public static func - (lhs: simd_quatf, rhs: simd_quatf) -> simd_quatf

    /// Subtract `rhs` from `lhs`.
    public static func -= (lhs: inout simd_quatf, rhs: simd_quatf)

    /// The negation of `rhs`.
    prefix public static func - (rhs: simd_quatf) -> simd_quatf

    /// The product of `lhs` and `rhs`.
    public static func * (lhs: simd_quatf, rhs: simd_quatf) -> simd_quatf

    /// The product of `lhs` and `rhs`.
    public static func * (lhs: Float, rhs: simd_quatf) -> simd_quatf

    /// The product of `lhs` and `rhs`.
    public static func * (lhs: simd_quatf, rhs: Float) -> simd_quatf

    /// Multiply `lhs` by `rhs`.
    public static func *= (lhs: inout simd_quatf, rhs: simd_quatf)

    /// Multiply `lhs` by `rhs`.
    public static func *= (lhs: inout simd_quatf, rhs: Float)

    /// The quotient of `lhs` and `rhs`.
    public static func / (lhs: simd_quatf, rhs: simd_quatf) -> simd_quatf

    /// The quotient of `lhs` and `rhs`.
    public static func / (lhs: simd_quatf, rhs: Float) -> simd_quatf

    /// Divide `lhs` by `rhs`.
    public static func /= (lhs: inout simd_quatf, rhs: simd_quatf)

    /// Divide `lhs` by `rhs`.
    public static func /= (lhs: inout simd_quatf, rhs: Float)
}

/** @abstract A double-precision quaternion.                                  */
public struct simd_quatd {

    public init()

    public init(vector: simd_double4)

    public var vector: simd_double4
}

extension simd_quatd {

    /// Construct a quaternion from components.
    ///
    /// - Parameters:
    ///   - ix: The x-component of the imaginary (vector) part.
    ///   - iy: The y-component of the imaginary (vector) part.
    ///   - iz: The z-component of the imaginary (vector) part.
    ///   - r: The real (scalar) part.
    public init(ix: Double, iy: Double, iz: Double, r: Double)

    /// Construct a quaternion from real and imaginary parts.
    public init(real: Double, imag: SIMD3<Double>)

    /// A quaternion whose action is a rotation by `angle` radians about `axis`.
    ///
    /// - Parameters:
    ///   - angle: The angle to rotate by measured in radians.
    ///   - axis: The axis to rotate around.
    public init(angle: Double, axis: SIMD3<Double>)

    /// A quaternion whose action rotates the vector `from` onto the vector `to`.
    public init(from: SIMD3<Double>, to: SIMD3<Double>)

    /// Construct a quaternion from `rotationMatrix`.
    public init(_ rotationMatrix: simd_double3x3)

    /// Construct a quaternion from `rotationMatrix`.
    public init(_ rotationMatrix: simd_double4x4)

    /// The real (scalar) part of `self`.
    public var real: Double

    /// The imaginary (vector) part of `self`.
    public var imag: SIMD3<Double>

    /// The angle (in radians) by which `self`'s action rotates.
    public var angle: Double { get }

    /// The normalized axis about which `self`'s action rotates.
    public var axis: SIMD3<Double> { get }

    /// The conjugate of `self`.
    public var conjugate: simd_quatd { get }

    /// The inverse of `self`.
    public var inverse: simd_quatd { get }

    /// The unit quaternion obtained by normalizing `self`.
    public var normalized: simd_quatd { get }

    /// The length of the quaternion interpreted as a 4d vector.
    public var length: Double { get }

    /// Applies the rotation represented by a unit quaternion to the vector and
    /// returns the result.
    public func act(_ vector: SIMD3<Double>) -> SIMD3<Double>
}

extension simd_quatd : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(reflecting:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `debugDescription` property for types that conform to
    /// `CustomDebugStringConvertible`:
    ///
    ///     struct Point: CustomDebugStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var debugDescription: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(reflecting: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `debugDescription` property.
    public var debugDescription: String { get }
}

extension simd_quatd : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: simd_quatd, rhs: simd_quatd) -> Bool
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension simd_quatd : Hashable {

    /// Hashes the essential components of this value by feeding them into the given hasher.
    ///
    /// A quaternion and its negation hash identically.
    /// - Parameter hasher: The hasher to use when combining the components of this instance.
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

extension simd_quatd : @unchecked Sendable {
}

extension simd_quatd {

    /// The sum of `lhs` and `rhs`.
    public static func + (lhs: simd_quatd, rhs: simd_quatd) -> simd_quatd

    /// Add `rhs` to `lhs`.
    public static func += (lhs: inout simd_quatd, rhs: simd_quatd)

    /// The difference of `lhs` and `rhs`.
    public static func - (lhs: simd_quatd, rhs: simd_quatd) -> simd_quatd

    /// Subtract `rhs` from `lhs`.
    public static func -= (lhs: inout simd_quatd, rhs: simd_quatd)

    /// The negation of `rhs`.
    prefix public static func - (rhs: simd_quatd) -> simd_quatd

    /// The product of `lhs` and `rhs`.
    public static func * (lhs: simd_quatd, rhs: simd_quatd) -> simd_quatd

    /// The product of `lhs` and `rhs`.
    public static func * (lhs: Double, rhs: simd_quatd) -> simd_quatd

    /// The product of `lhs` and `rhs`.
    public static func * (lhs: simd_quatd, rhs: Double) -> simd_quatd

    /// Multiply `lhs` by `rhs`.
    public static func *= (lhs: inout simd_quatd, rhs: simd_quatd)

    /// Multiply `lhs` by `rhs`.
    public static func *= (lhs: inout simd_quatd, rhs: Double)

    /// The quotient of `lhs` and `rhs`.
    public static func / (lhs: simd_quatd, rhs: simd_quatd) -> simd_quatd

    /// The quotient of `lhs` and `rhs`.
    public static func / (lhs: simd_quatd, rhs: Double) -> simd_quatd

    /// Divide `lhs` by `rhs`.
    public static func /= (lhs: inout simd_quatd, rhs: simd_quatd)

    /// Divide `lhs` by `rhs`.
    public static func /= (lhs: inout simd_quatd, rhs: Double)
}

