/// A type that can function as storage for a SIMD vector type.
///
/// The `SIMDStorage` protocol defines a storage layout and provides
/// elementwise accesses. Computational operations are defined on the `SIMD`
/// protocol, which refines this protocol, and on the concrete types that
/// conform to `SIMD`.
public protocol SIMDStorage {

    associatedtype Scalar : Decodable, Encodable, Hashable

    /// The number of scalars, or elements, in the vector.
    var scalarCount: Int { get }

    /// Creates a vector with zero in all lanes.
    init()

    /// Accesses the element at the specified index.
    ///
    /// - Parameter index: The index of the element to access. `index` must be in
    ///   the range `0..<scalarCount`.
    subscript(index: Int) -> Self.Scalar { get set }
}

extension SIMDStorage {

    /// The number of scalars, or elements, in a vector of this type.
    public static var scalarCount: Int { get }
}

/// A type that can be used as an element in a SIMD vector.
public protocol SIMDScalar : BitwiseCopyable {

    associatedtype SIMDMaskScalar : FixedWidthInteger, SIMDScalar, SignedInteger where Self.SIMDMaskScalar == Self.SIMDMaskScalar.SIMDMaskScalar

    associatedtype SIMD2Storage : SIMDStorage where Self.SIMD2Storage.Scalar == Self.SIMD32Storage.Scalar

    associatedtype SIMD4Storage : SIMDStorage where Self.SIMD4Storage.Scalar == Self.SIMD64Storage.Scalar

    associatedtype SIMD8Storage : SIMDStorage

    associatedtype SIMD16Storage : SIMDStorage where Self == Self.SIMD16Storage.Scalar, Self.SIMD16Storage.Scalar == Self.SIMD2Storage.Scalar

    associatedtype SIMD32Storage : SIMDStorage where Self.SIMD32Storage.Scalar == Self.SIMD4Storage.Scalar

    associatedtype SIMD64Storage : SIMDStorage where Self.SIMD64Storage.Scalar == Self.SIMD8Storage.Scalar
}

/// A SIMD vector of a fixed number of elements.
public protocol SIMD<Scalar> : CustomStringConvertible, Decodable, Encodable, ExpressibleByArrayLiteral, Hashable, SIMDStorage {

    /// The mask type resulting from pointwise comparisons of this vector type.
    associatedtype MaskStorage : SIMD where Self.MaskStorage.Scalar : FixedWidthInteger, Self.MaskStorage.Scalar : SignedInteger
}

extension SIMD {

    /// The valid indices for subscripting the vector.
    public var indices: Range<Int> { get }

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating value: Self.Scalar)

    /// Returns a Boolean value indicating whether two vectors are equal.
    public static func == (a: Self, b: Self) -> Bool

    /// Hashes the elements of the vector using the given hasher.
    @inlinable public func hash(into hasher: inout Hasher)

    /// Encodes the scalars of this vector into the given encoder in an unkeyed
    /// container.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new vector by decoding scalars from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws

    /// A textual description of the vector.
    public var description: String { get }

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: Self, b: Self) -> SIMDMask<Self.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: Self, b: Self) -> SIMDMask<Self.MaskStorage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: Self, where mask: SIMDMask<Self.MaskStorage>)

    /// Creates a vector from the specified elements.
    ///
    /// - Parameter scalars: The elements to use in the vector. `scalars` must
    ///   have the same number of elements as the vector type.
    @inlinable public init(arrayLiteral scalars: Self.Scalar...)

    /// Creates a vector from the given sequence.
    ///
    /// - Precondition: `scalars` must have the same number of elements as the
    ///   vector type.
    ///
    /// - Parameter scalars: The elements to use in the vector.
    @inlinable public init<S>(_ scalars: S) where S : Sequence, Self.Scalar == S.Element

    /// Extracts the scalars at specified indices to form a SIMD2.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD2<Index>) -> SIMD2<Self.Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Self.Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD3.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD3<Index>) -> SIMD3<Self.Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Self.Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD4.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD4<Index>) -> SIMD4<Self.Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Self.Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD8.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD8<Index>) -> SIMD8<Self.Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Self.Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD16.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD16<Index>) -> SIMD16<Self.Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Self.Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD32.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD32<Index>) -> SIMD32<Self.Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Self.Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD64.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD64<Index>) -> SIMD64<Self.Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Self.Scalar : SIMDScalar { get }

    /// Returns a vector mask with the result of a pointwise equality comparison.
    public static func .== (a: Self.Scalar, b: Self) -> SIMDMask<Self.MaskStorage>

    /// Returns a vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: Self.Scalar, b: Self) -> SIMDMask<Self.MaskStorage>

    /// Returns a vector mask with the result of a pointwise equality comparison.
    public static func .== (a: Self, b: Self.Scalar) -> SIMDMask<Self.MaskStorage>

    /// Returns a vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: Self, b: Self.Scalar) -> SIMDMask<Self.MaskStorage>

    /// Replaces elements of this vector with `other` in the lanes where `mask`
    /// is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other }
    /// }
    /// ```
    public mutating func replace(with other: Self.Scalar, where mask: SIMDMask<Self.MaskStorage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: Self, where mask: SIMDMask<Self.MaskStorage>) -> Self

    /// Returns a copy of this vector, with elements `other` in the lanes where
    /// `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other : self[i]
    /// }
    /// ```
    public func replacing(with other: Self.Scalar, where mask: SIMDMask<Self.MaskStorage>) -> Self
}

extension SIMD where Self.Scalar : Comparable {

    /// Returns a vector mask with the result of a pointwise less than
    /// comparison.
    public static func .< (a: Self, b: Self) -> SIMDMask<Self.MaskStorage>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: Self, b: Self) -> SIMDMask<Self.MaskStorage>

    /// The least element in the vector.
    public func min() -> Self.Scalar

    /// The greatest element in the vector.
    public func max() -> Self.Scalar

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: Self, b: Self) -> SIMDMask<Self.MaskStorage>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: Self, b: Self) -> SIMDMask<Self.MaskStorage>

    /// Returns a vector mask with the result of a pointwise less than comparison.
    public static func .< (a: Self.Scalar, b: Self) -> SIMDMask<Self.MaskStorage>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: Self.Scalar, b: Self) -> SIMDMask<Self.MaskStorage>

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: Self.Scalar, b: Self) -> SIMDMask<Self.MaskStorage>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: Self.Scalar, b: Self) -> SIMDMask<Self.MaskStorage>

    /// Returns a vector mask with the result of a pointwise less than comparison.
    public static func .< (a: Self, b: Self.Scalar) -> SIMDMask<Self.MaskStorage>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: Self, b: Self.Scalar) -> SIMDMask<Self.MaskStorage>

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: Self, b: Self.Scalar) -> SIMDMask<Self.MaskStorage>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: Self, b: Self.Scalar) -> SIMDMask<Self.MaskStorage>

    public mutating func clamp(lowerBound: Self, upperBound: Self)

    public func clamped(lowerBound: Self, upperBound: Self) -> Self
}

extension SIMD where Self.Scalar : FixedWidthInteger {

    /// A vector with zero in all lanes.
    public static var zero: Self { get }

    /// A vector with one in all lanes.
    public static var one: Self { get }

    /// Returns a vector with random values from within the specified range in
    /// all lanes, using the given generator as a source for randomness.
    @inlinable public static func random<T>(in range: Range<Self.Scalar>, using generator: inout T) -> Self where T : RandomNumberGenerator

    /// Returns a vector with random values from within the specified range in
    /// all lanes.
    @inlinable public static func random(in range: Range<Self.Scalar>) -> Self

    /// Returns a vector with random values from within the specified range in
    /// all lanes, using the given generator as a source for randomness.
    @inlinable public static func random<T>(in range: ClosedRange<Self.Scalar>, using generator: inout T) -> Self where T : RandomNumberGenerator

    /// Returns a vector with random values from within the specified range in
    /// all lanes.
    @inlinable public static func random(in range: ClosedRange<Self.Scalar>) -> Self

    public var leadingZeroBitCount: Self { get }

    public var trailingZeroBitCount: Self { get }

    public var nonzeroBitCount: Self { get }

    prefix public static func ~ (a: Self) -> Self

    public static func & (a: Self, b: Self) -> Self

    public static func ^ (a: Self, b: Self) -> Self

    public static func | (a: Self, b: Self) -> Self

    public static func &<< (a: Self, b: Self) -> Self

    public static func &>> (a: Self, b: Self) -> Self

    public static func &+ (a: Self, b: Self) -> Self

    public static func &- (a: Self, b: Self) -> Self

    public static func &* (a: Self, b: Self) -> Self

    public static func / (a: Self, b: Self) -> Self

    public static func % (a: Self, b: Self) -> Self

    /// Returns the sum of the scalars in the vector, computed with wrapping
    /// addition.
    ///
    /// Equivalent to `indices.reduce(into: 0) { $0 &+= self[$1] }`.
    public func wrappedSum() -> Self.Scalar

    public static func & (a: Self.Scalar, b: Self) -> Self

    public static func ^ (a: Self.Scalar, b: Self) -> Self

    public static func | (a: Self.Scalar, b: Self) -> Self

    public static func &<< (a: Self.Scalar, b: Self) -> Self

    public static func &>> (a: Self.Scalar, b: Self) -> Self

    public static func &+ (a: Self.Scalar, b: Self) -> Self

    public static func &- (a: Self.Scalar, b: Self) -> Self

    public static func &* (a: Self.Scalar, b: Self) -> Self

    public static func / (a: Self.Scalar, b: Self) -> Self

    public static func % (a: Self.Scalar, b: Self) -> Self

    public static func & (a: Self, b: Self.Scalar) -> Self

    public static func ^ (a: Self, b: Self.Scalar) -> Self

    public static func | (a: Self, b: Self.Scalar) -> Self

    public static func &<< (a: Self, b: Self.Scalar) -> Self

    public static func &>> (a: Self, b: Self.Scalar) -> Self

    public static func &+ (a: Self, b: Self.Scalar) -> Self

    public static func &- (a: Self, b: Self.Scalar) -> Self

    public static func &* (a: Self, b: Self.Scalar) -> Self

    public static func / (a: Self, b: Self.Scalar) -> Self

    public static func % (a: Self, b: Self.Scalar) -> Self

    public static func &= (a: inout Self, b: Self)

    public static func ^= (a: inout Self, b: Self)

    public static func |= (a: inout Self, b: Self)

    public static func &<<= (a: inout Self, b: Self)

    public static func &>>= (a: inout Self, b: Self)

    public static func &+= (a: inout Self, b: Self)

    public static func &-= (a: inout Self, b: Self)

    public static func &*= (a: inout Self, b: Self)

    public static func /= (a: inout Self, b: Self)

    public static func %= (a: inout Self, b: Self)

    public static func &= (a: inout Self, b: Self.Scalar)

    public static func ^= (a: inout Self, b: Self.Scalar)

    public static func |= (a: inout Self, b: Self.Scalar)

    public static func &<<= (a: inout Self, b: Self.Scalar)

    public static func &>>= (a: inout Self, b: Self.Scalar)

    public static func &+= (a: inout Self, b: Self.Scalar)

    public static func &-= (a: inout Self, b: Self.Scalar)

    public static func &*= (a: inout Self, b: Self.Scalar)

    public static func /= (a: inout Self, b: Self.Scalar)

    public static func %= (a: inout Self, b: Self.Scalar)
}

extension SIMD where Self.Scalar : FloatingPoint {

    /// A vector with zero in all lanes.
    public static var zero: Self { get }

    /// A vector with one in all lanes.
    public static var one: Self { get }

    public mutating func clamp(lowerBound: Self, upperBound: Self)

    public func clamped(lowerBound: Self, upperBound: Self) -> Self

    public static func + (a: Self, b: Self) -> Self

    public static func - (a: Self, b: Self) -> Self

    public static func * (a: Self, b: Self) -> Self

    public static func / (a: Self, b: Self) -> Self

    public func addingProduct(_ a: Self, _ b: Self) -> Self

    public func squareRoot() -> Self

    /// A vector formed by rounding each lane of the source vector to an integral
    /// value according to the specified rounding `rule`.
    public func rounded(_ rule: FloatingPointRoundingRule) -> Self

    /// The least scalar in the vector.
    public func min() -> Self.Scalar

    /// The greatest scalar in the vector.
    public func max() -> Self.Scalar

    /// The sum of the scalars in the vector.
    public func sum() -> Self.Scalar

    prefix public static func - (a: Self) -> Self

    public static func + (a: Self.Scalar, b: Self) -> Self

    public static func - (a: Self.Scalar, b: Self) -> Self

    public static func * (a: Self.Scalar, b: Self) -> Self

    public static func / (a: Self.Scalar, b: Self) -> Self

    public static func + (a: Self, b: Self.Scalar) -> Self

    public static func - (a: Self, b: Self.Scalar) -> Self

    public static func * (a: Self, b: Self.Scalar) -> Self

    public static func / (a: Self, b: Self.Scalar) -> Self

    public static func += (a: inout Self, b: Self)

    public static func -= (a: inout Self, b: Self)

    public static func *= (a: inout Self, b: Self)

    public static func /= (a: inout Self, b: Self)

    public static func += (a: inout Self, b: Self.Scalar)

    public static func -= (a: inout Self, b: Self.Scalar)

    public static func *= (a: inout Self, b: Self.Scalar)

    public static func /= (a: inout Self, b: Self.Scalar)

    public func addingProduct(_ a: Self.Scalar, _ b: Self) -> Self

    public func addingProduct(_ a: Self, _ b: Self.Scalar) -> Self

    public mutating func addProduct(_ a: Self, _ b: Self)

    public mutating func addProduct(_ a: Self.Scalar, _ b: Self)

    public mutating func addProduct(_ a: Self, _ b: Self.Scalar)

    public mutating func formSquareRoot()

    public mutating func round(_ rule: FloatingPointRoundingRule)
}

extension SIMD where Self : AdditiveArithmetic, Self.Scalar : FloatingPoint {

    public static func += (a: inout Self, b: Self)

    public static func -= (a: inout Self, b: Self)
}

@frozen public struct SIMDMask<Storage> : SIMD where Storage : SIMD, Storage.Scalar : FixedWidthInteger, Storage.Scalar : SignedInteger {

    /// The mask type resulting from pointwise comparisons of this vector type.
    public typealias MaskStorage = Storage

    public typealias Scalar = Bool

    /// Creates a vector with zero in all lanes.
    public init()

    /// The number of scalars, or elements, in the vector.
    public var scalarCount: Int { get }

    /// Accesses the element at the specified index.
    ///
    /// - Parameter index: The index of the element to access. `index` must be in
    ///   the range `0..<scalarCount`.
    public subscript(index: Int) -> Bool

    /// The type of the elements of an array literal.
    public typealias ArrayLiteralElement = SIMDMask<Storage>.Scalar

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    ///   The compiler provides an implementation for `hashValue` for you.
    public var hashValue: Int { get }

    /// Returns a vector mask with `true` or `false` randomly assigned in each
    /// lane, using the given generator as a source for randomness.
    @inlinable public static func random<T>(using generator: inout T) -> SIMDMask<Storage> where T : RandomNumberGenerator

    /// Returns a vector mask with `true` or `false` randomly assigned in each
    /// lane.
    @inlinable public static func random() -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<${Vector}>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<${Vector}>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<${Vector}>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<${Vector}>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to `a ? b : SIMDMask(repeating: false)`.
    public static func .& (a: Bool, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to `a ? .!b : b`.
    public static func .^ (a: Bool, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to `a ? SIMDMask(repeating: true) : b`.
    public static func .| (a: Bool, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to `b ? a : SIMDMask(repeating: false)`.
    public static func .& (a: SIMDMask<Storage>, b: Bool) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to `b ? .!a : a`.
    public static func .^ (a: SIMDMask<Storage>, b: Bool) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to `b ? SIMDMask(repeating: true) : a`
    public static func .| (a: SIMDMask<Storage>, b: Bool) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// if !b { a = SIMDMask(repeating: false) }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: Bool)

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// if b { a = .!a }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: Bool)

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// if b { a = SIMDMask(repeating: true) }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: Bool)

    /// Returns a Boolean value indicating whether two values are not equal.
    ///
    /// Inequality is the inverse of equality. For any values `a` and `b`, `a != b`
    /// implies that `a == b` is `false`.
    ///
    /// This is the default implementation of the not-equal-to operator (`!=`)
    /// for any type that conforms to `Equatable`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func != (lhs: SIMDMask<Storage>, rhs: SIMDMask<Storage>) -> Bool

    /// The number of scalars, or elements, in a vector of this type.
    public static var scalarCount: Int { get }

    /// The valid indices for subscripting the vector.
    public var indices: Range<Int> { get }

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating value: Bool)

    /// Returns a Boolean value indicating whether two vectors are equal.
    public static func == (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> Bool

    /// Hashes the elements of the vector using the given hasher.
    @inlinable public func hash(into hasher: inout Hasher)

    /// Encodes the scalars of this vector into the given encoder in an unkeyed
    /// container.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new vector by decoding scalars from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws

    /// A textual description of the vector.
    public var description: String { get }

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Creates a vector from the specified elements.
    ///
    /// - Parameter scalars: The elements to use in the vector. `scalars` must
    ///   have the same number of elements as the vector type.
    @inlinable public init(arrayLiteral scalars: Bool...)

    /// Creates a vector from the given sequence.
    ///
    /// - Precondition: `scalars` must have the same number of elements as the
    ///   vector type.
    ///
    /// - Parameter scalars: The elements to use in the vector.
    @inlinable public init<S>(_ scalars: S) where S : Sequence, Bool == S.Element

    /// Extracts the scalars at specified indices to form a SIMD2.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD2<Index>) -> SIMD2<Bool> where Index : FixedWidthInteger, Index : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD3.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD3<Index>) -> SIMD3<Bool> where Index : FixedWidthInteger, Index : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD4.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD4<Index>) -> SIMD4<Bool> where Index : FixedWidthInteger, Index : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD8.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD8<Index>) -> SIMD8<Bool> where Index : FixedWidthInteger, Index : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD16.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD16<Index>) -> SIMD16<Bool> where Index : FixedWidthInteger, Index : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD32.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD32<Index>) -> SIMD32<Bool> where Index : FixedWidthInteger, Index : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD64.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD64<Index>) -> SIMD64<Bool> where Index : FixedWidthInteger, Index : SIMDScalar { get }

    /// Returns a vector mask with the result of a pointwise equality comparison.
    public static func .== (a: Bool, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Returns a vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: Bool, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Returns a vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMDMask<Storage>, b: Bool) -> SIMDMask<Storage>

    /// Returns a vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMDMask<Storage>, b: Bool) -> SIMDMask<Storage>

    /// Replaces elements of this vector with `other` in the lanes where `mask`
    /// is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other }
    /// }
    /// ```
    public mutating func replace(with other: Bool, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Returns a copy of this vector, with elements `other` in the lanes where
    /// `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other : self[i]
    /// }
    /// ```
    public func replacing(with other: Bool, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD8<Int32> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int32>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD64<Int> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD4<Int8> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int8>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD8<Int8> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int8>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD16<Int8> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int8>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD32<Int8> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int8>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD64<Int8> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int8>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD3<Int8> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int8>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD2<Int16> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int16>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD4<Int16> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int16>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD8<Int16> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int16>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD16<Int16> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int16>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD32<Int16> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int16>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD64<Int16> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int16>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD3<Int16> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int16>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int16>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD2<Int32> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int32>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD4<Int32> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int32>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD3<Int> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD16<Int32> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int32>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD32<Int32> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int32>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD64<Int32> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int32>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD3<Int32> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int32>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int32>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD2<Int64> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int64>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD4<Int64> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int64>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD8<Int64> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int64>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD16<Int64> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int64>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD32<Int64> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int64>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD64<Int64> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int64>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD64<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD3<Int64> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int64>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD3<Int64>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD2<Int> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD4<Int> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD4<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD8<Int> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD8<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD16<Int> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD16<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD32<Int> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD32<Int>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

extension SIMDMask where Storage == SIMD2<Int8> {

    public init(repeating scalar: Bool)

    /// A vector mask that is the pointwise logical negation of the input.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int8>>()
    /// for i in result.indices {
    ///   result[i] = !a[i]
    /// }
    /// ```
    prefix public static func .! (a: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask that is the pointwise logical conjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] && b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `&&` operator, the SIMD `.&` operator
    /// always fully evaluates both arguments.
    public static func .& (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical conjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] && b[i]
    /// }
    /// ```
    public static func .&= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise exclusive or of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^ (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise exclusive or of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .^= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask that is the pointwise logical disjunction of the inputs.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] || b[i]
    /// }
    /// ```
    ///
    /// Note that unlike the scalar `||` operator, the SIMD `.|` operator
    /// always fully evaluates both arguments.
    public static func .| (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces `a` with the pointwise logical disjunction of `a` and `b`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in a.indices {
    ///   a[i] = a[i] || b[i]
    /// }
    /// ```
    public static func .|= (a: inout SIMDMask<Storage>, b: SIMDMask<Storage>)

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<SIMD2<Int8>>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMDMask<Storage>, b: SIMDMask<Storage>) -> SIMDMask<Storage>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMDMask<Storage>, where mask: SIMDMask<Storage>) -> SIMDMask<Storage>
}

/// True if any lane of mask is true.
public func any<Storage>(_ mask: SIMDMask<Storage>) -> Bool where Storage : SIMD, Storage.Scalar : FixedWidthInteger, Storage.Scalar : SignedInteger

/// True if every lane of mask is true.
public func all<Storage>(_ mask: SIMDMask<Storage>) -> Bool where Storage : SIMD, Storage.Scalar : FixedWidthInteger, Storage.Scalar : SignedInteger

/// The lanewise minimum of two vectors.
///
/// Each element of the result is the minimum of the corresponding elements
/// of the inputs.
public func pointwiseMin<T>(_ a: T, _ b: T) -> T where T : SIMD, T.Scalar : Comparable

/// The lanewise maximum of two vectors.
///
/// Each element of the result is the minimum of the corresponding elements
/// of the inputs.
public func pointwiseMax<T>(_ a: T, _ b: T) -> T where T : SIMD, T.Scalar : Comparable

/// The lanewise minimum of two vectors.
///
/// Each element of the result is the minimum of the corresponding elements
/// of the inputs.
public func pointwiseMin<T>(_ a: T, _ b: T) -> T where T : SIMD, T.Scalar : FloatingPoint

/// The lanewise maximum of two vectors.
///
/// Each element of the result is the maximum of the corresponding elements
/// of the inputs.
public func pointwiseMax<T>(_ a: T, _ b: T) -> T where T : SIMD, T.Scalar : FloatingPoint

/// A vector of two scalar values.
@frozen public struct SIMD2<Scalar> : SIMD where Scalar : SIMDScalar {

    /// The mask type resulting from pointwise comparisons of this vector type.
    public typealias MaskStorage = SIMD2<Scalar.SIMDMaskScalar>

    /// The number of scalars in the vector.
    public var scalarCount: Int { get }

    /// Creates a vector with zero in all lanes.
    public init()

    /// Accesses the scalar at the specified position.
    public subscript(index: Int) -> Scalar

    /// Creates a new vector from the given elements.
    public init(_ v0: Scalar, _ v1: Scalar)

    /// Creates a new vector from the given elements.
    ///
    /// - Parameters:
    ///   - x: The first element of the vector.
    ///   - y: The second element of the vector.
    public init(x: Scalar, y: Scalar)

    /// The first element of the vector.
    public var x: Scalar

    /// The second element of the vector.
    public var y: Scalar

    /// The type of the elements of an array literal.
    public typealias ArrayLiteralElement = Scalar

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    ///   The compiler provides an implementation for `hashValue` for you.
    public var hashValue: Int { get }

    /// Returns a Boolean value indicating whether two values are not equal.
    ///
    /// Inequality is the inverse of equality. For any values `a` and `b`, `a != b`
    /// implies that `a == b` is `false`.
    ///
    /// This is the default implementation of the not-equal-to operator (`!=`)
    /// for any type that conforms to `Equatable`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func != (lhs: SIMD2<Scalar>, rhs: SIMD2<Scalar>) -> Bool

    /// The number of scalars, or elements, in a vector of this type.
    public static var scalarCount: Int { get }

    /// The valid indices for subscripting the vector.
    public var indices: Range<Int> { get }

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating value: Scalar)

    /// Returns a Boolean value indicating whether two vectors are equal.
    public static func == (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> Bool

    /// Hashes the elements of the vector using the given hasher.
    @inlinable public func hash(into hasher: inout Hasher)

    /// Encodes the scalars of this vector into the given encoder in an unkeyed
    /// container.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new vector by decoding scalars from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws

    /// A textual description of the vector.
    public var description: String { get }

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar.SIMDMaskScalar>>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar.SIMDMaskScalar>>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMD2<Scalar>, where mask: SIMDMask<SIMD2<Scalar.SIMDMaskScalar>>)

    /// Creates a vector from the specified elements.
    ///
    /// - Parameter scalars: The elements to use in the vector. `scalars` must
    ///   have the same number of elements as the vector type.
    @inlinable public init(arrayLiteral scalars: Scalar...)

    /// Creates a vector from the given sequence.
    ///
    /// - Precondition: `scalars` must have the same number of elements as the
    ///   vector type.
    ///
    /// - Parameter scalars: The elements to use in the vector.
    @inlinable public init<S>(_ scalars: S) where S : Sequence, Scalar == S.Element

    /// Extracts the scalars at specified indices to form a SIMD2.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD2<Index>) -> SIMD2<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD3.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD3<Index>) -> SIMD3<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD4.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD4<Index>) -> SIMD4<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD8.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD8<Index>) -> SIMD8<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD16.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD16<Index>) -> SIMD16<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD32.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD32<Index>) -> SIMD32<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD64.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD64<Index>) -> SIMD64<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Returns a vector mask with the result of a pointwise equality comparison.
    public static func .== (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar.SIMDMaskScalar>>

    /// Replaces elements of this vector with `other` in the lanes where `mask`
    /// is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other }
    /// }
    /// ```
    public mutating func replace(with other: Scalar, where mask: SIMDMask<SIMD2<Scalar.SIMDMaskScalar>>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMD2<Scalar>, where mask: SIMDMask<SIMD2<Scalar.SIMDMaskScalar>>) -> SIMD2<Scalar>

    /// Returns a copy of this vector, with elements `other` in the lanes where
    /// `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other : self[i]
    /// }
    /// ```
    public func replacing(with other: Scalar, where mask: SIMDMask<SIMD2<Scalar.SIMDMaskScalar>>) -> SIMD2<Scalar>
}

extension SIMD2 : CustomDebugStringConvertible {

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

extension SIMD2 where Scalar : Comparable {

    /// Returns a vector mask with the result of a pointwise less than
    /// comparison.
    public static func .< (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar.SIMDMaskScalar>>

    /// The least element in the vector.
    public func min() -> Scalar

    /// The greatest element in the vector.
    public func max() -> Scalar

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than comparison.
    public static func .< (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than comparison.
    public static func .< (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar.SIMDMaskScalar>>

    public mutating func clamp(lowerBound: SIMD2<Scalar>, upperBound: SIMD2<Scalar>)

    public func clamped(lowerBound: SIMD2<Scalar>, upperBound: SIMD2<Scalar>) -> SIMD2<Scalar>
}

extension SIMD2 where Scalar : FixedWidthInteger {

    /// Creates a new vector from the given vector, truncating the bit patterns
    /// of the given vector's elements if necessary.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(truncatingIfNeeded other: SIMD2<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    /// Creates a new vector from the given vector, clamping the values of the
    /// given vector's elements if necessary.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(clamping other: SIMD2<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    /// Creates a new vector from the given vector, rounding the given vector's
    /// of elements using the specified rounding rule.
    ///
    /// - Parameters:
    ///   - other: The vector to convert.
    ///   - rule: The round rule to use when converting elements of `other.` The
    ///     default is `.towardZero`.
    @inlinable public init<Other>(_ other: SIMD2<Other>, rounding rule: FloatingPointRoundingRule = .towardZero) where Other : BinaryFloatingPoint, Other : SIMDScalar

    /// A vector with zero in all lanes.
    public static var zero: SIMD2<Scalar> { get }

    /// A vector with one in all lanes.
    public static var one: SIMD2<Scalar> { get }

    /// Returns a vector with random values from within the specified range in
    /// all lanes, using the given generator as a source for randomness.
    @inlinable public static func random<T>(in range: Range<Scalar>, using generator: inout T) -> SIMD2<Scalar> where T : RandomNumberGenerator

    /// Returns a vector with random values from within the specified range in
    /// all lanes.
    @inlinable public static func random(in range: Range<Scalar>) -> SIMD2<Scalar>

    /// Returns a vector with random values from within the specified range in
    /// all lanes, using the given generator as a source for randomness.
    @inlinable public static func random<T>(in range: ClosedRange<Scalar>, using generator: inout T) -> SIMD2<Scalar> where T : RandomNumberGenerator

    /// Returns a vector with random values from within the specified range in
    /// all lanes.
    @inlinable public static func random(in range: ClosedRange<Scalar>) -> SIMD2<Scalar>

    public var leadingZeroBitCount: SIMD2<Scalar> { get }

    public var trailingZeroBitCount: SIMD2<Scalar> { get }

    public var nonzeroBitCount: SIMD2<Scalar> { get }

    prefix public static func ~ (a: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func & (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func ^ (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func | (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func &<< (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func &>> (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func &+ (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func &- (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func &* (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func / (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func % (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// Returns the sum of the scalars in the vector, computed with wrapping
    /// addition.
    ///
    /// Equivalent to `indices.reduce(into: 0) { $0 &+= self[$1] }`.
    public func wrappedSum() -> Scalar

    public static func & (a: Scalar, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func ^ (a: Scalar, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func | (a: Scalar, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func &<< (a: Scalar, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func &>> (a: Scalar, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func &+ (a: Scalar, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func &- (a: Scalar, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func &* (a: Scalar, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func / (a: Scalar, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func % (a: Scalar, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func & (a: SIMD2<Scalar>, b: Scalar) -> SIMD2<Scalar>

    public static func ^ (a: SIMD2<Scalar>, b: Scalar) -> SIMD2<Scalar>

    public static func | (a: SIMD2<Scalar>, b: Scalar) -> SIMD2<Scalar>

    public static func &<< (a: SIMD2<Scalar>, b: Scalar) -> SIMD2<Scalar>

    public static func &>> (a: SIMD2<Scalar>, b: Scalar) -> SIMD2<Scalar>

    public static func &+ (a: SIMD2<Scalar>, b: Scalar) -> SIMD2<Scalar>

    public static func &- (a: SIMD2<Scalar>, b: Scalar) -> SIMD2<Scalar>

    public static func &* (a: SIMD2<Scalar>, b: Scalar) -> SIMD2<Scalar>

    public static func / (a: SIMD2<Scalar>, b: Scalar) -> SIMD2<Scalar>

    public static func % (a: SIMD2<Scalar>, b: Scalar) -> SIMD2<Scalar>

    public static func &= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    public static func ^= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    public static func |= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    public static func &<<= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    public static func &>>= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    public static func &+= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    public static func &-= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    public static func &*= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    public static func /= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    public static func %= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    public static func &= (a: inout SIMD2<Scalar>, b: Scalar)

    public static func ^= (a: inout SIMD2<Scalar>, b: Scalar)

    public static func |= (a: inout SIMD2<Scalar>, b: Scalar)

    public static func &<<= (a: inout SIMD2<Scalar>, b: Scalar)

    public static func &>>= (a: inout SIMD2<Scalar>, b: Scalar)

    public static func &+= (a: inout SIMD2<Scalar>, b: Scalar)

    public static func &-= (a: inout SIMD2<Scalar>, b: Scalar)

    public static func &*= (a: inout SIMD2<Scalar>, b: Scalar)

    public static func /= (a: inout SIMD2<Scalar>, b: Scalar)

    public static func %= (a: inout SIMD2<Scalar>, b: Scalar)
}

extension SIMD2 where Scalar : FloatingPoint {

    /// A vector with zero in all lanes.
    public static var zero: SIMD2<Scalar> { get }

    /// A vector with one in all lanes.
    public static var one: SIMD2<Scalar> { get }

    public mutating func clamp(lowerBound: SIMD2<Scalar>, upperBound: SIMD2<Scalar>)

    public func clamped(lowerBound: SIMD2<Scalar>, upperBound: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func + (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func - (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func * (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func / (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public func addingProduct(_ a: SIMD2<Scalar>, _ b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public func squareRoot() -> SIMD2<Scalar>

    /// A vector formed by rounding each lane of the source vector to an integral
    /// value according to the specified rounding `rule`.
    public func rounded(_ rule: FloatingPointRoundingRule) -> SIMD2<Scalar>

    /// The least scalar in the vector.
    public func min() -> Scalar

    /// The greatest scalar in the vector.
    public func max() -> Scalar

    /// The sum of the scalars in the vector.
    public func sum() -> Scalar

    prefix public static func - (a: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func + (a: Scalar, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func - (a: Scalar, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func * (a: Scalar, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func / (a: Scalar, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public static func + (a: SIMD2<Scalar>, b: Scalar) -> SIMD2<Scalar>

    public static func - (a: SIMD2<Scalar>, b: Scalar) -> SIMD2<Scalar>

    public static func * (a: SIMD2<Scalar>, b: Scalar) -> SIMD2<Scalar>

    public static func / (a: SIMD2<Scalar>, b: Scalar) -> SIMD2<Scalar>

    public static func += (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    public static func -= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    public static func *= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    public static func /= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    public static func += (a: inout SIMD2<Scalar>, b: Scalar)

    public static func -= (a: inout SIMD2<Scalar>, b: Scalar)

    public static func *= (a: inout SIMD2<Scalar>, b: Scalar)

    public static func /= (a: inout SIMD2<Scalar>, b: Scalar)

    public func addingProduct(_ a: Scalar, _ b: SIMD2<Scalar>) -> SIMD2<Scalar>

    public func addingProduct(_ a: SIMD2<Scalar>, _ b: Scalar) -> SIMD2<Scalar>

    public mutating func addProduct(_ a: SIMD2<Scalar>, _ b: SIMD2<Scalar>)

    public mutating func addProduct(_ a: Scalar, _ b: SIMD2<Scalar>)

    public mutating func addProduct(_ a: SIMD2<Scalar>, _ b: Scalar)

    public mutating func formSquareRoot()

    public mutating func round(_ rule: FloatingPointRoundingRule)
}

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension SIMD2 where Scalar == Float16 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD2<Float16>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Float16)

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] == b[i])
    /// }
    /// ```
    public static func .== (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] == b)
    /// }
    /// ```
    public static func .== (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if a is equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a == b[i])
    /// }
    /// ```
    public static func .== (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] != b[i])
    /// }
    /// ```
    public static func .!= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] != b)
    /// }
    /// ```
    public static func .!= (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if a is not equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a != b[i])
    /// }
    /// ```
    public static func .!= (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] < b[i])
    /// }
    /// ```
    public static func .< (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] < b)
    /// }
    /// ```
    public static func .< (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if a is less than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a < b[i])
    /// }
    /// ```
    public static func .< (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] <= b[i])
    /// }
    /// ```
    public static func .<= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] <= b)
    /// }
    /// ```
    public static func .<= (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if a is less than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a <= b[i])
    /// }
    /// ```
    public static func .<= (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] >= b[i])
    /// }
    /// ```
    public static func .>= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] >= b)
    /// }
    /// ```
    public static func .>= (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if a is greater than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a >= b[i])
    /// }
    /// ```
    public static func .>= (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] > b[i])
    /// }
    /// ```
    public static func .> (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] > b)
    /// }
    /// ```
    public static func .> (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if a is greater than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a > b[i])
    /// }
    /// ```
    public static func .> (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>
}

extension SIMD2 where Scalar == Float {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD2<Float>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Float)

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] == b[i])
    /// }
    /// ```
    public static func .== (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] == b)
    /// }
    /// ```
    public static func .== (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if a is equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a == b[i])
    /// }
    /// ```
    public static func .== (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] != b[i])
    /// }
    /// ```
    public static func .!= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] != b)
    /// }
    /// ```
    public static func .!= (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if a is not equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a != b[i])
    /// }
    /// ```
    public static func .!= (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] < b[i])
    /// }
    /// ```
    public static func .< (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] < b)
    /// }
    /// ```
    public static func .< (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if a is less than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a < b[i])
    /// }
    /// ```
    public static func .< (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] <= b[i])
    /// }
    /// ```
    public static func .<= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] <= b)
    /// }
    /// ```
    public static func .<= (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if a is less than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a <= b[i])
    /// }
    /// ```
    public static func .<= (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] >= b[i])
    /// }
    /// ```
    public static func .>= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] >= b)
    /// }
    /// ```
    public static func .>= (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if a is greater than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a >= b[i])
    /// }
    /// ```
    public static func .>= (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] > b[i])
    /// }
    /// ```
    public static func .> (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] > b)
    /// }
    /// ```
    public static func .> (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if a is greater than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a > b[i])
    /// }
    /// ```
    public static func .> (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>
}

extension SIMD2 where Scalar == Double {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD2<Double>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Double)

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] == b[i])
    /// }
    /// ```
    public static func .== (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] == b)
    /// }
    /// ```
    public static func .== (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if a is equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a == b[i])
    /// }
    /// ```
    public static func .== (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] != b[i])
    /// }
    /// ```
    public static func .!= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] != b)
    /// }
    /// ```
    public static func .!= (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if a is not equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a != b[i])
    /// }
    /// ```
    public static func .!= (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] < b[i])
    /// }
    /// ```
    public static func .< (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] < b)
    /// }
    /// ```
    public static func .< (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if a is less than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a < b[i])
    /// }
    /// ```
    public static func .< (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] <= b[i])
    /// }
    /// ```
    public static func .<= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] <= b)
    /// }
    /// ```
    public static func .<= (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if a is less than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a <= b[i])
    /// }
    /// ```
    public static func .<= (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] >= b[i])
    /// }
    /// ```
    public static func .>= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] >= b)
    /// }
    /// ```
    public static func .>= (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if a is greater than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a >= b[i])
    /// }
    /// ```
    public static func .>= (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] > b[i])
    /// }
    /// ```
    public static func .> (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a[i] > b)
    /// }
    /// ```
    public static func .> (a: SIMD2<Scalar>, b: Scalar) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if a is greater than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<2 {
    ///   result[i] = (a > b[i])
    /// }
    /// ```
    public static func .> (a: Scalar, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>
}

extension SIMD2 where Scalar == UInt8 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD2<UInt8>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt8)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)
}

extension SIMD2 where Scalar == Int8 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD2<Int8>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int8)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)
}

extension SIMD2 where Scalar == UInt16 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD2<UInt16>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt16)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)
}

extension SIMD2 where Scalar == Int16 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD2<Int16>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int16)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)
}

extension SIMD2 where Scalar == UInt32 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD2<UInt32>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt32)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)
}

extension SIMD2 where Scalar == Int32 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD2<Int32>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int32)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)
}

extension SIMD2 where Scalar == UInt64 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD2<UInt64>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt64)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)
}

extension SIMD2 where Scalar == Int64 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD2<Int64>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int64)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)
}

extension SIMD2 where Scalar == UInt {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD2<UInt>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)
}

extension SIMD2 where Scalar == Int {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD2<Int>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMDMask<SIMD2<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD2<Scalar>, b: SIMD2<Scalar>) -> SIMD2<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD2<Scalar>, b: SIMD2<Scalar>)
}

extension SIMD2 where Scalar : BinaryFloatingPoint {

    /// Creates a new vector from the given vector of integers.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(_ other: SIMD2<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    /// Creates a new vector from the given vector of floating-point values.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(_ other: SIMD2<Other>) where Other : BinaryFloatingPoint, Other : SIMDScalar
}

/// A vector of four scalar values.
@frozen public struct SIMD4<Scalar> : SIMD where Scalar : SIMDScalar {

    /// The mask type resulting from pointwise comparisons of this vector type.
    public typealias MaskStorage = SIMD4<Scalar.SIMDMaskScalar>

    /// The number of scalars in the vector.
    public var scalarCount: Int { get }

    /// Creates a vector with zero in all lanes.
    public init()

    /// Accesses the scalar at the specified position.
    public subscript(index: Int) -> Scalar

    /// Creates a new vector from the given elements.
    public init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar)

    /// Creates a new vector from the given elements.
    ///
    /// - Parameters:
    ///   - x: The first element of the vector.
    ///   - y: The second element of the vector.
    ///   - z: The third element of the vector.
    ///   - w: The fourth element of the vector.
    public init(x: Scalar, y: Scalar, z: Scalar, w: Scalar)

    /// The first element of the vector.
    public var x: Scalar

    /// The second element of the vector.
    public var y: Scalar

    /// The third element of the vector.
    public var z: Scalar

    /// The fourth element of the vector.
    public var w: Scalar

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<Scalar>()
    /// for i in 0..<2 {
    ///   result[i] = lowHalf[i]
    ///   result[2+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD2<Scalar>, highHalf: SIMD2<Scalar>)

    /// A half-length vector made up of the low elements of the vector.
    public var lowHalf: SIMD2<Scalar>

    /// A half-length vector made up of the high elements of the vector.
    public var highHalf: SIMD2<Scalar>

    /// A half-length vector made up of the even elements of the vector.
    public var evenHalf: SIMD2<Scalar>

    /// A half-length vector made up of the odd elements of the vector.
    public var oddHalf: SIMD2<Scalar>

    /// The type of the elements of an array literal.
    public typealias ArrayLiteralElement = Scalar

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    ///   The compiler provides an implementation for `hashValue` for you.
    public var hashValue: Int { get }

    /// A four-element vector created by appending a scalar to a three-element vector.
    public init(_ xyz: SIMD3<Scalar>, _ w: Scalar)

    /// Returns a Boolean value indicating whether two values are not equal.
    ///
    /// Inequality is the inverse of equality. For any values `a` and `b`, `a != b`
    /// implies that `a == b` is `false`.
    ///
    /// This is the default implementation of the not-equal-to operator (`!=`)
    /// for any type that conforms to `Equatable`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func != (lhs: SIMD4<Scalar>, rhs: SIMD4<Scalar>) -> Bool

    /// The number of scalars, or elements, in a vector of this type.
    public static var scalarCount: Int { get }

    /// The valid indices for subscripting the vector.
    public var indices: Range<Int> { get }

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating value: Scalar)

    /// Returns a Boolean value indicating whether two vectors are equal.
    public static func == (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> Bool

    /// Hashes the elements of the vector using the given hasher.
    @inlinable public func hash(into hasher: inout Hasher)

    /// Encodes the scalars of this vector into the given encoder in an unkeyed
    /// container.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new vector by decoding scalars from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws

    /// A textual description of the vector.
    public var description: String { get }

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar.SIMDMaskScalar>>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar.SIMDMaskScalar>>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMD4<Scalar>, where mask: SIMDMask<SIMD4<Scalar.SIMDMaskScalar>>)

    /// Creates a vector from the specified elements.
    ///
    /// - Parameter scalars: The elements to use in the vector. `scalars` must
    ///   have the same number of elements as the vector type.
    @inlinable public init(arrayLiteral scalars: Scalar...)

    /// Creates a vector from the given sequence.
    ///
    /// - Precondition: `scalars` must have the same number of elements as the
    ///   vector type.
    ///
    /// - Parameter scalars: The elements to use in the vector.
    @inlinable public init<S>(_ scalars: S) where S : Sequence, Scalar == S.Element

    /// Extracts the scalars at specified indices to form a SIMD2.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD2<Index>) -> SIMD2<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD3.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD3<Index>) -> SIMD3<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD4.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD4<Index>) -> SIMD4<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD8.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD8<Index>) -> SIMD8<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD16.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD16<Index>) -> SIMD16<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD32.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD32<Index>) -> SIMD32<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD64.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD64<Index>) -> SIMD64<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Returns a vector mask with the result of a pointwise equality comparison.
    public static func .== (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar.SIMDMaskScalar>>

    /// Replaces elements of this vector with `other` in the lanes where `mask`
    /// is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other }
    /// }
    /// ```
    public mutating func replace(with other: Scalar, where mask: SIMDMask<SIMD4<Scalar.SIMDMaskScalar>>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMD4<Scalar>, where mask: SIMDMask<SIMD4<Scalar.SIMDMaskScalar>>) -> SIMD4<Scalar>

    /// Returns a copy of this vector, with elements `other` in the lanes where
    /// `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other : self[i]
    /// }
    /// ```
    public func replacing(with other: Scalar, where mask: SIMDMask<SIMD4<Scalar.SIMDMaskScalar>>) -> SIMD4<Scalar>
}

extension SIMD4 : CustomDebugStringConvertible {

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

extension SIMD4 where Scalar : Comparable {

    /// Returns a vector mask with the result of a pointwise less than
    /// comparison.
    public static func .< (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar.SIMDMaskScalar>>

    /// The least element in the vector.
    public func min() -> Scalar

    /// The greatest element in the vector.
    public func max() -> Scalar

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than comparison.
    public static func .< (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than comparison.
    public static func .< (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar.SIMDMaskScalar>>

    public mutating func clamp(lowerBound: SIMD4<Scalar>, upperBound: SIMD4<Scalar>)

    public func clamped(lowerBound: SIMD4<Scalar>, upperBound: SIMD4<Scalar>) -> SIMD4<Scalar>
}

extension SIMD4 where Scalar : FixedWidthInteger {

    /// Creates a new vector from the given vector, truncating the bit patterns
    /// of the given vector's elements if necessary.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(truncatingIfNeeded other: SIMD4<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    /// Creates a new vector from the given vector, clamping the values of the
    /// given vector's elements if necessary.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(clamping other: SIMD4<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    /// Creates a new vector from the given vector, rounding the given vector's
    /// of elements using the specified rounding rule.
    ///
    /// - Parameters:
    ///   - other: The vector to convert.
    ///   - rule: The round rule to use when converting elements of `other.` The
    ///     default is `.towardZero`.
    @inlinable public init<Other>(_ other: SIMD4<Other>, rounding rule: FloatingPointRoundingRule = .towardZero) where Other : BinaryFloatingPoint, Other : SIMDScalar

    /// A vector with zero in all lanes.
    public static var zero: SIMD4<Scalar> { get }

    /// A vector with one in all lanes.
    public static var one: SIMD4<Scalar> { get }

    /// Returns a vector with random values from within the specified range in
    /// all lanes, using the given generator as a source for randomness.
    @inlinable public static func random<T>(in range: Range<Scalar>, using generator: inout T) -> SIMD4<Scalar> where T : RandomNumberGenerator

    /// Returns a vector with random values from within the specified range in
    /// all lanes.
    @inlinable public static func random(in range: Range<Scalar>) -> SIMD4<Scalar>

    /// Returns a vector with random values from within the specified range in
    /// all lanes, using the given generator as a source for randomness.
    @inlinable public static func random<T>(in range: ClosedRange<Scalar>, using generator: inout T) -> SIMD4<Scalar> where T : RandomNumberGenerator

    /// Returns a vector with random values from within the specified range in
    /// all lanes.
    @inlinable public static func random(in range: ClosedRange<Scalar>) -> SIMD4<Scalar>

    public var leadingZeroBitCount: SIMD4<Scalar> { get }

    public var trailingZeroBitCount: SIMD4<Scalar> { get }

    public var nonzeroBitCount: SIMD4<Scalar> { get }

    prefix public static func ~ (a: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func & (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func ^ (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func | (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func &<< (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func &>> (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func &+ (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func &- (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func &* (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func / (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func % (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// Returns the sum of the scalars in the vector, computed with wrapping
    /// addition.
    ///
    /// Equivalent to `indices.reduce(into: 0) { $0 &+= self[$1] }`.
    public func wrappedSum() -> Scalar

    public static func & (a: Scalar, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func ^ (a: Scalar, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func | (a: Scalar, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func &<< (a: Scalar, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func &>> (a: Scalar, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func &+ (a: Scalar, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func &- (a: Scalar, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func &* (a: Scalar, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func / (a: Scalar, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func % (a: Scalar, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func & (a: SIMD4<Scalar>, b: Scalar) -> SIMD4<Scalar>

    public static func ^ (a: SIMD4<Scalar>, b: Scalar) -> SIMD4<Scalar>

    public static func | (a: SIMD4<Scalar>, b: Scalar) -> SIMD4<Scalar>

    public static func &<< (a: SIMD4<Scalar>, b: Scalar) -> SIMD4<Scalar>

    public static func &>> (a: SIMD4<Scalar>, b: Scalar) -> SIMD4<Scalar>

    public static func &+ (a: SIMD4<Scalar>, b: Scalar) -> SIMD4<Scalar>

    public static func &- (a: SIMD4<Scalar>, b: Scalar) -> SIMD4<Scalar>

    public static func &* (a: SIMD4<Scalar>, b: Scalar) -> SIMD4<Scalar>

    public static func / (a: SIMD4<Scalar>, b: Scalar) -> SIMD4<Scalar>

    public static func % (a: SIMD4<Scalar>, b: Scalar) -> SIMD4<Scalar>

    public static func &= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    public static func ^= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    public static func |= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    public static func &<<= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    public static func &>>= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    public static func &+= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    public static func &-= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    public static func &*= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    public static func /= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    public static func %= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    public static func &= (a: inout SIMD4<Scalar>, b: Scalar)

    public static func ^= (a: inout SIMD4<Scalar>, b: Scalar)

    public static func |= (a: inout SIMD4<Scalar>, b: Scalar)

    public static func &<<= (a: inout SIMD4<Scalar>, b: Scalar)

    public static func &>>= (a: inout SIMD4<Scalar>, b: Scalar)

    public static func &+= (a: inout SIMD4<Scalar>, b: Scalar)

    public static func &-= (a: inout SIMD4<Scalar>, b: Scalar)

    public static func &*= (a: inout SIMD4<Scalar>, b: Scalar)

    public static func /= (a: inout SIMD4<Scalar>, b: Scalar)

    public static func %= (a: inout SIMD4<Scalar>, b: Scalar)
}

extension SIMD4 where Scalar : FloatingPoint {

    /// A vector with zero in all lanes.
    public static var zero: SIMD4<Scalar> { get }

    /// A vector with one in all lanes.
    public static var one: SIMD4<Scalar> { get }

    public mutating func clamp(lowerBound: SIMD4<Scalar>, upperBound: SIMD4<Scalar>)

    public func clamped(lowerBound: SIMD4<Scalar>, upperBound: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func + (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func - (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func * (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func / (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public func addingProduct(_ a: SIMD4<Scalar>, _ b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public func squareRoot() -> SIMD4<Scalar>

    /// A vector formed by rounding each lane of the source vector to an integral
    /// value according to the specified rounding `rule`.
    public func rounded(_ rule: FloatingPointRoundingRule) -> SIMD4<Scalar>

    /// The least scalar in the vector.
    public func min() -> Scalar

    /// The greatest scalar in the vector.
    public func max() -> Scalar

    /// The sum of the scalars in the vector.
    public func sum() -> Scalar

    prefix public static func - (a: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func + (a: Scalar, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func - (a: Scalar, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func * (a: Scalar, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func / (a: Scalar, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public static func + (a: SIMD4<Scalar>, b: Scalar) -> SIMD4<Scalar>

    public static func - (a: SIMD4<Scalar>, b: Scalar) -> SIMD4<Scalar>

    public static func * (a: SIMD4<Scalar>, b: Scalar) -> SIMD4<Scalar>

    public static func / (a: SIMD4<Scalar>, b: Scalar) -> SIMD4<Scalar>

    public static func += (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    public static func -= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    public static func *= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    public static func /= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    public static func += (a: inout SIMD4<Scalar>, b: Scalar)

    public static func -= (a: inout SIMD4<Scalar>, b: Scalar)

    public static func *= (a: inout SIMD4<Scalar>, b: Scalar)

    public static func /= (a: inout SIMD4<Scalar>, b: Scalar)

    public func addingProduct(_ a: Scalar, _ b: SIMD4<Scalar>) -> SIMD4<Scalar>

    public func addingProduct(_ a: SIMD4<Scalar>, _ b: Scalar) -> SIMD4<Scalar>

    public mutating func addProduct(_ a: SIMD4<Scalar>, _ b: SIMD4<Scalar>)

    public mutating func addProduct(_ a: Scalar, _ b: SIMD4<Scalar>)

    public mutating func addProduct(_ a: SIMD4<Scalar>, _ b: Scalar)

    public mutating func formSquareRoot()

    public mutating func round(_ rule: FloatingPointRoundingRule)
}

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension SIMD4 where Scalar == Float16 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<Float16>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Float16)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<Float16>()
    /// for i in 0..<2 {
    ///   result[i] = lowHalf[i]
    ///   result[2+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD2<Float16>, highHalf: SIMD2<Float16>)

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] == b[i])
    /// }
    /// ```
    public static func .== (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] == b)
    /// }
    /// ```
    public static func .== (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if a is equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a == b[i])
    /// }
    /// ```
    public static func .== (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] != b[i])
    /// }
    /// ```
    public static func .!= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] != b)
    /// }
    /// ```
    public static func .!= (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if a is not equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a != b[i])
    /// }
    /// ```
    public static func .!= (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] < b[i])
    /// }
    /// ```
    public static func .< (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] < b)
    /// }
    /// ```
    public static func .< (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if a is less than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a < b[i])
    /// }
    /// ```
    public static func .< (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] <= b[i])
    /// }
    /// ```
    public static func .<= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] <= b)
    /// }
    /// ```
    public static func .<= (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if a is less than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a <= b[i])
    /// }
    /// ```
    public static func .<= (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] >= b[i])
    /// }
    /// ```
    public static func .>= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] >= b)
    /// }
    /// ```
    public static func .>= (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if a is greater than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a >= b[i])
    /// }
    /// ```
    public static func .>= (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] > b[i])
    /// }
    /// ```
    public static func .> (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] > b)
    /// }
    /// ```
    public static func .> (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if a is greater than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a > b[i])
    /// }
    /// ```
    public static func .> (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>
}

extension SIMD4 where Scalar == Float {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<Float>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Float)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<Float>()
    /// for i in 0..<2 {
    ///   result[i] = lowHalf[i]
    ///   result[2+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD2<Float>, highHalf: SIMD2<Float>)

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] == b[i])
    /// }
    /// ```
    public static func .== (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] == b)
    /// }
    /// ```
    public static func .== (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if a is equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a == b[i])
    /// }
    /// ```
    public static func .== (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] != b[i])
    /// }
    /// ```
    public static func .!= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] != b)
    /// }
    /// ```
    public static func .!= (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if a is not equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a != b[i])
    /// }
    /// ```
    public static func .!= (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] < b[i])
    /// }
    /// ```
    public static func .< (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] < b)
    /// }
    /// ```
    public static func .< (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if a is less than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a < b[i])
    /// }
    /// ```
    public static func .< (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] <= b[i])
    /// }
    /// ```
    public static func .<= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] <= b)
    /// }
    /// ```
    public static func .<= (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if a is less than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a <= b[i])
    /// }
    /// ```
    public static func .<= (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] >= b[i])
    /// }
    /// ```
    public static func .>= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] >= b)
    /// }
    /// ```
    public static func .>= (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if a is greater than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a >= b[i])
    /// }
    /// ```
    public static func .>= (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] > b[i])
    /// }
    /// ```
    public static func .> (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] > b)
    /// }
    /// ```
    public static func .> (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if a is greater than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a > b[i])
    /// }
    /// ```
    public static func .> (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>
}

extension SIMD4 where Scalar == Double {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<Double>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Double)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<Double>()
    /// for i in 0..<2 {
    ///   result[i] = lowHalf[i]
    ///   result[2+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD2<Double>, highHalf: SIMD2<Double>)

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] == b[i])
    /// }
    /// ```
    public static func .== (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] == b)
    /// }
    /// ```
    public static func .== (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if a is equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a == b[i])
    /// }
    /// ```
    public static func .== (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] != b[i])
    /// }
    /// ```
    public static func .!= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] != b)
    /// }
    /// ```
    public static func .!= (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if a is not equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a != b[i])
    /// }
    /// ```
    public static func .!= (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] < b[i])
    /// }
    /// ```
    public static func .< (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] < b)
    /// }
    /// ```
    public static func .< (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if a is less than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a < b[i])
    /// }
    /// ```
    public static func .< (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] <= b[i])
    /// }
    /// ```
    public static func .<= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] <= b)
    /// }
    /// ```
    public static func .<= (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if a is less than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a <= b[i])
    /// }
    /// ```
    public static func .<= (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] >= b[i])
    /// }
    /// ```
    public static func .>= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] >= b)
    /// }
    /// ```
    public static func .>= (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if a is greater than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a >= b[i])
    /// }
    /// ```
    public static func .>= (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] > b[i])
    /// }
    /// ```
    public static func .> (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a[i] > b)
    /// }
    /// ```
    public static func .> (a: SIMD4<Scalar>, b: Scalar) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if a is greater than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<4 {
    ///   result[i] = (a > b[i])
    /// }
    /// ```
    public static func .> (a: Scalar, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>
}

extension SIMD4 where Scalar == UInt8 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<UInt8>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt8)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<UInt8>()
    /// for i in 0..<2 {
    ///   result[i] = lowHalf[i]
    ///   result[2+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD2<UInt8>, highHalf: SIMD2<UInt8>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)
}

extension SIMD4 where Scalar == Int8 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<Int8>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int8)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<Int8>()
    /// for i in 0..<2 {
    ///   result[i] = lowHalf[i]
    ///   result[2+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD2<Int8>, highHalf: SIMD2<Int8>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)
}

extension SIMD4 where Scalar == UInt16 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<UInt16>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt16)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<UInt16>()
    /// for i in 0..<2 {
    ///   result[i] = lowHalf[i]
    ///   result[2+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD2<UInt16>, highHalf: SIMD2<UInt16>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)
}

extension SIMD4 where Scalar == Int16 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<Int16>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int16)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<Int16>()
    /// for i in 0..<2 {
    ///   result[i] = lowHalf[i]
    ///   result[2+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD2<Int16>, highHalf: SIMD2<Int16>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)
}

extension SIMD4 where Scalar == UInt32 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<UInt32>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt32)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<UInt32>()
    /// for i in 0..<2 {
    ///   result[i] = lowHalf[i]
    ///   result[2+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD2<UInt32>, highHalf: SIMD2<UInt32>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)
}

extension SIMD4 where Scalar == Int32 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<Int32>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int32)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<Int32>()
    /// for i in 0..<2 {
    ///   result[i] = lowHalf[i]
    ///   result[2+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD2<Int32>, highHalf: SIMD2<Int32>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)
}

extension SIMD4 where Scalar == UInt64 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<UInt64>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt64)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<UInt64>()
    /// for i in 0..<2 {
    ///   result[i] = lowHalf[i]
    ///   result[2+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD2<UInt64>, highHalf: SIMD2<UInt64>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)
}

extension SIMD4 where Scalar == Int64 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<Int64>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int64)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<Int64>()
    /// for i in 0..<2 {
    ///   result[i] = lowHalf[i]
    ///   result[2+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD2<Int64>, highHalf: SIMD2<Int64>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)
}

extension SIMD4 where Scalar == UInt {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<UInt>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<UInt>()
    /// for i in 0..<2 {
    ///   result[i] = lowHalf[i]
    ///   result[2+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD2<UInt>, highHalf: SIMD2<UInt>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)
}

extension SIMD4 where Scalar == Int {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<Int>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD4<Int>()
    /// for i in 0..<2 {
    ///   result[i] = lowHalf[i]
    ///   result[2+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD2<Int>, highHalf: SIMD2<Int>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMDMask<SIMD4<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD4<Scalar>, b: SIMD4<Scalar>) -> SIMD4<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD4<Scalar>, b: SIMD4<Scalar>)
}

extension SIMD4 where Scalar : BinaryFloatingPoint {

    /// Creates a new vector from the given vector of integers.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(_ other: SIMD4<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    /// Creates a new vector from the given vector of floating-point values.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(_ other: SIMD4<Other>) where Other : BinaryFloatingPoint, Other : SIMDScalar
}

/// A vector of eight scalar values.
@frozen public struct SIMD8<Scalar> : SIMD where Scalar : SIMDScalar {

    /// The mask type resulting from pointwise comparisons of this vector type.
    public typealias MaskStorage = SIMD8<Scalar.SIMDMaskScalar>

    /// The number of scalars in the vector.
    public var scalarCount: Int { get }

    /// Creates a vector with zero in all lanes.
    public init()

    /// Accesses the scalar at the specified position.
    public subscript(index: Int) -> Scalar

    /// Creates a new vector from the given elements.
    public init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar, _ v6: Scalar, _ v7: Scalar)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<Scalar>()
    /// for i in 0..<4 {
    ///   result[i] = lowHalf[i]
    ///   result[4+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD4<Scalar>, highHalf: SIMD4<Scalar>)

    /// A half-length vector made up of the low elements of the vector.
    public var lowHalf: SIMD4<Scalar>

    /// A half-length vector made up of the high elements of the vector.
    public var highHalf: SIMD4<Scalar>

    /// A half-length vector made up of the even elements of the vector.
    public var evenHalf: SIMD4<Scalar>

    /// A half-length vector made up of the odd elements of the vector.
    public var oddHalf: SIMD4<Scalar>

    /// The type of the elements of an array literal.
    public typealias ArrayLiteralElement = Scalar

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    ///   The compiler provides an implementation for `hashValue` for you.
    public var hashValue: Int { get }

    /// Returns a Boolean value indicating whether two values are not equal.
    ///
    /// Inequality is the inverse of equality. For any values `a` and `b`, `a != b`
    /// implies that `a == b` is `false`.
    ///
    /// This is the default implementation of the not-equal-to operator (`!=`)
    /// for any type that conforms to `Equatable`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func != (lhs: SIMD8<Scalar>, rhs: SIMD8<Scalar>) -> Bool

    /// The number of scalars, or elements, in a vector of this type.
    public static var scalarCount: Int { get }

    /// The valid indices for subscripting the vector.
    public var indices: Range<Int> { get }

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating value: Scalar)

    /// Returns a Boolean value indicating whether two vectors are equal.
    public static func == (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> Bool

    /// Hashes the elements of the vector using the given hasher.
    @inlinable public func hash(into hasher: inout Hasher)

    /// Encodes the scalars of this vector into the given encoder in an unkeyed
    /// container.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new vector by decoding scalars from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws

    /// A textual description of the vector.
    public var description: String { get }

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar.SIMDMaskScalar>>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar.SIMDMaskScalar>>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMD8<Scalar>, where mask: SIMDMask<SIMD8<Scalar.SIMDMaskScalar>>)

    /// Creates a vector from the specified elements.
    ///
    /// - Parameter scalars: The elements to use in the vector. `scalars` must
    ///   have the same number of elements as the vector type.
    @inlinable public init(arrayLiteral scalars: Scalar...)

    /// Creates a vector from the given sequence.
    ///
    /// - Precondition: `scalars` must have the same number of elements as the
    ///   vector type.
    ///
    /// - Parameter scalars: The elements to use in the vector.
    @inlinable public init<S>(_ scalars: S) where S : Sequence, Scalar == S.Element

    /// Extracts the scalars at specified indices to form a SIMD2.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD2<Index>) -> SIMD2<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD3.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD3<Index>) -> SIMD3<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD4.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD4<Index>) -> SIMD4<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD8.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD8<Index>) -> SIMD8<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD16.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD16<Index>) -> SIMD16<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD32.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD32<Index>) -> SIMD32<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD64.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD64<Index>) -> SIMD64<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Returns a vector mask with the result of a pointwise equality comparison.
    public static func .== (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar.SIMDMaskScalar>>

    /// Replaces elements of this vector with `other` in the lanes where `mask`
    /// is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other }
    /// }
    /// ```
    public mutating func replace(with other: Scalar, where mask: SIMDMask<SIMD8<Scalar.SIMDMaskScalar>>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMD8<Scalar>, where mask: SIMDMask<SIMD8<Scalar.SIMDMaskScalar>>) -> SIMD8<Scalar>

    /// Returns a copy of this vector, with elements `other` in the lanes where
    /// `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other : self[i]
    /// }
    /// ```
    public func replacing(with other: Scalar, where mask: SIMDMask<SIMD8<Scalar.SIMDMaskScalar>>) -> SIMD8<Scalar>
}

extension SIMD8 : CustomDebugStringConvertible {

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

extension SIMD8 where Scalar : Comparable {

    /// Returns a vector mask with the result of a pointwise less than
    /// comparison.
    public static func .< (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar.SIMDMaskScalar>>

    /// The least element in the vector.
    public func min() -> Scalar

    /// The greatest element in the vector.
    public func max() -> Scalar

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than comparison.
    public static func .< (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than comparison.
    public static func .< (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar.SIMDMaskScalar>>

    public mutating func clamp(lowerBound: SIMD8<Scalar>, upperBound: SIMD8<Scalar>)

    public func clamped(lowerBound: SIMD8<Scalar>, upperBound: SIMD8<Scalar>) -> SIMD8<Scalar>
}

extension SIMD8 where Scalar : FixedWidthInteger {

    /// Creates a new vector from the given vector, truncating the bit patterns
    /// of the given vector's elements if necessary.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(truncatingIfNeeded other: SIMD8<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    /// Creates a new vector from the given vector, clamping the values of the
    /// given vector's elements if necessary.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(clamping other: SIMD8<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    /// Creates a new vector from the given vector, rounding the given vector's
    /// of elements using the specified rounding rule.
    ///
    /// - Parameters:
    ///   - other: The vector to convert.
    ///   - rule: The round rule to use when converting elements of `other.` The
    ///     default is `.towardZero`.
    @inlinable public init<Other>(_ other: SIMD8<Other>, rounding rule: FloatingPointRoundingRule = .towardZero) where Other : BinaryFloatingPoint, Other : SIMDScalar

    /// A vector with zero in all lanes.
    public static var zero: SIMD8<Scalar> { get }

    /// A vector with one in all lanes.
    public static var one: SIMD8<Scalar> { get }

    /// Returns a vector with random values from within the specified range in
    /// all lanes, using the given generator as a source for randomness.
    @inlinable public static func random<T>(in range: Range<Scalar>, using generator: inout T) -> SIMD8<Scalar> where T : RandomNumberGenerator

    /// Returns a vector with random values from within the specified range in
    /// all lanes.
    @inlinable public static func random(in range: Range<Scalar>) -> SIMD8<Scalar>

    /// Returns a vector with random values from within the specified range in
    /// all lanes, using the given generator as a source for randomness.
    @inlinable public static func random<T>(in range: ClosedRange<Scalar>, using generator: inout T) -> SIMD8<Scalar> where T : RandomNumberGenerator

    /// Returns a vector with random values from within the specified range in
    /// all lanes.
    @inlinable public static func random(in range: ClosedRange<Scalar>) -> SIMD8<Scalar>

    public var leadingZeroBitCount: SIMD8<Scalar> { get }

    public var trailingZeroBitCount: SIMD8<Scalar> { get }

    public var nonzeroBitCount: SIMD8<Scalar> { get }

    prefix public static func ~ (a: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func & (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func ^ (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func | (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func &<< (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func &>> (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func &+ (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func &- (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func &* (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func / (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func % (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// Returns the sum of the scalars in the vector, computed with wrapping
    /// addition.
    ///
    /// Equivalent to `indices.reduce(into: 0) { $0 &+= self[$1] }`.
    public func wrappedSum() -> Scalar

    public static func & (a: Scalar, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func ^ (a: Scalar, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func | (a: Scalar, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func &<< (a: Scalar, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func &>> (a: Scalar, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func &+ (a: Scalar, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func &- (a: Scalar, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func &* (a: Scalar, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func / (a: Scalar, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func % (a: Scalar, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func & (a: SIMD8<Scalar>, b: Scalar) -> SIMD8<Scalar>

    public static func ^ (a: SIMD8<Scalar>, b: Scalar) -> SIMD8<Scalar>

    public static func | (a: SIMD8<Scalar>, b: Scalar) -> SIMD8<Scalar>

    public static func &<< (a: SIMD8<Scalar>, b: Scalar) -> SIMD8<Scalar>

    public static func &>> (a: SIMD8<Scalar>, b: Scalar) -> SIMD8<Scalar>

    public static func &+ (a: SIMD8<Scalar>, b: Scalar) -> SIMD8<Scalar>

    public static func &- (a: SIMD8<Scalar>, b: Scalar) -> SIMD8<Scalar>

    public static func &* (a: SIMD8<Scalar>, b: Scalar) -> SIMD8<Scalar>

    public static func / (a: SIMD8<Scalar>, b: Scalar) -> SIMD8<Scalar>

    public static func % (a: SIMD8<Scalar>, b: Scalar) -> SIMD8<Scalar>

    public static func &= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    public static func ^= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    public static func |= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    public static func &<<= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    public static func &>>= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    public static func &+= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    public static func &-= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    public static func &*= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    public static func /= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    public static func %= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    public static func &= (a: inout SIMD8<Scalar>, b: Scalar)

    public static func ^= (a: inout SIMD8<Scalar>, b: Scalar)

    public static func |= (a: inout SIMD8<Scalar>, b: Scalar)

    public static func &<<= (a: inout SIMD8<Scalar>, b: Scalar)

    public static func &>>= (a: inout SIMD8<Scalar>, b: Scalar)

    public static func &+= (a: inout SIMD8<Scalar>, b: Scalar)

    public static func &-= (a: inout SIMD8<Scalar>, b: Scalar)

    public static func &*= (a: inout SIMD8<Scalar>, b: Scalar)

    public static func /= (a: inout SIMD8<Scalar>, b: Scalar)

    public static func %= (a: inout SIMD8<Scalar>, b: Scalar)
}

extension SIMD8 where Scalar : FloatingPoint {

    /// A vector with zero in all lanes.
    public static var zero: SIMD8<Scalar> { get }

    /// A vector with one in all lanes.
    public static var one: SIMD8<Scalar> { get }

    public mutating func clamp(lowerBound: SIMD8<Scalar>, upperBound: SIMD8<Scalar>)

    public func clamped(lowerBound: SIMD8<Scalar>, upperBound: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func + (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func - (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func * (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func / (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public func addingProduct(_ a: SIMD8<Scalar>, _ b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public func squareRoot() -> SIMD8<Scalar>

    /// A vector formed by rounding each lane of the source vector to an integral
    /// value according to the specified rounding `rule`.
    public func rounded(_ rule: FloatingPointRoundingRule) -> SIMD8<Scalar>

    /// The least scalar in the vector.
    public func min() -> Scalar

    /// The greatest scalar in the vector.
    public func max() -> Scalar

    /// The sum of the scalars in the vector.
    public func sum() -> Scalar

    prefix public static func - (a: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func + (a: Scalar, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func - (a: Scalar, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func * (a: Scalar, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func / (a: Scalar, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public static func + (a: SIMD8<Scalar>, b: Scalar) -> SIMD8<Scalar>

    public static func - (a: SIMD8<Scalar>, b: Scalar) -> SIMD8<Scalar>

    public static func * (a: SIMD8<Scalar>, b: Scalar) -> SIMD8<Scalar>

    public static func / (a: SIMD8<Scalar>, b: Scalar) -> SIMD8<Scalar>

    public static func += (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    public static func -= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    public static func *= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    public static func /= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    public static func += (a: inout SIMD8<Scalar>, b: Scalar)

    public static func -= (a: inout SIMD8<Scalar>, b: Scalar)

    public static func *= (a: inout SIMD8<Scalar>, b: Scalar)

    public static func /= (a: inout SIMD8<Scalar>, b: Scalar)

    public func addingProduct(_ a: Scalar, _ b: SIMD8<Scalar>) -> SIMD8<Scalar>

    public func addingProduct(_ a: SIMD8<Scalar>, _ b: Scalar) -> SIMD8<Scalar>

    public mutating func addProduct(_ a: SIMD8<Scalar>, _ b: SIMD8<Scalar>)

    public mutating func addProduct(_ a: Scalar, _ b: SIMD8<Scalar>)

    public mutating func addProduct(_ a: SIMD8<Scalar>, _ b: Scalar)

    public mutating func formSquareRoot()

    public mutating func round(_ rule: FloatingPointRoundingRule)
}

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension SIMD8 where Scalar == Float16 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<Float16>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Float16)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<Float16>()
    /// for i in 0..<4 {
    ///   result[i] = lowHalf[i]
    ///   result[4+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD4<Float16>, highHalf: SIMD4<Float16>)

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] == b[i])
    /// }
    /// ```
    public static func .== (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] == b)
    /// }
    /// ```
    public static func .== (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if a is equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a == b[i])
    /// }
    /// ```
    public static func .== (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] != b[i])
    /// }
    /// ```
    public static func .!= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] != b)
    /// }
    /// ```
    public static func .!= (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if a is not equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a != b[i])
    /// }
    /// ```
    public static func .!= (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] < b[i])
    /// }
    /// ```
    public static func .< (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] < b)
    /// }
    /// ```
    public static func .< (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if a is less than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a < b[i])
    /// }
    /// ```
    public static func .< (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] <= b[i])
    /// }
    /// ```
    public static func .<= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] <= b)
    /// }
    /// ```
    public static func .<= (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if a is less than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a <= b[i])
    /// }
    /// ```
    public static func .<= (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] >= b[i])
    /// }
    /// ```
    public static func .>= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] >= b)
    /// }
    /// ```
    public static func .>= (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if a is greater than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a >= b[i])
    /// }
    /// ```
    public static func .>= (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] > b[i])
    /// }
    /// ```
    public static func .> (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] > b)
    /// }
    /// ```
    public static func .> (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if a is greater than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a > b[i])
    /// }
    /// ```
    public static func .> (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>
}

extension SIMD8 where Scalar == Float {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<Float>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Float)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<Float>()
    /// for i in 0..<4 {
    ///   result[i] = lowHalf[i]
    ///   result[4+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD4<Float>, highHalf: SIMD4<Float>)

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] == b[i])
    /// }
    /// ```
    public static func .== (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] == b)
    /// }
    /// ```
    public static func .== (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if a is equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a == b[i])
    /// }
    /// ```
    public static func .== (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] != b[i])
    /// }
    /// ```
    public static func .!= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] != b)
    /// }
    /// ```
    public static func .!= (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if a is not equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a != b[i])
    /// }
    /// ```
    public static func .!= (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] < b[i])
    /// }
    /// ```
    public static func .< (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] < b)
    /// }
    /// ```
    public static func .< (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if a is less than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a < b[i])
    /// }
    /// ```
    public static func .< (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] <= b[i])
    /// }
    /// ```
    public static func .<= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] <= b)
    /// }
    /// ```
    public static func .<= (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if a is less than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a <= b[i])
    /// }
    /// ```
    public static func .<= (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] >= b[i])
    /// }
    /// ```
    public static func .>= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] >= b)
    /// }
    /// ```
    public static func .>= (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if a is greater than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a >= b[i])
    /// }
    /// ```
    public static func .>= (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] > b[i])
    /// }
    /// ```
    public static func .> (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] > b)
    /// }
    /// ```
    public static func .> (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if a is greater than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a > b[i])
    /// }
    /// ```
    public static func .> (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>
}

extension SIMD8 where Scalar == Double {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<Double>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Double)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<Double>()
    /// for i in 0..<4 {
    ///   result[i] = lowHalf[i]
    ///   result[4+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD4<Double>, highHalf: SIMD4<Double>)

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] == b[i])
    /// }
    /// ```
    public static func .== (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] == b)
    /// }
    /// ```
    public static func .== (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if a is equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a == b[i])
    /// }
    /// ```
    public static func .== (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] != b[i])
    /// }
    /// ```
    public static func .!= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] != b)
    /// }
    /// ```
    public static func .!= (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if a is not equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a != b[i])
    /// }
    /// ```
    public static func .!= (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] < b[i])
    /// }
    /// ```
    public static func .< (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] < b)
    /// }
    /// ```
    public static func .< (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if a is less than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a < b[i])
    /// }
    /// ```
    public static func .< (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] <= b[i])
    /// }
    /// ```
    public static func .<= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] <= b)
    /// }
    /// ```
    public static func .<= (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if a is less than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a <= b[i])
    /// }
    /// ```
    public static func .<= (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] >= b[i])
    /// }
    /// ```
    public static func .>= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] >= b)
    /// }
    /// ```
    public static func .>= (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if a is greater than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a >= b[i])
    /// }
    /// ```
    public static func .>= (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] > b[i])
    /// }
    /// ```
    public static func .> (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a[i] > b)
    /// }
    /// ```
    public static func .> (a: SIMD8<Scalar>, b: Scalar) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if a is greater than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<8 {
    ///   result[i] = (a > b[i])
    /// }
    /// ```
    public static func .> (a: Scalar, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>
}

extension SIMD8 where Scalar == UInt8 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<UInt8>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt8)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<UInt8>()
    /// for i in 0..<4 {
    ///   result[i] = lowHalf[i]
    ///   result[4+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD4<UInt8>, highHalf: SIMD4<UInt8>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)
}

extension SIMD8 where Scalar == Int8 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<Int8>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int8)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<Int8>()
    /// for i in 0..<4 {
    ///   result[i] = lowHalf[i]
    ///   result[4+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD4<Int8>, highHalf: SIMD4<Int8>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)
}

extension SIMD8 where Scalar == UInt16 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<UInt16>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt16)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<UInt16>()
    /// for i in 0..<4 {
    ///   result[i] = lowHalf[i]
    ///   result[4+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD4<UInt16>, highHalf: SIMD4<UInt16>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)
}

extension SIMD8 where Scalar == Int16 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<Int16>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int16)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<Int16>()
    /// for i in 0..<4 {
    ///   result[i] = lowHalf[i]
    ///   result[4+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD4<Int16>, highHalf: SIMD4<Int16>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)
}

extension SIMD8 where Scalar == UInt32 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<UInt32>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt32)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<UInt32>()
    /// for i in 0..<4 {
    ///   result[i] = lowHalf[i]
    ///   result[4+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD4<UInt32>, highHalf: SIMD4<UInt32>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)
}

extension SIMD8 where Scalar == Int32 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<Int32>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int32)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<Int32>()
    /// for i in 0..<4 {
    ///   result[i] = lowHalf[i]
    ///   result[4+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD4<Int32>, highHalf: SIMD4<Int32>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)
}

extension SIMD8 where Scalar == UInt64 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<UInt64>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt64)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<UInt64>()
    /// for i in 0..<4 {
    ///   result[i] = lowHalf[i]
    ///   result[4+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD4<UInt64>, highHalf: SIMD4<UInt64>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)
}

extension SIMD8 where Scalar == Int64 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<Int64>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int64)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<Int64>()
    /// for i in 0..<4 {
    ///   result[i] = lowHalf[i]
    ///   result[4+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD4<Int64>, highHalf: SIMD4<Int64>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)
}

extension SIMD8 where Scalar == UInt {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<UInt>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<UInt>()
    /// for i in 0..<4 {
    ///   result[i] = lowHalf[i]
    ///   result[4+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD4<UInt>, highHalf: SIMD4<UInt>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)
}

extension SIMD8 where Scalar == Int {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<Int>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD8<Int>()
    /// for i in 0..<4 {
    ///   result[i] = lowHalf[i]
    ///   result[4+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD4<Int>, highHalf: SIMD4<Int>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMDMask<SIMD8<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD8<Scalar>, b: SIMD8<Scalar>) -> SIMD8<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD8<Scalar>, b: SIMD8<Scalar>)
}

extension SIMD8 where Scalar : BinaryFloatingPoint {

    /// Creates a new vector from the given vector of integers.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(_ other: SIMD8<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    /// Creates a new vector from the given vector of floating-point values.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(_ other: SIMD8<Other>) where Other : BinaryFloatingPoint, Other : SIMDScalar
}

/// A vector of 16 scalar values.
@frozen public struct SIMD16<Scalar> : SIMD where Scalar : SIMDScalar {

    /// The mask type resulting from pointwise comparisons of this vector type.
    public typealias MaskStorage = SIMD16<Scalar.SIMDMaskScalar>

    /// The number of scalars in the vector.
    public var scalarCount: Int { get }

    /// Creates a vector with zero in all lanes.
    public init()

    /// Accesses the scalar at the specified position.
    public subscript(index: Int) -> Scalar

    /// Creates a new vector from the given elements.
    public init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar, _ v6: Scalar, _ v7: Scalar, _ v8: Scalar, _ v9: Scalar, _ v10: Scalar, _ v11: Scalar, _ v12: Scalar, _ v13: Scalar, _ v14: Scalar, _ v15: Scalar)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<Scalar>()
    /// for i in 0..<8 {
    ///   result[i] = lowHalf[i]
    ///   result[8+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD8<Scalar>, highHalf: SIMD8<Scalar>)

    /// A half-length vector made up of the low elements of the vector.
    public var lowHalf: SIMD8<Scalar>

    /// A half-length vector made up of the high elements of the vector.
    public var highHalf: SIMD8<Scalar>

    /// A half-length vector made up of the even elements of the vector.
    public var evenHalf: SIMD8<Scalar>

    /// A half-length vector made up of the odd elements of the vector.
    public var oddHalf: SIMD8<Scalar>

    /// The type of the elements of an array literal.
    public typealias ArrayLiteralElement = Scalar

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    ///   The compiler provides an implementation for `hashValue` for you.
    public var hashValue: Int { get }

    /// Returns a Boolean value indicating whether two values are not equal.
    ///
    /// Inequality is the inverse of equality. For any values `a` and `b`, `a != b`
    /// implies that `a == b` is `false`.
    ///
    /// This is the default implementation of the not-equal-to operator (`!=`)
    /// for any type that conforms to `Equatable`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func != (lhs: SIMD16<Scalar>, rhs: SIMD16<Scalar>) -> Bool

    /// The number of scalars, or elements, in a vector of this type.
    public static var scalarCount: Int { get }

    /// The valid indices for subscripting the vector.
    public var indices: Range<Int> { get }

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating value: Scalar)

    /// Returns a Boolean value indicating whether two vectors are equal.
    public static func == (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> Bool

    /// Hashes the elements of the vector using the given hasher.
    @inlinable public func hash(into hasher: inout Hasher)

    /// Encodes the scalars of this vector into the given encoder in an unkeyed
    /// container.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new vector by decoding scalars from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws

    /// A textual description of the vector.
    public var description: String { get }

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar.SIMDMaskScalar>>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar.SIMDMaskScalar>>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMD16<Scalar>, where mask: SIMDMask<SIMD16<Scalar.SIMDMaskScalar>>)

    /// Creates a vector from the specified elements.
    ///
    /// - Parameter scalars: The elements to use in the vector. `scalars` must
    ///   have the same number of elements as the vector type.
    @inlinable public init(arrayLiteral scalars: Scalar...)

    /// Creates a vector from the given sequence.
    ///
    /// - Precondition: `scalars` must have the same number of elements as the
    ///   vector type.
    ///
    /// - Parameter scalars: The elements to use in the vector.
    @inlinable public init<S>(_ scalars: S) where S : Sequence, Scalar == S.Element

    /// Extracts the scalars at specified indices to form a SIMD2.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD2<Index>) -> SIMD2<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD3.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD3<Index>) -> SIMD3<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD4.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD4<Index>) -> SIMD4<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD8.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD8<Index>) -> SIMD8<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD16.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD16<Index>) -> SIMD16<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD32.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD32<Index>) -> SIMD32<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD64.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD64<Index>) -> SIMD64<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Returns a vector mask with the result of a pointwise equality comparison.
    public static func .== (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar.SIMDMaskScalar>>

    /// Replaces elements of this vector with `other` in the lanes where `mask`
    /// is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other }
    /// }
    /// ```
    public mutating func replace(with other: Scalar, where mask: SIMDMask<SIMD16<Scalar.SIMDMaskScalar>>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMD16<Scalar>, where mask: SIMDMask<SIMD16<Scalar.SIMDMaskScalar>>) -> SIMD16<Scalar>

    /// Returns a copy of this vector, with elements `other` in the lanes where
    /// `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other : self[i]
    /// }
    /// ```
    public func replacing(with other: Scalar, where mask: SIMDMask<SIMD16<Scalar.SIMDMaskScalar>>) -> SIMD16<Scalar>
}

extension SIMD16 : CustomDebugStringConvertible {

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

extension SIMD16 where Scalar : Comparable {

    /// Returns a vector mask with the result of a pointwise less than
    /// comparison.
    public static func .< (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar.SIMDMaskScalar>>

    /// The least element in the vector.
    public func min() -> Scalar

    /// The greatest element in the vector.
    public func max() -> Scalar

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than comparison.
    public static func .< (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than comparison.
    public static func .< (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar.SIMDMaskScalar>>

    public mutating func clamp(lowerBound: SIMD16<Scalar>, upperBound: SIMD16<Scalar>)

    public func clamped(lowerBound: SIMD16<Scalar>, upperBound: SIMD16<Scalar>) -> SIMD16<Scalar>
}

extension SIMD16 where Scalar : FixedWidthInteger {

    /// Creates a new vector from the given vector, truncating the bit patterns
    /// of the given vector's elements if necessary.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(truncatingIfNeeded other: SIMD16<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    /// Creates a new vector from the given vector, clamping the values of the
    /// given vector's elements if necessary.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(clamping other: SIMD16<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    /// Creates a new vector from the given vector, rounding the given vector's
    /// of elements using the specified rounding rule.
    ///
    /// - Parameters:
    ///   - other: The vector to convert.
    ///   - rule: The round rule to use when converting elements of `other.` The
    ///     default is `.towardZero`.
    @inlinable public init<Other>(_ other: SIMD16<Other>, rounding rule: FloatingPointRoundingRule = .towardZero) where Other : BinaryFloatingPoint, Other : SIMDScalar

    /// A vector with zero in all lanes.
    public static var zero: SIMD16<Scalar> { get }

    /// A vector with one in all lanes.
    public static var one: SIMD16<Scalar> { get }

    /// Returns a vector with random values from within the specified range in
    /// all lanes, using the given generator as a source for randomness.
    @inlinable public static func random<T>(in range: Range<Scalar>, using generator: inout T) -> SIMD16<Scalar> where T : RandomNumberGenerator

    /// Returns a vector with random values from within the specified range in
    /// all lanes.
    @inlinable public static func random(in range: Range<Scalar>) -> SIMD16<Scalar>

    /// Returns a vector with random values from within the specified range in
    /// all lanes, using the given generator as a source for randomness.
    @inlinable public static func random<T>(in range: ClosedRange<Scalar>, using generator: inout T) -> SIMD16<Scalar> where T : RandomNumberGenerator

    /// Returns a vector with random values from within the specified range in
    /// all lanes.
    @inlinable public static func random(in range: ClosedRange<Scalar>) -> SIMD16<Scalar>

    public var leadingZeroBitCount: SIMD16<Scalar> { get }

    public var trailingZeroBitCount: SIMD16<Scalar> { get }

    public var nonzeroBitCount: SIMD16<Scalar> { get }

    prefix public static func ~ (a: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func & (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func ^ (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func | (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func &<< (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func &>> (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func &+ (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func &- (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func &* (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func / (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func % (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// Returns the sum of the scalars in the vector, computed with wrapping
    /// addition.
    ///
    /// Equivalent to `indices.reduce(into: 0) { $0 &+= self[$1] }`.
    public func wrappedSum() -> Scalar

    public static func & (a: Scalar, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func ^ (a: Scalar, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func | (a: Scalar, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func &<< (a: Scalar, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func &>> (a: Scalar, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func &+ (a: Scalar, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func &- (a: Scalar, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func &* (a: Scalar, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func / (a: Scalar, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func % (a: Scalar, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func & (a: SIMD16<Scalar>, b: Scalar) -> SIMD16<Scalar>

    public static func ^ (a: SIMD16<Scalar>, b: Scalar) -> SIMD16<Scalar>

    public static func | (a: SIMD16<Scalar>, b: Scalar) -> SIMD16<Scalar>

    public static func &<< (a: SIMD16<Scalar>, b: Scalar) -> SIMD16<Scalar>

    public static func &>> (a: SIMD16<Scalar>, b: Scalar) -> SIMD16<Scalar>

    public static func &+ (a: SIMD16<Scalar>, b: Scalar) -> SIMD16<Scalar>

    public static func &- (a: SIMD16<Scalar>, b: Scalar) -> SIMD16<Scalar>

    public static func &* (a: SIMD16<Scalar>, b: Scalar) -> SIMD16<Scalar>

    public static func / (a: SIMD16<Scalar>, b: Scalar) -> SIMD16<Scalar>

    public static func % (a: SIMD16<Scalar>, b: Scalar) -> SIMD16<Scalar>

    public static func &= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    public static func ^= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    public static func |= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    public static func &<<= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    public static func &>>= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    public static func &+= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    public static func &-= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    public static func &*= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    public static func /= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    public static func %= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    public static func &= (a: inout SIMD16<Scalar>, b: Scalar)

    public static func ^= (a: inout SIMD16<Scalar>, b: Scalar)

    public static func |= (a: inout SIMD16<Scalar>, b: Scalar)

    public static func &<<= (a: inout SIMD16<Scalar>, b: Scalar)

    public static func &>>= (a: inout SIMD16<Scalar>, b: Scalar)

    public static func &+= (a: inout SIMD16<Scalar>, b: Scalar)

    public static func &-= (a: inout SIMD16<Scalar>, b: Scalar)

    public static func &*= (a: inout SIMD16<Scalar>, b: Scalar)

    public static func /= (a: inout SIMD16<Scalar>, b: Scalar)

    public static func %= (a: inout SIMD16<Scalar>, b: Scalar)
}

extension SIMD16 where Scalar : FloatingPoint {

    /// A vector with zero in all lanes.
    public static var zero: SIMD16<Scalar> { get }

    /// A vector with one in all lanes.
    public static var one: SIMD16<Scalar> { get }

    public mutating func clamp(lowerBound: SIMD16<Scalar>, upperBound: SIMD16<Scalar>)

    public func clamped(lowerBound: SIMD16<Scalar>, upperBound: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func + (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func - (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func * (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func / (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public func addingProduct(_ a: SIMD16<Scalar>, _ b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public func squareRoot() -> SIMD16<Scalar>

    /// A vector formed by rounding each lane of the source vector to an integral
    /// value according to the specified rounding `rule`.
    public func rounded(_ rule: FloatingPointRoundingRule) -> SIMD16<Scalar>

    /// The least scalar in the vector.
    public func min() -> Scalar

    /// The greatest scalar in the vector.
    public func max() -> Scalar

    /// The sum of the scalars in the vector.
    public func sum() -> Scalar

    prefix public static func - (a: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func + (a: Scalar, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func - (a: Scalar, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func * (a: Scalar, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func / (a: Scalar, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public static func + (a: SIMD16<Scalar>, b: Scalar) -> SIMD16<Scalar>

    public static func - (a: SIMD16<Scalar>, b: Scalar) -> SIMD16<Scalar>

    public static func * (a: SIMD16<Scalar>, b: Scalar) -> SIMD16<Scalar>

    public static func / (a: SIMD16<Scalar>, b: Scalar) -> SIMD16<Scalar>

    public static func += (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    public static func -= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    public static func *= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    public static func /= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    public static func += (a: inout SIMD16<Scalar>, b: Scalar)

    public static func -= (a: inout SIMD16<Scalar>, b: Scalar)

    public static func *= (a: inout SIMD16<Scalar>, b: Scalar)

    public static func /= (a: inout SIMD16<Scalar>, b: Scalar)

    public func addingProduct(_ a: Scalar, _ b: SIMD16<Scalar>) -> SIMD16<Scalar>

    public func addingProduct(_ a: SIMD16<Scalar>, _ b: Scalar) -> SIMD16<Scalar>

    public mutating func addProduct(_ a: SIMD16<Scalar>, _ b: SIMD16<Scalar>)

    public mutating func addProduct(_ a: Scalar, _ b: SIMD16<Scalar>)

    public mutating func addProduct(_ a: SIMD16<Scalar>, _ b: Scalar)

    public mutating func formSquareRoot()

    public mutating func round(_ rule: FloatingPointRoundingRule)
}

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension SIMD16 where Scalar == Float16 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<Float16>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Float16)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<Float16>()
    /// for i in 0..<8 {
    ///   result[i] = lowHalf[i]
    ///   result[8+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD8<Float16>, highHalf: SIMD8<Float16>)

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] == b[i])
    /// }
    /// ```
    public static func .== (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] == b)
    /// }
    /// ```
    public static func .== (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if a is equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a == b[i])
    /// }
    /// ```
    public static func .== (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] != b[i])
    /// }
    /// ```
    public static func .!= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] != b)
    /// }
    /// ```
    public static func .!= (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if a is not equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a != b[i])
    /// }
    /// ```
    public static func .!= (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] < b[i])
    /// }
    /// ```
    public static func .< (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] < b)
    /// }
    /// ```
    public static func .< (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if a is less than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a < b[i])
    /// }
    /// ```
    public static func .< (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] <= b[i])
    /// }
    /// ```
    public static func .<= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] <= b)
    /// }
    /// ```
    public static func .<= (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if a is less than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a <= b[i])
    /// }
    /// ```
    public static func .<= (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] >= b[i])
    /// }
    /// ```
    public static func .>= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] >= b)
    /// }
    /// ```
    public static func .>= (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if a is greater than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a >= b[i])
    /// }
    /// ```
    public static func .>= (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] > b[i])
    /// }
    /// ```
    public static func .> (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] > b)
    /// }
    /// ```
    public static func .> (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if a is greater than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a > b[i])
    /// }
    /// ```
    public static func .> (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>
}

extension SIMD16 where Scalar == Float {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<Float>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Float)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<Float>()
    /// for i in 0..<8 {
    ///   result[i] = lowHalf[i]
    ///   result[8+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD8<Float>, highHalf: SIMD8<Float>)

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] == b[i])
    /// }
    /// ```
    public static func .== (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] == b)
    /// }
    /// ```
    public static func .== (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if a is equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a == b[i])
    /// }
    /// ```
    public static func .== (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] != b[i])
    /// }
    /// ```
    public static func .!= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] != b)
    /// }
    /// ```
    public static func .!= (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if a is not equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a != b[i])
    /// }
    /// ```
    public static func .!= (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] < b[i])
    /// }
    /// ```
    public static func .< (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] < b)
    /// }
    /// ```
    public static func .< (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if a is less than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a < b[i])
    /// }
    /// ```
    public static func .< (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] <= b[i])
    /// }
    /// ```
    public static func .<= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] <= b)
    /// }
    /// ```
    public static func .<= (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if a is less than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a <= b[i])
    /// }
    /// ```
    public static func .<= (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] >= b[i])
    /// }
    /// ```
    public static func .>= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] >= b)
    /// }
    /// ```
    public static func .>= (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if a is greater than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a >= b[i])
    /// }
    /// ```
    public static func .>= (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] > b[i])
    /// }
    /// ```
    public static func .> (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] > b)
    /// }
    /// ```
    public static func .> (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if a is greater than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a > b[i])
    /// }
    /// ```
    public static func .> (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>
}

extension SIMD16 where Scalar == Double {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<Double>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Double)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<Double>()
    /// for i in 0..<8 {
    ///   result[i] = lowHalf[i]
    ///   result[8+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD8<Double>, highHalf: SIMD8<Double>)

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] == b[i])
    /// }
    /// ```
    public static func .== (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] == b)
    /// }
    /// ```
    public static func .== (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if a is equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a == b[i])
    /// }
    /// ```
    public static func .== (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] != b[i])
    /// }
    /// ```
    public static func .!= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] != b)
    /// }
    /// ```
    public static func .!= (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if a is not equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a != b[i])
    /// }
    /// ```
    public static func .!= (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] < b[i])
    /// }
    /// ```
    public static func .< (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] < b)
    /// }
    /// ```
    public static func .< (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if a is less than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a < b[i])
    /// }
    /// ```
    public static func .< (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] <= b[i])
    /// }
    /// ```
    public static func .<= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] <= b)
    /// }
    /// ```
    public static func .<= (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if a is less than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a <= b[i])
    /// }
    /// ```
    public static func .<= (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] >= b[i])
    /// }
    /// ```
    public static func .>= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] >= b)
    /// }
    /// ```
    public static func .>= (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if a is greater than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a >= b[i])
    /// }
    /// ```
    public static func .>= (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] > b[i])
    /// }
    /// ```
    public static func .> (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a[i] > b)
    /// }
    /// ```
    public static func .> (a: SIMD16<Scalar>, b: Scalar) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if a is greater than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<16 {
    ///   result[i] = (a > b[i])
    /// }
    /// ```
    public static func .> (a: Scalar, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>
}

extension SIMD16 where Scalar == UInt8 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<UInt8>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt8)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<UInt8>()
    /// for i in 0..<8 {
    ///   result[i] = lowHalf[i]
    ///   result[8+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD8<UInt8>, highHalf: SIMD8<UInt8>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)
}

extension SIMD16 where Scalar == Int8 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<Int8>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int8)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<Int8>()
    /// for i in 0..<8 {
    ///   result[i] = lowHalf[i]
    ///   result[8+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD8<Int8>, highHalf: SIMD8<Int8>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)
}

extension SIMD16 where Scalar == UInt16 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<UInt16>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt16)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<UInt16>()
    /// for i in 0..<8 {
    ///   result[i] = lowHalf[i]
    ///   result[8+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD8<UInt16>, highHalf: SIMD8<UInt16>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)
}

extension SIMD16 where Scalar == Int16 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<Int16>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int16)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<Int16>()
    /// for i in 0..<8 {
    ///   result[i] = lowHalf[i]
    ///   result[8+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD8<Int16>, highHalf: SIMD8<Int16>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)
}

extension SIMD16 where Scalar == UInt32 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<UInt32>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt32)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<UInt32>()
    /// for i in 0..<8 {
    ///   result[i] = lowHalf[i]
    ///   result[8+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD8<UInt32>, highHalf: SIMD8<UInt32>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)
}

extension SIMD16 where Scalar == Int32 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<Int32>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int32)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<Int32>()
    /// for i in 0..<8 {
    ///   result[i] = lowHalf[i]
    ///   result[8+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD8<Int32>, highHalf: SIMD8<Int32>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)
}

extension SIMD16 where Scalar == UInt64 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<UInt64>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt64)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<UInt64>()
    /// for i in 0..<8 {
    ///   result[i] = lowHalf[i]
    ///   result[8+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD8<UInt64>, highHalf: SIMD8<UInt64>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)
}

extension SIMD16 where Scalar == Int64 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<Int64>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int64)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<Int64>()
    /// for i in 0..<8 {
    ///   result[i] = lowHalf[i]
    ///   result[8+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD8<Int64>, highHalf: SIMD8<Int64>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)
}

extension SIMD16 where Scalar == UInt {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<UInt>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<UInt>()
    /// for i in 0..<8 {
    ///   result[i] = lowHalf[i]
    ///   result[8+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD8<UInt>, highHalf: SIMD8<UInt>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)
}

extension SIMD16 where Scalar == Int {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<Int>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD16<Int>()
    /// for i in 0..<8 {
    ///   result[i] = lowHalf[i]
    ///   result[8+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD8<Int>, highHalf: SIMD8<Int>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMDMask<SIMD16<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD16<Scalar>, b: SIMD16<Scalar>) -> SIMD16<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD16<Scalar>, b: SIMD16<Scalar>)
}

extension SIMD16 where Scalar : BinaryFloatingPoint {

    /// Creates a new vector from the given vector of integers.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(_ other: SIMD16<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    /// Creates a new vector from the given vector of floating-point values.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(_ other: SIMD16<Other>) where Other : BinaryFloatingPoint, Other : SIMDScalar
}

/// A vector of 32 scalar values.
@frozen public struct SIMD32<Scalar> : SIMD where Scalar : SIMDScalar {

    /// The mask type resulting from pointwise comparisons of this vector type.
    public typealias MaskStorage = SIMD32<Scalar.SIMDMaskScalar>

    /// The number of scalars in the vector.
    public var scalarCount: Int { get }

    /// Creates a vector with zero in all lanes.
    public init()

    /// Accesses the scalar at the specified position.
    public subscript(index: Int) -> Scalar

    /// Creates a new vector from the given elements.
    public init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar, _ v6: Scalar, _ v7: Scalar, _ v8: Scalar, _ v9: Scalar, _ v10: Scalar, _ v11: Scalar, _ v12: Scalar, _ v13: Scalar, _ v14: Scalar, _ v15: Scalar, _ v16: Scalar, _ v17: Scalar, _ v18: Scalar, _ v19: Scalar, _ v20: Scalar, _ v21: Scalar, _ v22: Scalar, _ v23: Scalar, _ v24: Scalar, _ v25: Scalar, _ v26: Scalar, _ v27: Scalar, _ v28: Scalar, _ v29: Scalar, _ v30: Scalar, _ v31: Scalar)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<Scalar>()
    /// for i in 0..<16 {
    ///   result[i] = lowHalf[i]
    ///   result[16+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD16<Scalar>, highHalf: SIMD16<Scalar>)

    /// A half-length vector made up of the low elements of the vector.
    public var lowHalf: SIMD16<Scalar>

    /// A half-length vector made up of the high elements of the vector.
    public var highHalf: SIMD16<Scalar>

    /// A half-length vector made up of the even elements of the vector.
    public var evenHalf: SIMD16<Scalar>

    /// A half-length vector made up of the odd elements of the vector.
    public var oddHalf: SIMD16<Scalar>

    /// The type of the elements of an array literal.
    public typealias ArrayLiteralElement = Scalar

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    ///   The compiler provides an implementation for `hashValue` for you.
    public var hashValue: Int { get }

    /// Returns a Boolean value indicating whether two values are not equal.
    ///
    /// Inequality is the inverse of equality. For any values `a` and `b`, `a != b`
    /// implies that `a == b` is `false`.
    ///
    /// This is the default implementation of the not-equal-to operator (`!=`)
    /// for any type that conforms to `Equatable`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func != (lhs: SIMD32<Scalar>, rhs: SIMD32<Scalar>) -> Bool

    /// The number of scalars, or elements, in a vector of this type.
    public static var scalarCount: Int { get }

    /// The valid indices for subscripting the vector.
    public var indices: Range<Int> { get }

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating value: Scalar)

    /// Returns a Boolean value indicating whether two vectors are equal.
    public static func == (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> Bool

    /// Hashes the elements of the vector using the given hasher.
    @inlinable public func hash(into hasher: inout Hasher)

    /// Encodes the scalars of this vector into the given encoder in an unkeyed
    /// container.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new vector by decoding scalars from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws

    /// A textual description of the vector.
    public var description: String { get }

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMD32<Scalar>, where mask: SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>)

    /// Creates a vector from the specified elements.
    ///
    /// - Parameter scalars: The elements to use in the vector. `scalars` must
    ///   have the same number of elements as the vector type.
    @inlinable public init(arrayLiteral scalars: Scalar...)

    /// Creates a vector from the given sequence.
    ///
    /// - Precondition: `scalars` must have the same number of elements as the
    ///   vector type.
    ///
    /// - Parameter scalars: The elements to use in the vector.
    @inlinable public init<S>(_ scalars: S) where S : Sequence, Scalar == S.Element

    /// Extracts the scalars at specified indices to form a SIMD2.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD2<Index>) -> SIMD2<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD3.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD3<Index>) -> SIMD3<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD4.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD4<Index>) -> SIMD4<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD8.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD8<Index>) -> SIMD8<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD16.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD16<Index>) -> SIMD16<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD32.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD32<Index>) -> SIMD32<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD64.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD64<Index>) -> SIMD64<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Returns a vector mask with the result of a pointwise equality comparison.
    public static func .== (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>

    /// Replaces elements of this vector with `other` in the lanes where `mask`
    /// is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other }
    /// }
    /// ```
    public mutating func replace(with other: Scalar, where mask: SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMD32<Scalar>, where mask: SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>) -> SIMD32<Scalar>

    /// Returns a copy of this vector, with elements `other` in the lanes where
    /// `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other : self[i]
    /// }
    /// ```
    public func replacing(with other: Scalar, where mask: SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>) -> SIMD32<Scalar>
}

extension SIMD32 : CustomDebugStringConvertible {

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

extension SIMD32 where Scalar : Comparable {

    /// Returns a vector mask with the result of a pointwise less than
    /// comparison.
    public static func .< (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>

    /// The least element in the vector.
    public func min() -> Scalar

    /// The greatest element in the vector.
    public func max() -> Scalar

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than comparison.
    public static func .< (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than comparison.
    public static func .< (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>

    public mutating func clamp(lowerBound: SIMD32<Scalar>, upperBound: SIMD32<Scalar>)

    public func clamped(lowerBound: SIMD32<Scalar>, upperBound: SIMD32<Scalar>) -> SIMD32<Scalar>
}

extension SIMD32 where Scalar : FixedWidthInteger {

    /// Creates a new vector from the given vector, truncating the bit patterns
    /// of the given vector's elements if necessary.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(truncatingIfNeeded other: SIMD32<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    /// Creates a new vector from the given vector, clamping the values of the
    /// given vector's elements if necessary.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(clamping other: SIMD32<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    /// Creates a new vector from the given vector, rounding the given vector's
    /// of elements using the specified rounding rule.
    ///
    /// - Parameters:
    ///   - other: The vector to convert.
    ///   - rule: The round rule to use when converting elements of `other.` The
    ///     default is `.towardZero`.
    @inlinable public init<Other>(_ other: SIMD32<Other>, rounding rule: FloatingPointRoundingRule = .towardZero) where Other : BinaryFloatingPoint, Other : SIMDScalar

    /// A vector with zero in all lanes.
    public static var zero: SIMD32<Scalar> { get }

    /// A vector with one in all lanes.
    public static var one: SIMD32<Scalar> { get }

    /// Returns a vector with random values from within the specified range in
    /// all lanes, using the given generator as a source for randomness.
    @inlinable public static func random<T>(in range: Range<Scalar>, using generator: inout T) -> SIMD32<Scalar> where T : RandomNumberGenerator

    /// Returns a vector with random values from within the specified range in
    /// all lanes.
    @inlinable public static func random(in range: Range<Scalar>) -> SIMD32<Scalar>

    /// Returns a vector with random values from within the specified range in
    /// all lanes, using the given generator as a source for randomness.
    @inlinable public static func random<T>(in range: ClosedRange<Scalar>, using generator: inout T) -> SIMD32<Scalar> where T : RandomNumberGenerator

    /// Returns a vector with random values from within the specified range in
    /// all lanes.
    @inlinable public static func random(in range: ClosedRange<Scalar>) -> SIMD32<Scalar>

    public var leadingZeroBitCount: SIMD32<Scalar> { get }

    public var trailingZeroBitCount: SIMD32<Scalar> { get }

    public var nonzeroBitCount: SIMD32<Scalar> { get }

    prefix public static func ~ (a: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func & (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func ^ (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func | (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func &<< (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func &>> (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func &+ (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func &- (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func &* (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func / (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func % (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// Returns the sum of the scalars in the vector, computed with wrapping
    /// addition.
    ///
    /// Equivalent to `indices.reduce(into: 0) { $0 &+= self[$1] }`.
    public func wrappedSum() -> Scalar

    public static func & (a: Scalar, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func ^ (a: Scalar, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func | (a: Scalar, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func &<< (a: Scalar, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func &>> (a: Scalar, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func &+ (a: Scalar, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func &- (a: Scalar, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func &* (a: Scalar, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func / (a: Scalar, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func % (a: Scalar, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func & (a: SIMD32<Scalar>, b: Scalar) -> SIMD32<Scalar>

    public static func ^ (a: SIMD32<Scalar>, b: Scalar) -> SIMD32<Scalar>

    public static func | (a: SIMD32<Scalar>, b: Scalar) -> SIMD32<Scalar>

    public static func &<< (a: SIMD32<Scalar>, b: Scalar) -> SIMD32<Scalar>

    public static func &>> (a: SIMD32<Scalar>, b: Scalar) -> SIMD32<Scalar>

    public static func &+ (a: SIMD32<Scalar>, b: Scalar) -> SIMD32<Scalar>

    public static func &- (a: SIMD32<Scalar>, b: Scalar) -> SIMD32<Scalar>

    public static func &* (a: SIMD32<Scalar>, b: Scalar) -> SIMD32<Scalar>

    public static func / (a: SIMD32<Scalar>, b: Scalar) -> SIMD32<Scalar>

    public static func % (a: SIMD32<Scalar>, b: Scalar) -> SIMD32<Scalar>

    public static func &= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    public static func ^= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    public static func |= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    public static func &<<= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    public static func &>>= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    public static func &+= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    public static func &-= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    public static func &*= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    public static func /= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    public static func %= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    public static func &= (a: inout SIMD32<Scalar>, b: Scalar)

    public static func ^= (a: inout SIMD32<Scalar>, b: Scalar)

    public static func |= (a: inout SIMD32<Scalar>, b: Scalar)

    public static func &<<= (a: inout SIMD32<Scalar>, b: Scalar)

    public static func &>>= (a: inout SIMD32<Scalar>, b: Scalar)

    public static func &+= (a: inout SIMD32<Scalar>, b: Scalar)

    public static func &-= (a: inout SIMD32<Scalar>, b: Scalar)

    public static func &*= (a: inout SIMD32<Scalar>, b: Scalar)

    public static func /= (a: inout SIMD32<Scalar>, b: Scalar)

    public static func %= (a: inout SIMD32<Scalar>, b: Scalar)
}

extension SIMD32 where Scalar : FloatingPoint {

    /// A vector with zero in all lanes.
    public static var zero: SIMD32<Scalar> { get }

    /// A vector with one in all lanes.
    public static var one: SIMD32<Scalar> { get }

    public mutating func clamp(lowerBound: SIMD32<Scalar>, upperBound: SIMD32<Scalar>)

    public func clamped(lowerBound: SIMD32<Scalar>, upperBound: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func + (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func - (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func * (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func / (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public func addingProduct(_ a: SIMD32<Scalar>, _ b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public func squareRoot() -> SIMD32<Scalar>

    /// A vector formed by rounding each lane of the source vector to an integral
    /// value according to the specified rounding `rule`.
    public func rounded(_ rule: FloatingPointRoundingRule) -> SIMD32<Scalar>

    /// The least scalar in the vector.
    public func min() -> Scalar

    /// The greatest scalar in the vector.
    public func max() -> Scalar

    /// The sum of the scalars in the vector.
    public func sum() -> Scalar

    prefix public static func - (a: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func + (a: Scalar, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func - (a: Scalar, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func * (a: Scalar, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func / (a: Scalar, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public static func + (a: SIMD32<Scalar>, b: Scalar) -> SIMD32<Scalar>

    public static func - (a: SIMD32<Scalar>, b: Scalar) -> SIMD32<Scalar>

    public static func * (a: SIMD32<Scalar>, b: Scalar) -> SIMD32<Scalar>

    public static func / (a: SIMD32<Scalar>, b: Scalar) -> SIMD32<Scalar>

    public static func += (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    public static func -= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    public static func *= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    public static func /= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    public static func += (a: inout SIMD32<Scalar>, b: Scalar)

    public static func -= (a: inout SIMD32<Scalar>, b: Scalar)

    public static func *= (a: inout SIMD32<Scalar>, b: Scalar)

    public static func /= (a: inout SIMD32<Scalar>, b: Scalar)

    public func addingProduct(_ a: Scalar, _ b: SIMD32<Scalar>) -> SIMD32<Scalar>

    public func addingProduct(_ a: SIMD32<Scalar>, _ b: Scalar) -> SIMD32<Scalar>

    public mutating func addProduct(_ a: SIMD32<Scalar>, _ b: SIMD32<Scalar>)

    public mutating func addProduct(_ a: Scalar, _ b: SIMD32<Scalar>)

    public mutating func addProduct(_ a: SIMD32<Scalar>, _ b: Scalar)

    public mutating func formSquareRoot()

    public mutating func round(_ rule: FloatingPointRoundingRule)
}

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension SIMD32 where Scalar == Float16 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<Float16>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Float16)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<Float16>()
    /// for i in 0..<16 {
    ///   result[i] = lowHalf[i]
    ///   result[16+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD16<Float16>, highHalf: SIMD16<Float16>)

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] == b[i])
    /// }
    /// ```
    public static func .== (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] == b)
    /// }
    /// ```
    public static func .== (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if a is equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a == b[i])
    /// }
    /// ```
    public static func .== (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] != b[i])
    /// }
    /// ```
    public static func .!= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] != b)
    /// }
    /// ```
    public static func .!= (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if a is not equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a != b[i])
    /// }
    /// ```
    public static func .!= (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] < b[i])
    /// }
    /// ```
    public static func .< (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] < b)
    /// }
    /// ```
    public static func .< (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if a is less than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a < b[i])
    /// }
    /// ```
    public static func .< (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] <= b[i])
    /// }
    /// ```
    public static func .<= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] <= b)
    /// }
    /// ```
    public static func .<= (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if a is less than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a <= b[i])
    /// }
    /// ```
    public static func .<= (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] >= b[i])
    /// }
    /// ```
    public static func .>= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] >= b)
    /// }
    /// ```
    public static func .>= (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if a is greater than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a >= b[i])
    /// }
    /// ```
    public static func .>= (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] > b[i])
    /// }
    /// ```
    public static func .> (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] > b)
    /// }
    /// ```
    public static func .> (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if a is greater than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a > b[i])
    /// }
    /// ```
    public static func .> (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>
}

extension SIMD32 where Scalar == Float {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<Float>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Float)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<Float>()
    /// for i in 0..<16 {
    ///   result[i] = lowHalf[i]
    ///   result[16+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD16<Float>, highHalf: SIMD16<Float>)

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] == b[i])
    /// }
    /// ```
    public static func .== (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] == b)
    /// }
    /// ```
    public static func .== (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if a is equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a == b[i])
    /// }
    /// ```
    public static func .== (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] != b[i])
    /// }
    /// ```
    public static func .!= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] != b)
    /// }
    /// ```
    public static func .!= (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if a is not equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a != b[i])
    /// }
    /// ```
    public static func .!= (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] < b[i])
    /// }
    /// ```
    public static func .< (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] < b)
    /// }
    /// ```
    public static func .< (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if a is less than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a < b[i])
    /// }
    /// ```
    public static func .< (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] <= b[i])
    /// }
    /// ```
    public static func .<= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] <= b)
    /// }
    /// ```
    public static func .<= (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if a is less than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a <= b[i])
    /// }
    /// ```
    public static func .<= (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] >= b[i])
    /// }
    /// ```
    public static func .>= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] >= b)
    /// }
    /// ```
    public static func .>= (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if a is greater than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a >= b[i])
    /// }
    /// ```
    public static func .>= (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] > b[i])
    /// }
    /// ```
    public static func .> (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] > b)
    /// }
    /// ```
    public static func .> (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if a is greater than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a > b[i])
    /// }
    /// ```
    public static func .> (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>
}

extension SIMD32 where Scalar == Double {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<Double>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Double)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<Double>()
    /// for i in 0..<16 {
    ///   result[i] = lowHalf[i]
    ///   result[16+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD16<Double>, highHalf: SIMD16<Double>)

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] == b[i])
    /// }
    /// ```
    public static func .== (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] == b)
    /// }
    /// ```
    public static func .== (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if a is equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a == b[i])
    /// }
    /// ```
    public static func .== (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] != b[i])
    /// }
    /// ```
    public static func .!= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] != b)
    /// }
    /// ```
    public static func .!= (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if a is not equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a != b[i])
    /// }
    /// ```
    public static func .!= (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] < b[i])
    /// }
    /// ```
    public static func .< (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] < b)
    /// }
    /// ```
    public static func .< (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if a is less than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a < b[i])
    /// }
    /// ```
    public static func .< (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] <= b[i])
    /// }
    /// ```
    public static func .<= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] <= b)
    /// }
    /// ```
    public static func .<= (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if a is less than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a <= b[i])
    /// }
    /// ```
    public static func .<= (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] >= b[i])
    /// }
    /// ```
    public static func .>= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] >= b)
    /// }
    /// ```
    public static func .>= (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if a is greater than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a >= b[i])
    /// }
    /// ```
    public static func .>= (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] > b[i])
    /// }
    /// ```
    public static func .> (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a[i] > b)
    /// }
    /// ```
    public static func .> (a: SIMD32<Scalar>, b: Scalar) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if a is greater than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<32 {
    ///   result[i] = (a > b[i])
    /// }
    /// ```
    public static func .> (a: Scalar, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>
}

extension SIMD32 where Scalar == UInt8 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<UInt8>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt8)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<UInt8>()
    /// for i in 0..<16 {
    ///   result[i] = lowHalf[i]
    ///   result[16+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD16<UInt8>, highHalf: SIMD16<UInt8>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)
}

extension SIMD32 where Scalar == Int8 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<Int8>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int8)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<Int8>()
    /// for i in 0..<16 {
    ///   result[i] = lowHalf[i]
    ///   result[16+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD16<Int8>, highHalf: SIMD16<Int8>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)
}

extension SIMD32 where Scalar == UInt16 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<UInt16>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt16)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<UInt16>()
    /// for i in 0..<16 {
    ///   result[i] = lowHalf[i]
    ///   result[16+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD16<UInt16>, highHalf: SIMD16<UInt16>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)
}

extension SIMD32 where Scalar == Int16 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<Int16>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int16)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<Int16>()
    /// for i in 0..<16 {
    ///   result[i] = lowHalf[i]
    ///   result[16+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD16<Int16>, highHalf: SIMD16<Int16>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)
}

extension SIMD32 where Scalar == UInt32 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<UInt32>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt32)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<UInt32>()
    /// for i in 0..<16 {
    ///   result[i] = lowHalf[i]
    ///   result[16+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD16<UInt32>, highHalf: SIMD16<UInt32>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)
}

extension SIMD32 where Scalar == Int32 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<Int32>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int32)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<Int32>()
    /// for i in 0..<16 {
    ///   result[i] = lowHalf[i]
    ///   result[16+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD16<Int32>, highHalf: SIMD16<Int32>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)
}

extension SIMD32 where Scalar == UInt64 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<UInt64>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt64)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<UInt64>()
    /// for i in 0..<16 {
    ///   result[i] = lowHalf[i]
    ///   result[16+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD16<UInt64>, highHalf: SIMD16<UInt64>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)
}

extension SIMD32 where Scalar == Int64 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<Int64>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int64)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<Int64>()
    /// for i in 0..<16 {
    ///   result[i] = lowHalf[i]
    ///   result[16+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD16<Int64>, highHalf: SIMD16<Int64>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)
}

extension SIMD32 where Scalar == UInt {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<UInt>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<UInt>()
    /// for i in 0..<16 {
    ///   result[i] = lowHalf[i]
    ///   result[16+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD16<UInt>, highHalf: SIMD16<UInt>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)
}

extension SIMD32 where Scalar == Int {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<Int>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD32<Int>()
    /// for i in 0..<16 {
    ///   result[i] = lowHalf[i]
    ///   result[16+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD16<Int>, highHalf: SIMD16<Int>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMD32<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD32<Scalar>, b: SIMD32<Scalar>)
}

extension SIMD32 where Scalar : BinaryFloatingPoint {

    /// Creates a new vector from the given vector of integers.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(_ other: SIMD32<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    /// Creates a new vector from the given vector of floating-point values.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(_ other: SIMD32<Other>) where Other : BinaryFloatingPoint, Other : SIMDScalar
}

/// A vector of 64 scalar values.
@frozen public struct SIMD64<Scalar> : SIMD where Scalar : SIMDScalar {

    /// The mask type resulting from pointwise comparisons of this vector type.
    public typealias MaskStorage = SIMD64<Scalar.SIMDMaskScalar>

    /// The number of scalars in the vector.
    public var scalarCount: Int { get }

    /// Creates a vector with zero in all lanes.
    public init()

    /// Accesses the scalar at the specified position.
    public subscript(index: Int) -> Scalar

    /// Creates a new vector from the given elements.
    public init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar, _ v6: Scalar, _ v7: Scalar, _ v8: Scalar, _ v9: Scalar, _ v10: Scalar, _ v11: Scalar, _ v12: Scalar, _ v13: Scalar, _ v14: Scalar, _ v15: Scalar, _ v16: Scalar, _ v17: Scalar, _ v18: Scalar, _ v19: Scalar, _ v20: Scalar, _ v21: Scalar, _ v22: Scalar, _ v23: Scalar, _ v24: Scalar, _ v25: Scalar, _ v26: Scalar, _ v27: Scalar, _ v28: Scalar, _ v29: Scalar, _ v30: Scalar, _ v31: Scalar, _ v32: Scalar, _ v33: Scalar, _ v34: Scalar, _ v35: Scalar, _ v36: Scalar, _ v37: Scalar, _ v38: Scalar, _ v39: Scalar, _ v40: Scalar, _ v41: Scalar, _ v42: Scalar, _ v43: Scalar, _ v44: Scalar, _ v45: Scalar, _ v46: Scalar, _ v47: Scalar, _ v48: Scalar, _ v49: Scalar, _ v50: Scalar, _ v51: Scalar, _ v52: Scalar, _ v53: Scalar, _ v54: Scalar, _ v55: Scalar, _ v56: Scalar, _ v57: Scalar, _ v58: Scalar, _ v59: Scalar, _ v60: Scalar, _ v61: Scalar, _ v62: Scalar, _ v63: Scalar)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<Scalar>()
    /// for i in 0..<32 {
    ///   result[i] = lowHalf[i]
    ///   result[32+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD32<Scalar>, highHalf: SIMD32<Scalar>)

    /// A half-length vector made up of the low elements of the vector.
    public var lowHalf: SIMD32<Scalar>

    /// A half-length vector made up of the high elements of the vector.
    public var highHalf: SIMD32<Scalar>

    /// A half-length vector made up of the even elements of the vector.
    public var evenHalf: SIMD32<Scalar>

    /// A half-length vector made up of the odd elements of the vector.
    public var oddHalf: SIMD32<Scalar>

    /// The type of the elements of an array literal.
    public typealias ArrayLiteralElement = Scalar

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    ///   The compiler provides an implementation for `hashValue` for you.
    public var hashValue: Int { get }

    /// Returns a Boolean value indicating whether two values are not equal.
    ///
    /// Inequality is the inverse of equality. For any values `a` and `b`, `a != b`
    /// implies that `a == b` is `false`.
    ///
    /// This is the default implementation of the not-equal-to operator (`!=`)
    /// for any type that conforms to `Equatable`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func != (lhs: SIMD64<Scalar>, rhs: SIMD64<Scalar>) -> Bool

    /// The number of scalars, or elements, in a vector of this type.
    public static var scalarCount: Int { get }

    /// The valid indices for subscripting the vector.
    public var indices: Range<Int> { get }

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating value: Scalar)

    /// Returns a Boolean value indicating whether two vectors are equal.
    public static func == (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> Bool

    /// Hashes the elements of the vector using the given hasher.
    @inlinable public func hash(into hasher: inout Hasher)

    /// Encodes the scalars of this vector into the given encoder in an unkeyed
    /// container.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new vector by decoding scalars from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws

    /// A textual description of the vector.
    public var description: String { get }

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar.SIMDMaskScalar>>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar.SIMDMaskScalar>>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMD64<Scalar>, where mask: SIMDMask<SIMD64<Scalar.SIMDMaskScalar>>)

    /// Creates a vector from the specified elements.
    ///
    /// - Parameter scalars: The elements to use in the vector. `scalars` must
    ///   have the same number of elements as the vector type.
    @inlinable public init(arrayLiteral scalars: Scalar...)

    /// Creates a vector from the given sequence.
    ///
    /// - Precondition: `scalars` must have the same number of elements as the
    ///   vector type.
    ///
    /// - Parameter scalars: The elements to use in the vector.
    @inlinable public init<S>(_ scalars: S) where S : Sequence, Scalar == S.Element

    /// Extracts the scalars at specified indices to form a SIMD2.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD2<Index>) -> SIMD2<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD3.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD3<Index>) -> SIMD3<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD4.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD4<Index>) -> SIMD4<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD8.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD8<Index>) -> SIMD8<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD16.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD16<Index>) -> SIMD16<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD32.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD32<Index>) -> SIMD32<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD64.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD64<Index>) -> SIMD64<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Returns a vector mask with the result of a pointwise equality comparison.
    public static func .== (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar.SIMDMaskScalar>>

    /// Replaces elements of this vector with `other` in the lanes where `mask`
    /// is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other }
    /// }
    /// ```
    public mutating func replace(with other: Scalar, where mask: SIMDMask<SIMD64<Scalar.SIMDMaskScalar>>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMD64<Scalar>, where mask: SIMDMask<SIMD64<Scalar.SIMDMaskScalar>>) -> SIMD64<Scalar>

    /// Returns a copy of this vector, with elements `other` in the lanes where
    /// `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other : self[i]
    /// }
    /// ```
    public func replacing(with other: Scalar, where mask: SIMDMask<SIMD64<Scalar.SIMDMaskScalar>>) -> SIMD64<Scalar>
}

extension SIMD64 : CustomDebugStringConvertible {

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

extension SIMD64 where Scalar : Comparable {

    /// Returns a vector mask with the result of a pointwise less than
    /// comparison.
    public static func .< (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar.SIMDMaskScalar>>

    /// The least element in the vector.
    public func min() -> Scalar

    /// The greatest element in the vector.
    public func max() -> Scalar

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than comparison.
    public static func .< (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than comparison.
    public static func .< (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar.SIMDMaskScalar>>

    public mutating func clamp(lowerBound: SIMD64<Scalar>, upperBound: SIMD64<Scalar>)

    public func clamped(lowerBound: SIMD64<Scalar>, upperBound: SIMD64<Scalar>) -> SIMD64<Scalar>
}

extension SIMD64 where Scalar : FixedWidthInteger {

    /// Creates a new vector from the given vector, truncating the bit patterns
    /// of the given vector's elements if necessary.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(truncatingIfNeeded other: SIMD64<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    /// Creates a new vector from the given vector, clamping the values of the
    /// given vector's elements if necessary.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(clamping other: SIMD64<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    /// Creates a new vector from the given vector, rounding the given vector's
    /// of elements using the specified rounding rule.
    ///
    /// - Parameters:
    ///   - other: The vector to convert.
    ///   - rule: The round rule to use when converting elements of `other.` The
    ///     default is `.towardZero`.
    @inlinable public init<Other>(_ other: SIMD64<Other>, rounding rule: FloatingPointRoundingRule = .towardZero) where Other : BinaryFloatingPoint, Other : SIMDScalar

    /// A vector with zero in all lanes.
    public static var zero: SIMD64<Scalar> { get }

    /// A vector with one in all lanes.
    public static var one: SIMD64<Scalar> { get }

    /// Returns a vector with random values from within the specified range in
    /// all lanes, using the given generator as a source for randomness.
    @inlinable public static func random<T>(in range: Range<Scalar>, using generator: inout T) -> SIMD64<Scalar> where T : RandomNumberGenerator

    /// Returns a vector with random values from within the specified range in
    /// all lanes.
    @inlinable public static func random(in range: Range<Scalar>) -> SIMD64<Scalar>

    /// Returns a vector with random values from within the specified range in
    /// all lanes, using the given generator as a source for randomness.
    @inlinable public static func random<T>(in range: ClosedRange<Scalar>, using generator: inout T) -> SIMD64<Scalar> where T : RandomNumberGenerator

    /// Returns a vector with random values from within the specified range in
    /// all lanes.
    @inlinable public static func random(in range: ClosedRange<Scalar>) -> SIMD64<Scalar>

    public var leadingZeroBitCount: SIMD64<Scalar> { get }

    public var trailingZeroBitCount: SIMD64<Scalar> { get }

    public var nonzeroBitCount: SIMD64<Scalar> { get }

    prefix public static func ~ (a: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func & (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func ^ (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func | (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func &<< (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func &>> (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func &+ (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func &- (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func &* (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func / (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func % (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// Returns the sum of the scalars in the vector, computed with wrapping
    /// addition.
    ///
    /// Equivalent to `indices.reduce(into: 0) { $0 &+= self[$1] }`.
    public func wrappedSum() -> Scalar

    public static func & (a: Scalar, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func ^ (a: Scalar, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func | (a: Scalar, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func &<< (a: Scalar, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func &>> (a: Scalar, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func &+ (a: Scalar, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func &- (a: Scalar, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func &* (a: Scalar, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func / (a: Scalar, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func % (a: Scalar, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func & (a: SIMD64<Scalar>, b: Scalar) -> SIMD64<Scalar>

    public static func ^ (a: SIMD64<Scalar>, b: Scalar) -> SIMD64<Scalar>

    public static func | (a: SIMD64<Scalar>, b: Scalar) -> SIMD64<Scalar>

    public static func &<< (a: SIMD64<Scalar>, b: Scalar) -> SIMD64<Scalar>

    public static func &>> (a: SIMD64<Scalar>, b: Scalar) -> SIMD64<Scalar>

    public static func &+ (a: SIMD64<Scalar>, b: Scalar) -> SIMD64<Scalar>

    public static func &- (a: SIMD64<Scalar>, b: Scalar) -> SIMD64<Scalar>

    public static func &* (a: SIMD64<Scalar>, b: Scalar) -> SIMD64<Scalar>

    public static func / (a: SIMD64<Scalar>, b: Scalar) -> SIMD64<Scalar>

    public static func % (a: SIMD64<Scalar>, b: Scalar) -> SIMD64<Scalar>

    public static func &= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    public static func ^= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    public static func |= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    public static func &<<= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    public static func &>>= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    public static func &+= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    public static func &-= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    public static func &*= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    public static func /= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    public static func %= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    public static func &= (a: inout SIMD64<Scalar>, b: Scalar)

    public static func ^= (a: inout SIMD64<Scalar>, b: Scalar)

    public static func |= (a: inout SIMD64<Scalar>, b: Scalar)

    public static func &<<= (a: inout SIMD64<Scalar>, b: Scalar)

    public static func &>>= (a: inout SIMD64<Scalar>, b: Scalar)

    public static func &+= (a: inout SIMD64<Scalar>, b: Scalar)

    public static func &-= (a: inout SIMD64<Scalar>, b: Scalar)

    public static func &*= (a: inout SIMD64<Scalar>, b: Scalar)

    public static func /= (a: inout SIMD64<Scalar>, b: Scalar)

    public static func %= (a: inout SIMD64<Scalar>, b: Scalar)
}

extension SIMD64 where Scalar : FloatingPoint {

    /// A vector with zero in all lanes.
    public static var zero: SIMD64<Scalar> { get }

    /// A vector with one in all lanes.
    public static var one: SIMD64<Scalar> { get }

    public mutating func clamp(lowerBound: SIMD64<Scalar>, upperBound: SIMD64<Scalar>)

    public func clamped(lowerBound: SIMD64<Scalar>, upperBound: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func + (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func - (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func * (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func / (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public func addingProduct(_ a: SIMD64<Scalar>, _ b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public func squareRoot() -> SIMD64<Scalar>

    /// A vector formed by rounding each lane of the source vector to an integral
    /// value according to the specified rounding `rule`.
    public func rounded(_ rule: FloatingPointRoundingRule) -> SIMD64<Scalar>

    /// The least scalar in the vector.
    public func min() -> Scalar

    /// The greatest scalar in the vector.
    public func max() -> Scalar

    /// The sum of the scalars in the vector.
    public func sum() -> Scalar

    prefix public static func - (a: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func + (a: Scalar, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func - (a: Scalar, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func * (a: Scalar, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func / (a: Scalar, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public static func + (a: SIMD64<Scalar>, b: Scalar) -> SIMD64<Scalar>

    public static func - (a: SIMD64<Scalar>, b: Scalar) -> SIMD64<Scalar>

    public static func * (a: SIMD64<Scalar>, b: Scalar) -> SIMD64<Scalar>

    public static func / (a: SIMD64<Scalar>, b: Scalar) -> SIMD64<Scalar>

    public static func += (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    public static func -= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    public static func *= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    public static func /= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    public static func += (a: inout SIMD64<Scalar>, b: Scalar)

    public static func -= (a: inout SIMD64<Scalar>, b: Scalar)

    public static func *= (a: inout SIMD64<Scalar>, b: Scalar)

    public static func /= (a: inout SIMD64<Scalar>, b: Scalar)

    public func addingProduct(_ a: Scalar, _ b: SIMD64<Scalar>) -> SIMD64<Scalar>

    public func addingProduct(_ a: SIMD64<Scalar>, _ b: Scalar) -> SIMD64<Scalar>

    public mutating func addProduct(_ a: SIMD64<Scalar>, _ b: SIMD64<Scalar>)

    public mutating func addProduct(_ a: Scalar, _ b: SIMD64<Scalar>)

    public mutating func addProduct(_ a: SIMD64<Scalar>, _ b: Scalar)

    public mutating func formSquareRoot()

    public mutating func round(_ rule: FloatingPointRoundingRule)
}

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension SIMD64 where Scalar == Float16 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<Float16>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Float16)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<Float16>()
    /// for i in 0..<32 {
    ///   result[i] = lowHalf[i]
    ///   result[32+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD32<Float16>, highHalf: SIMD32<Float16>)

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] == b[i])
    /// }
    /// ```
    public static func .== (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] == b)
    /// }
    /// ```
    public static func .== (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if a is equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a == b[i])
    /// }
    /// ```
    public static func .== (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] != b[i])
    /// }
    /// ```
    public static func .!= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] != b)
    /// }
    /// ```
    public static func .!= (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if a is not equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a != b[i])
    /// }
    /// ```
    public static func .!= (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] < b[i])
    /// }
    /// ```
    public static func .< (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] < b)
    /// }
    /// ```
    public static func .< (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if a is less than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a < b[i])
    /// }
    /// ```
    public static func .< (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] <= b[i])
    /// }
    /// ```
    public static func .<= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] <= b)
    /// }
    /// ```
    public static func .<= (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if a is less than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a <= b[i])
    /// }
    /// ```
    public static func .<= (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] >= b[i])
    /// }
    /// ```
    public static func .>= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] >= b)
    /// }
    /// ```
    public static func .>= (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if a is greater than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a >= b[i])
    /// }
    /// ```
    public static func .>= (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] > b[i])
    /// }
    /// ```
    public static func .> (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] > b)
    /// }
    /// ```
    public static func .> (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if a is greater than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a > b[i])
    /// }
    /// ```
    public static func .> (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>
}

extension SIMD64 where Scalar == Float {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<Float>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Float)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<Float>()
    /// for i in 0..<32 {
    ///   result[i] = lowHalf[i]
    ///   result[32+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD32<Float>, highHalf: SIMD32<Float>)

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] == b[i])
    /// }
    /// ```
    public static func .== (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] == b)
    /// }
    /// ```
    public static func .== (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if a is equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a == b[i])
    /// }
    /// ```
    public static func .== (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] != b[i])
    /// }
    /// ```
    public static func .!= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] != b)
    /// }
    /// ```
    public static func .!= (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if a is not equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a != b[i])
    /// }
    /// ```
    public static func .!= (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] < b[i])
    /// }
    /// ```
    public static func .< (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] < b)
    /// }
    /// ```
    public static func .< (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if a is less than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a < b[i])
    /// }
    /// ```
    public static func .< (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] <= b[i])
    /// }
    /// ```
    public static func .<= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] <= b)
    /// }
    /// ```
    public static func .<= (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if a is less than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a <= b[i])
    /// }
    /// ```
    public static func .<= (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] >= b[i])
    /// }
    /// ```
    public static func .>= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] >= b)
    /// }
    /// ```
    public static func .>= (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if a is greater than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a >= b[i])
    /// }
    /// ```
    public static func .>= (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] > b[i])
    /// }
    /// ```
    public static func .> (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] > b)
    /// }
    /// ```
    public static func .> (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if a is greater than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a > b[i])
    /// }
    /// ```
    public static func .> (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>
}

extension SIMD64 where Scalar == Double {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<Double>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Double)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<Double>()
    /// for i in 0..<32 {
    ///   result[i] = lowHalf[i]
    ///   result[32+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD32<Double>, highHalf: SIMD32<Double>)

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] == b[i])
    /// }
    /// ```
    public static func .== (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] == b)
    /// }
    /// ```
    public static func .== (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if a is equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a == b[i])
    /// }
    /// ```
    public static func .== (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] != b[i])
    /// }
    /// ```
    public static func .!= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] != b)
    /// }
    /// ```
    public static func .!= (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if a is not equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a != b[i])
    /// }
    /// ```
    public static func .!= (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] < b[i])
    /// }
    /// ```
    public static func .< (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] < b)
    /// }
    /// ```
    public static func .< (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if a is less than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a < b[i])
    /// }
    /// ```
    public static func .< (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] <= b[i])
    /// }
    /// ```
    public static func .<= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] <= b)
    /// }
    /// ```
    public static func .<= (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if a is less than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a <= b[i])
    /// }
    /// ```
    public static func .<= (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] >= b[i])
    /// }
    /// ```
    public static func .>= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] >= b)
    /// }
    /// ```
    public static func .>= (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if a is greater than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a >= b[i])
    /// }
    /// ```
    public static func .>= (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] > b[i])
    /// }
    /// ```
    public static func .> (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a[i] > b)
    /// }
    /// ```
    public static func .> (a: SIMD64<Scalar>, b: Scalar) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if a is greater than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<64 {
    ///   result[i] = (a > b[i])
    /// }
    /// ```
    public static func .> (a: Scalar, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>
}

extension SIMD64 where Scalar == UInt8 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<UInt8>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt8)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<UInt8>()
    /// for i in 0..<32 {
    ///   result[i] = lowHalf[i]
    ///   result[32+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD32<UInt8>, highHalf: SIMD32<UInt8>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)
}

extension SIMD64 where Scalar == Int8 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<Int8>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int8)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<Int8>()
    /// for i in 0..<32 {
    ///   result[i] = lowHalf[i]
    ///   result[32+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD32<Int8>, highHalf: SIMD32<Int8>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)
}

extension SIMD64 where Scalar == UInt16 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<UInt16>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt16)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<UInt16>()
    /// for i in 0..<32 {
    ///   result[i] = lowHalf[i]
    ///   result[32+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD32<UInt16>, highHalf: SIMD32<UInt16>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)
}

extension SIMD64 where Scalar == Int16 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<Int16>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int16)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<Int16>()
    /// for i in 0..<32 {
    ///   result[i] = lowHalf[i]
    ///   result[32+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD32<Int16>, highHalf: SIMD32<Int16>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)
}

extension SIMD64 where Scalar == UInt32 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<UInt32>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt32)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<UInt32>()
    /// for i in 0..<32 {
    ///   result[i] = lowHalf[i]
    ///   result[32+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD32<UInt32>, highHalf: SIMD32<UInt32>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)
}

extension SIMD64 where Scalar == Int32 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<Int32>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int32)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<Int32>()
    /// for i in 0..<32 {
    ///   result[i] = lowHalf[i]
    ///   result[32+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD32<Int32>, highHalf: SIMD32<Int32>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)
}

extension SIMD64 where Scalar == UInt64 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<UInt64>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt64)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<UInt64>()
    /// for i in 0..<32 {
    ///   result[i] = lowHalf[i]
    ///   result[32+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD32<UInt64>, highHalf: SIMD32<UInt64>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)
}

extension SIMD64 where Scalar == Int64 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<Int64>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int64)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<Int64>()
    /// for i in 0..<32 {
    ///   result[i] = lowHalf[i]
    ///   result[32+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD32<Int64>, highHalf: SIMD32<Int64>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)
}

extension SIMD64 where Scalar == UInt {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<UInt>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<UInt>()
    /// for i in 0..<32 {
    ///   result[i] = lowHalf[i]
    ///   result[32+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD32<UInt>, highHalf: SIMD32<UInt>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)
}

extension SIMD64 where Scalar == Int {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<Int>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int)

    /// A vector formed by concatenating lowHalf and highHalf.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD64<Int>()
    /// for i in 0..<32 {
    ///   result[i] = lowHalf[i]
    ///   result[32+i] = highHalf[i]
    /// }
    /// ```
    public init(lowHalf: SIMD32<Int>, highHalf: SIMD32<Int>)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMDMask<SIMD64<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD64<Scalar>, b: SIMD64<Scalar>) -> SIMD64<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD64<Scalar>, b: SIMD64<Scalar>)
}

extension SIMD64 where Scalar : BinaryFloatingPoint {

    /// Creates a new vector from the given vector of integers.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(_ other: SIMD64<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    /// Creates a new vector from the given vector of floating-point values.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(_ other: SIMD64<Other>) where Other : BinaryFloatingPoint, Other : SIMDScalar
}

/// A vector of three scalar values.
@frozen public struct SIMD3<Scalar> : SIMD where Scalar : SIMDScalar {

    /// The mask type resulting from pointwise comparisons of this vector type.
    public typealias MaskStorage = SIMD3<Scalar.SIMDMaskScalar>

    /// The number of scalars in the vector.
    public var scalarCount: Int { get }

    /// Creates a vector with zero in all lanes.
    public init()

    /// Accesses the scalar at the specified position.
    public subscript(index: Int) -> Scalar

    /// Creates a new vector from the given elements.
    public init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar)

    /// Creates a new vector from the given elements.
    ///
    /// - Parameters:
    ///   - x: The first element of the vector.
    ///   - y: The second element of the vector.
    ///   - z: The third element of the vector.
    public init(x: Scalar, y: Scalar, z: Scalar)

    /// The first element of the vector.
    public var x: Scalar

    /// The second element of the vector.
    public var y: Scalar

    /// The third element of the vector.
    public var z: Scalar

    /// The type of the elements of an array literal.
    public typealias ArrayLiteralElement = Scalar

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    ///   The compiler provides an implementation for `hashValue` for you.
    public var hashValue: Int { get }

    /// A three-element vector created by appending a scalar to a two-element vector.
    public init(_ xy: SIMD2<Scalar>, _ z: Scalar)

    /// Returns a Boolean value indicating whether two values are not equal.
    ///
    /// Inequality is the inverse of equality. For any values `a` and `b`, `a != b`
    /// implies that `a == b` is `false`.
    ///
    /// This is the default implementation of the not-equal-to operator (`!=`)
    /// for any type that conforms to `Equatable`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func != (lhs: SIMD3<Scalar>, rhs: SIMD3<Scalar>) -> Bool

    /// The number of scalars, or elements, in a vector of this type.
    public static var scalarCount: Int { get }

    /// The valid indices for subscripting the vector.
    public var indices: Range<Int> { get }

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating value: Scalar)

    /// Returns a Boolean value indicating whether two vectors are equal.
    public static func == (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> Bool

    /// Hashes the elements of the vector using the given hasher.
    @inlinable public func hash(into hasher: inout Hasher)

    /// Encodes the scalars of this vector into the given encoder in an unkeyed
    /// container.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new vector by decoding scalars from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws

    /// A textual description of the vector.
    public var description: String { get }

    /// A vector mask with the result of a pointwise equality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in result.indices {
    ///   result[i] = a[i] == b[i]
    /// }
    /// ```
    public static func .== (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar.SIMDMaskScalar>>

    /// A vector mask with the result of a pointwise inequality comparison.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in result.indices {
    ///   result[i] = a[i] != b[i]
    /// }
    /// ```
    public static func .!= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar.SIMDMaskScalar>>

    /// Replaces elements of this vector with elements of `other` in the lanes
    /// where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other[i] }
    /// }
    /// ```
    public mutating func replace(with other: SIMD3<Scalar>, where mask: SIMDMask<SIMD3<Scalar.SIMDMaskScalar>>)

    /// Creates a vector from the specified elements.
    ///
    /// - Parameter scalars: The elements to use in the vector. `scalars` must
    ///   have the same number of elements as the vector type.
    @inlinable public init(arrayLiteral scalars: Scalar...)

    /// Creates a vector from the given sequence.
    ///
    /// - Precondition: `scalars` must have the same number of elements as the
    ///   vector type.
    ///
    /// - Parameter scalars: The elements to use in the vector.
    @inlinable public init<S>(_ scalars: S) where S : Sequence, Scalar == S.Element

    /// Extracts the scalars at specified indices to form a SIMD2.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD2<Index>) -> SIMD2<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD3.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD3<Index>) -> SIMD3<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD4.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD4<Index>) -> SIMD4<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD8.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD8<Index>) -> SIMD8<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD16.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD16<Index>) -> SIMD16<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD32.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD32<Index>) -> SIMD32<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Extracts the scalars at specified indices to form a SIMD64.
    ///
    /// The elements of the index vector are wrapped modulo the count of elements
    /// in this vector. Because of this, the index is always in-range and no trap
    /// can occur.
    public subscript<Index>(index: SIMD64<Index>) -> SIMD64<Scalar> where Index : FixedWidthInteger, Index : SIMDScalar, Scalar : SIMDScalar { get }

    /// Returns a vector mask with the result of a pointwise equality comparison.
    public static func .== (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar.SIMDMaskScalar>>

    /// Replaces elements of this vector with `other` in the lanes where `mask`
    /// is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// for i in indices {
    ///   if mask[i] { self[i] = other }
    /// }
    /// ```
    public mutating func replace(with other: Scalar, where mask: SIMDMask<SIMD3<Scalar.SIMDMaskScalar>>)

    /// Returns a copy of this vector, with elements replaced by elements of
    /// `other` in the lanes where `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other[i] : self[i]
    /// }
    /// ```
    public func replacing(with other: SIMD3<Scalar>, where mask: SIMDMask<SIMD3<Scalar.SIMDMaskScalar>>) -> SIMD3<Scalar>

    /// Returns a copy of this vector, with elements `other` in the lanes where
    /// `mask` is `true`.
    ///
    /// Equivalent to:
    /// ```
    /// var result = Self()
    /// for i in indices {
    ///   result[i] = mask[i] ? other : self[i]
    /// }
    /// ```
    public func replacing(with other: Scalar, where mask: SIMDMask<SIMD3<Scalar.SIMDMaskScalar>>) -> SIMD3<Scalar>
}

extension SIMD3 : CustomDebugStringConvertible {

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

extension SIMD3 where Scalar : Comparable {

    /// Returns a vector mask with the result of a pointwise less than
    /// comparison.
    public static func .< (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar.SIMDMaskScalar>>

    /// The least element in the vector.
    public func min() -> Scalar

    /// The greatest element in the vector.
    public func max() -> Scalar

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than comparison.
    public static func .< (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than comparison.
    public static func .< (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise less than or equal
    /// comparison.
    public static func .<= (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than or
    /// equal comparison.
    public static func .>= (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar.SIMDMaskScalar>>

    /// Returns a vector mask with the result of a pointwise greater than
    /// comparison.
    public static func .> (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar.SIMDMaskScalar>>

    public mutating func clamp(lowerBound: SIMD3<Scalar>, upperBound: SIMD3<Scalar>)

    public func clamped(lowerBound: SIMD3<Scalar>, upperBound: SIMD3<Scalar>) -> SIMD3<Scalar>
}

extension SIMD3 where Scalar : FixedWidthInteger {

    /// Creates a new vector from the given vector, truncating the bit patterns
    /// of the given vector's elements if necessary.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(truncatingIfNeeded other: SIMD3<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    /// Creates a new vector from the given vector, clamping the values of the
    /// given vector's elements if necessary.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(clamping other: SIMD3<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    /// Creates a new vector from the given vector, rounding the given vector's
    /// of elements using the specified rounding rule.
    ///
    /// - Parameters:
    ///   - other: The vector to convert.
    ///   - rule: The round rule to use when converting elements of `other.` The
    ///     default is `.towardZero`.
    @inlinable public init<Other>(_ other: SIMD3<Other>, rounding rule: FloatingPointRoundingRule = .towardZero) where Other : BinaryFloatingPoint, Other : SIMDScalar

    /// A vector with zero in all lanes.
    public static var zero: SIMD3<Scalar> { get }

    /// A vector with one in all lanes.
    public static var one: SIMD3<Scalar> { get }

    /// Returns a vector with random values from within the specified range in
    /// all lanes, using the given generator as a source for randomness.
    @inlinable public static func random<T>(in range: Range<Scalar>, using generator: inout T) -> SIMD3<Scalar> where T : RandomNumberGenerator

    /// Returns a vector with random values from within the specified range in
    /// all lanes.
    @inlinable public static func random(in range: Range<Scalar>) -> SIMD3<Scalar>

    /// Returns a vector with random values from within the specified range in
    /// all lanes, using the given generator as a source for randomness.
    @inlinable public static func random<T>(in range: ClosedRange<Scalar>, using generator: inout T) -> SIMD3<Scalar> where T : RandomNumberGenerator

    /// Returns a vector with random values from within the specified range in
    /// all lanes.
    @inlinable public static func random(in range: ClosedRange<Scalar>) -> SIMD3<Scalar>

    public var leadingZeroBitCount: SIMD3<Scalar> { get }

    public var trailingZeroBitCount: SIMD3<Scalar> { get }

    public var nonzeroBitCount: SIMD3<Scalar> { get }

    prefix public static func ~ (a: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func & (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func ^ (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func | (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func &<< (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func &>> (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func &+ (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func &- (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func &* (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func / (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func % (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// Returns the sum of the scalars in the vector, computed with wrapping
    /// addition.
    ///
    /// Equivalent to `indices.reduce(into: 0) { $0 &+= self[$1] }`.
    public func wrappedSum() -> Scalar

    public static func & (a: Scalar, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func ^ (a: Scalar, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func | (a: Scalar, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func &<< (a: Scalar, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func &>> (a: Scalar, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func &+ (a: Scalar, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func &- (a: Scalar, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func &* (a: Scalar, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func / (a: Scalar, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func % (a: Scalar, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func & (a: SIMD3<Scalar>, b: Scalar) -> SIMD3<Scalar>

    public static func ^ (a: SIMD3<Scalar>, b: Scalar) -> SIMD3<Scalar>

    public static func | (a: SIMD3<Scalar>, b: Scalar) -> SIMD3<Scalar>

    public static func &<< (a: SIMD3<Scalar>, b: Scalar) -> SIMD3<Scalar>

    public static func &>> (a: SIMD3<Scalar>, b: Scalar) -> SIMD3<Scalar>

    public static func &+ (a: SIMD3<Scalar>, b: Scalar) -> SIMD3<Scalar>

    public static func &- (a: SIMD3<Scalar>, b: Scalar) -> SIMD3<Scalar>

    public static func &* (a: SIMD3<Scalar>, b: Scalar) -> SIMD3<Scalar>

    public static func / (a: SIMD3<Scalar>, b: Scalar) -> SIMD3<Scalar>

    public static func % (a: SIMD3<Scalar>, b: Scalar) -> SIMD3<Scalar>

    public static func &= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    public static func ^= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    public static func |= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    public static func &<<= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    public static func &>>= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    public static func &+= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    public static func &-= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    public static func &*= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    public static func /= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    public static func %= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    public static func &= (a: inout SIMD3<Scalar>, b: Scalar)

    public static func ^= (a: inout SIMD3<Scalar>, b: Scalar)

    public static func |= (a: inout SIMD3<Scalar>, b: Scalar)

    public static func &<<= (a: inout SIMD3<Scalar>, b: Scalar)

    public static func &>>= (a: inout SIMD3<Scalar>, b: Scalar)

    public static func &+= (a: inout SIMD3<Scalar>, b: Scalar)

    public static func &-= (a: inout SIMD3<Scalar>, b: Scalar)

    public static func &*= (a: inout SIMD3<Scalar>, b: Scalar)

    public static func /= (a: inout SIMD3<Scalar>, b: Scalar)

    public static func %= (a: inout SIMD3<Scalar>, b: Scalar)
}

extension SIMD3 where Scalar : FloatingPoint {

    /// A vector with zero in all lanes.
    public static var zero: SIMD3<Scalar> { get }

    /// A vector with one in all lanes.
    public static var one: SIMD3<Scalar> { get }

    public mutating func clamp(lowerBound: SIMD3<Scalar>, upperBound: SIMD3<Scalar>)

    public func clamped(lowerBound: SIMD3<Scalar>, upperBound: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func + (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func - (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func * (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func / (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public func addingProduct(_ a: SIMD3<Scalar>, _ b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public func squareRoot() -> SIMD3<Scalar>

    /// A vector formed by rounding each lane of the source vector to an integral
    /// value according to the specified rounding `rule`.
    public func rounded(_ rule: FloatingPointRoundingRule) -> SIMD3<Scalar>

    /// The least scalar in the vector.
    public func min() -> Scalar

    /// The greatest scalar in the vector.
    public func max() -> Scalar

    /// The sum of the scalars in the vector.
    public func sum() -> Scalar

    prefix public static func - (a: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func + (a: Scalar, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func - (a: Scalar, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func * (a: Scalar, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func / (a: Scalar, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public static func + (a: SIMD3<Scalar>, b: Scalar) -> SIMD3<Scalar>

    public static func - (a: SIMD3<Scalar>, b: Scalar) -> SIMD3<Scalar>

    public static func * (a: SIMD3<Scalar>, b: Scalar) -> SIMD3<Scalar>

    public static func / (a: SIMD3<Scalar>, b: Scalar) -> SIMD3<Scalar>

    public static func += (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    public static func -= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    public static func *= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    public static func /= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    public static func += (a: inout SIMD3<Scalar>, b: Scalar)

    public static func -= (a: inout SIMD3<Scalar>, b: Scalar)

    public static func *= (a: inout SIMD3<Scalar>, b: Scalar)

    public static func /= (a: inout SIMD3<Scalar>, b: Scalar)

    public func addingProduct(_ a: Scalar, _ b: SIMD3<Scalar>) -> SIMD3<Scalar>

    public func addingProduct(_ a: SIMD3<Scalar>, _ b: Scalar) -> SIMD3<Scalar>

    public mutating func addProduct(_ a: SIMD3<Scalar>, _ b: SIMD3<Scalar>)

    public mutating func addProduct(_ a: Scalar, _ b: SIMD3<Scalar>)

    public mutating func addProduct(_ a: SIMD3<Scalar>, _ b: Scalar)

    public mutating func formSquareRoot()

    public mutating func round(_ rule: FloatingPointRoundingRule)
}

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension SIMD3 where Scalar == Float16 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD3<Float16>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Float16)

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] == b[i])
    /// }
    /// ```
    public static func .== (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] == b)
    /// }
    /// ```
    public static func .== (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if a is equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a == b[i])
    /// }
    /// ```
    public static func .== (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] != b[i])
    /// }
    /// ```
    public static func .!= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] != b)
    /// }
    /// ```
    public static func .!= (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if a is not equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a != b[i])
    /// }
    /// ```
    public static func .!= (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] < b[i])
    /// }
    /// ```
    public static func .< (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] < b)
    /// }
    /// ```
    public static func .< (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if a is less than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a < b[i])
    /// }
    /// ```
    public static func .< (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] <= b[i])
    /// }
    /// ```
    public static func .<= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] <= b)
    /// }
    /// ```
    public static func .<= (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if a is less than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a <= b[i])
    /// }
    /// ```
    public static func .<= (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] >= b[i])
    /// }
    /// ```
    public static func .>= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] >= b)
    /// }
    /// ```
    public static func .>= (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if a is greater than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a >= b[i])
    /// }
    /// ```
    public static func .>= (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] > b[i])
    /// }
    /// ```
    public static func .> (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] > b)
    /// }
    /// ```
    public static func .> (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if a is greater than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a > b[i])
    /// }
    /// ```
    public static func .> (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>
}

extension SIMD3 where Scalar == Float {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD3<Float>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Float)

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] == b[i])
    /// }
    /// ```
    public static func .== (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] == b)
    /// }
    /// ```
    public static func .== (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if a is equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a == b[i])
    /// }
    /// ```
    public static func .== (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] != b[i])
    /// }
    /// ```
    public static func .!= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] != b)
    /// }
    /// ```
    public static func .!= (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if a is not equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a != b[i])
    /// }
    /// ```
    public static func .!= (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] < b[i])
    /// }
    /// ```
    public static func .< (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] < b)
    /// }
    /// ```
    public static func .< (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if a is less than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a < b[i])
    /// }
    /// ```
    public static func .< (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] <= b[i])
    /// }
    /// ```
    public static func .<= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] <= b)
    /// }
    /// ```
    public static func .<= (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if a is less than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a <= b[i])
    /// }
    /// ```
    public static func .<= (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] >= b[i])
    /// }
    /// ```
    public static func .>= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] >= b)
    /// }
    /// ```
    public static func .>= (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if a is greater than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a >= b[i])
    /// }
    /// ```
    public static func .>= (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] > b[i])
    /// }
    /// ```
    public static func .> (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] > b)
    /// }
    /// ```
    public static func .> (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if a is greater than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a > b[i])
    /// }
    /// ```
    public static func .> (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>
}

extension SIMD3 where Scalar == Double {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD3<Double>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Double)

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] == b[i])
    /// }
    /// ```
    public static func .== (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if that lane of a is equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] == b)
    /// }
    /// ```
    public static func .== (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare equal to.
    ///
    /// Each lane of the result is true if a is equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a == b[i])
    /// }
    /// ```
    public static func .== (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] != b[i])
    /// }
    /// ```
    public static func .!= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if that lane of a is not equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] != b)
    /// }
    /// ```
    public static func .!= (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare not equal to.
    ///
    /// Each lane of the result is true if a is not equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a != b[i])
    /// }
    /// ```
    public static func .!= (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] < b[i])
    /// }
    /// ```
    public static func .< (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if that lane of a is less than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] < b)
    /// }
    /// ```
    public static func .< (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare less than.
    ///
    /// Each lane of the result is true if a is less than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a < b[i])
    /// }
    /// ```
    public static func .< (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] <= b[i])
    /// }
    /// ```
    public static func .<= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is less than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] <= b)
    /// }
    /// ```
    public static func .<= (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare less than or equal to.
    ///
    /// Each lane of the result is true if a is less than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a <= b[i])
    /// }
    /// ```
    public static func .<= (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] >= b[i])
    /// }
    /// ```
    public static func .>= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if that lane of a is greater than or equal to b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] >= b)
    /// }
    /// ```
    public static func .>= (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare greater than or equal to.
    ///
    /// Each lane of the result is true if a is greater than or equal to the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a >= b[i])
    /// }
    /// ```
    public static func .>= (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than the
    /// corresponding lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] > b[i])
    /// }
    /// ```
    public static func .> (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if that lane of a is greater than b,
    /// and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a[i] > b)
    /// }
    /// ```
    public static func .> (a: SIMD3<Scalar>, b: Scalar) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// Pointwise compare greater than.
    ///
    /// Each lane of the result is true if a is greater than the corresponding
    /// lane of b, and false otherwise.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMDMask<MaskStorage>()
    /// for i in 0..<3 {
    ///   result[i] = (a > b[i])
    /// }
    /// ```
    public static func .> (a: Scalar, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>
}

extension SIMD3 where Scalar == UInt8 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD3<UInt8>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt8)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)
}

extension SIMD3 where Scalar == Int8 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD3<Int8>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int8)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)
}

extension SIMD3 where Scalar == UInt16 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD3<UInt16>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt16)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)
}

extension SIMD3 where Scalar == Int16 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD3<Int16>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int16)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)
}

extension SIMD3 where Scalar == UInt32 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD3<UInt32>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt32)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)
}

extension SIMD3 where Scalar == Int32 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD3<Int32>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int32)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)
}

extension SIMD3 where Scalar == UInt64 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD3<UInt64>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt64)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)
}

extension SIMD3 where Scalar == Int64 {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD3<Int64>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int64)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)
}

extension SIMD3 where Scalar == UInt {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD3<UInt>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: UInt)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)
}

extension SIMD3 where Scalar == Int {

    /// A vector with the specified scalar in all lanes.
    ///
    /// Equivalent to:
    /// ```
    /// var result = SIMD3<Int>()
    /// for i in result.indices {
    ///   result[i] = scalar
    /// }
    /// ```
    public init(repeating scalar: Int)

    /// A vector mask with the result of a pointwise equality comparison.
    public static func .== (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise inequality comparison.
    public static func .!= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than comparison.
    public static func .< (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise less-than-or-equal-to comparison.
    public static func .<= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than comparison.
    public static func .> (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// A vector mask with the result of a pointwise greater-than-or-equal-to comparison.
    public static func .>= (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMDMask<SIMD3<Scalar>.MaskStorage>

    /// The wrapping sum of two vectors.
    public static func &+ (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// The wrapping difference of two vectors.
    public static func &- (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// The pointwise wrapping product of two vectors.
    public static func &* (a: SIMD3<Scalar>, b: SIMD3<Scalar>) -> SIMD3<Scalar>

    /// Updates the left hand side with the wrapping sum of the two
    /// vectors.
    public static func &+= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    /// Updates the left hand side with the wrapping difference of the two
    /// vectors.
    public static func &-= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)

    /// Updates the left hand side with the pointwise wrapping product of two
    /// vectors.
    public static func &*= (a: inout SIMD3<Scalar>, b: SIMD3<Scalar>)
}

extension SIMD3 where Scalar : BinaryFloatingPoint {

    /// Creates a new vector from the given vector of integers.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(_ other: SIMD3<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    /// Creates a new vector from the given vector of floating-point values.
    ///
    /// - Parameter other: The vector to convert.
    @inlinable public init<Other>(_ other: SIMD3<Other>) where Other : BinaryFloatingPoint, Other : SIMDScalar
}

