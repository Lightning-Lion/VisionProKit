import CoreVideo

public var COREIMAGE_SUPPORTS_OPENGLES: Int32 { get }

/// The Core Image context class provides an evaluation context for Core Image processing with Metal, OpenGL, or OpenCL.
/// 
/// You use a `CIContext` instance to render a ``CIImage`` instance which represents a graph of image processing operations
/// which are built using other Core Image classes, such as ``CIFilter-class``, ``CIKernel``, ``CIColor`` and ``CIImage``. 
/// You can also use a `CIContext` with the ``CIDetector`` class to analyze images — for example, to detect faces 
/// or barcodes.
/// 
/// Contexts support automatic color management by performing all processing operations in a working color space.
/// This means that unless told otherwise:
/// * All input images are color matched from the input's color space to the working space.
/// * All renders are color matched from the working space to the destination space.
/// (For more information on `CGColorSpace` see <doc://com.apple.documentation/documentation/coregraphics/cgcolorspace>)
/// 
/// `CIContext` and ``CIImage`` instances are immutable, so multiple threads can use the same ``CIContext`` instance 
/// to render ``CIImage`` instances. However, ``CIFilter-class`` instances are mutable and thus cannot be shared safely among 
/// threads. Each thread must take case not to access or modify a ``CIFilter-class`` instance while it is being used by 
/// another thread.
/// 
/// The `CIContext` manages various internal state such as `MTLCommandQueue` and caches for compiled kernels
/// and intermediate buffers.  For this reason it is not recommended to create many `CIContext` instances.  As a rule,
/// it recommended that you create one `CIContext` instance for each view that renders ``CIImage`` or each background task.
///
@available(visionOS 1.0, *)
open class CIContext : NSObject, @unchecked Sendable {

    @available(visionOS 1.0, *)
    public /*not inherited*/ init(cgContext cgctx: CGContext, options: [CIContextOption : Any]? = nil)

    @available(visionOS 1.0, *)
    public init(options: [CIContextOption : Any]? = nil)

    @available(visionOS 1.0, *)
    public init()

    @available(visionOS 1.0, *)
    public /*not inherited*/ init(mtlDevice device: any MTLDevice)

    @available(visionOS 1.0, *)
    public /*not inherited*/ init(mtlDevice device: any MTLDevice, options: [CIContextOption : Any]? = nil)

    @available(visionOS 1.0, *)
    public /*not inherited*/ init(mtlCommandQueue commandQueue: any MTLCommandQueue)

    @available(visionOS 1.0, *)
    public /*not inherited*/ init(mtlCommandQueue commandQueue: any MTLCommandQueue, options: [CIContextOption : Any]? = nil)

    /// The working color space of the CIContext.
    /// 
    /// The working color space determines the color space used when executing filter kernels. 
    /// You specify a working color space using the ``kCIContextWorkingColorSpace`` option when creating a ``CIContext``.
    /// * All input images are color matched from the input's color space to the working space.
    /// * All renders are color matched from the working space to the destination space.
    ///
    /// The property will be `null` if the context was created with color management disabled.
    ///
    @available(visionOS 1.0, *)
    open var workingColorSpace: CGColorSpace? { get }

    /// The working pixel format that the CIContext uses for intermediate buffers.
    /// 
    /// The working format determines the pixel format that Core Image uses to create intermediate buffers for rendering images. 
    /// You specify a working pixel format using the ``kCIContextWorkingFormat`` option when creating a ``CIContext``.
    ///
    @available(visionOS 1.0, *)
    open var workingFormat: CIFormat { get }

    @available(visionOS, introduced: 1.0, deprecated: 1.0)
    open func draw(_ image: CIImage, at atPoint: CGPoint, from fromRect: CGRect)

    open func draw(_ image: CIImage, in inRect: CGRect, from fromRect: CGRect)

    open func render(_ image: CIImage, toBitmap data: UnsafeMutableRawPointer, rowBytes: Int, bounds: CGRect, format: CIFormat, colorSpace: CGColorSpace?)

    @available(visionOS 1.0, *)
    open func render(_ image: CIImage, to surface: IOSurfaceRef, bounds: CGRect, colorSpace: CGColorSpace?)

    @available(visionOS 1.0, *)
    open func render(_ image: CIImage, to buffer: CVPixelBuffer)

    @available(visionOS 1.0, *)
    open func render(_ image: CIImage, to buffer: CVPixelBuffer, bounds: CGRect, colorSpace: CGColorSpace?)

    @available(visionOS 1.0, *)
    open func render(_ image: CIImage, to texture: any MTLTexture, commandBuffer: (any MTLCommandBuffer)?, bounds: CGRect, colorSpace: CGColorSpace)

    @available(visionOS 1.0, *)
    open func clearCaches()

    @available(visionOS 1.0, *)
    open func inputImageMaximumSize() -> CGSize

    @available(visionOS 1.0, *)
    open func outputImageMaximumSize() -> CGSize
}

/// An enum string type that your code can use to select different options when creating a Core Image context.
/// 
/// These option keys can be passed to `CIContext` creation APIs such as:
/// * ``/CIContext/contextWithOptions:``
/// * ``/CIContext/contextWithMTLDevice:options:``
/// 
public struct CIContextOption : Hashable, Equatable, RawRepresentable, @unchecked Sendable {

    public init(rawValue: String)
}

extension CIContextOption {

    /// A Core Image context option key to specify the default destination color space for rendering.
    /// 
    /// This option only affects how Core Image renders using the following methods:
    /// * ``/CIContext/createCGImage:fromRect:``
    /// * ``/CIContext/drawImage:atPoint:fromRect:``
    /// * ``/CIContext/drawImage:inRect:fromRect:``
    /// 
    /// With all other render methods, the destination color space is either specified as a parameter
    /// or can be determined from the object being rendered to.
    ///
    /// The value of this option can be either:
    /// * A `CGColorSpace` instance with an RGB or monochrome color model that supports output.
    /// * An `NSNull` instance to indicate that the context should not match from the working space to the destination.
    ///
    /// If this option is not specified, then the default output space is sRGB.
    /// 
    public static let outputColorSpace: CIContextOption

    /// A Core Image context option key to specify the working color space for rendering.
    /// 
    /// Contexts support automatic color management by performing all processing operations 
    /// in a working color space. This means that unless told otherwise:
    /// * All input images are color matched from the input's color space to the working space.
    /// * All renders are color matched from the working space to the destination's color space.
    /// 
    /// The default working space is the extended sRGB color space with linear gamma.
    /// On macOS before 10.10, the default is extended Generic RGB with linear gamma. 
    /// 
    /// The value of this option can be either:
    /// * A `CGColorSpace` instance with an RGB color model that supports output.
    /// * An `NSNull` instance to request that Core Image perform no color management.
    /// 
    /// If this option is not specified, then the default working space is used.
    /// 
    public static let workingColorSpace: CIContextOption

    /// A Core Image context option key to specify the pixel format to for intermediate results when rendering.
    /// 
    /// The value for this key is an `NSNumber` instance containing a ``CIFormat`` value. 
    /// 
    /// The supported values for the working pixel format are:
    /// ``CIFormat``        | Notes
    /// ------------------- | --------------
    /// ``kCIFormatRGBA8``  | Uses less memory but has less precision an range
    /// ``kCIFormatRGBAh``  | Uses 8 bytes per pixel, supports HDR
    /// ``kCIFormatRGBAf``  | Only on macOS
    /// 
    /// If this option is not specified, then the default is ``kCIFormatRGBAh``.
    /// 
    /// (The default is ``kCIFormatRGBA8`` if your if app is linked against iOS 12 SDK or earlier.)
    /// 
    @available(visionOS 1.0, *)
    public static let workingFormat: CIContextOption

    /// A Boolean value to control the quality of image downsampling operations performed by the 
    /// Core Image context.
    /// 
    /// The higher quality behavior performs downsampling operations in multiple passes
    /// in order to reduce aliasing artifacts.
    /// 
    /// The lower quality behavior performs downsampling operations a single pass
    /// in order to improve performance.
    ///
    /// If the value for this option is:
    /// * True: The higher quality behavior will be used. 
    /// * False: The lower quality behavior will be used. 
    /// * Not specified: the default behavior is True on macOS and False on other platforms. 
    /// 
    /// > Note: 
    /// > * This option does affect how ``/CIImage/imageByApplyingTransform:`` operations are performed by the context.
    /// > * This option does not affect how ``/CIImage/imageByApplyingTransform:highQualityDownsample:`` behaves.
    /// 
    @available(visionOS 1.0, *)
    public static let highQualityDownsample: CIContextOption

    /// A Boolean value to control how a Core Image context render produces alpha-premultiplied pixels.
    ///
    /// This option only affects how a context is rendered when using methods where the destination's
    /// alpha mode cannot be determined such as:
    /// *  ``/CIContext/render:toBitmap:rowBytes:bounds:format:colorSpace:``
    /// *  ``/CIContext/render:toCVPixelBuffer:``
    /// *  ``/CIContext/render:toIOSurface:bounds:colorSpace:``
    /// *  ``/CIContext/render:toMTLTexture:commandBuffer:bounds:colorSpace:``
    /// *  ``/CIContext/createCGImage:fromRect:``
    /// 
    /// If the value for this option is:
    /// * True: The output will produce alpha-premultiplied pixels. 
    /// * False: The output will produce un-premultiplied pixels. 
    /// * Not specified: the default behavior True. 
    /// 
    /// This option does not affect how a context is rendered to a ``CIRenderDestination`` because
    /// that API allows you to set or override the alpha behavior using ``/CIRenderDestination/alphaMode``.
    /// 
    @available(visionOS 1.0, *)
    public static let outputPremultiplied: CIContextOption

    /// A Boolean value to control how a Core Image context caches the contents of any intermediate image buffers it uses during rendering.
    /// 
    /// If a context caches intermediate buffers, then subsequent renders of a similar image using the same context
    /// may be able to render faster. If a context does not cache intermediate buffers, then it may use less memory.
    /// 
    /// If the value for this option is:
    /// * True: The context will cache intermediate results for future renders using the same context. 
    /// * False: The context will not cache intermediate results. 
    /// * Not specified: the default behavior True. 
    /// 
    /// > Note: 
    /// > * This option does affect how ``/CIImage/imageByInsertingIntermediate`` behaves.
    /// > * This option does not affect how ``/CIImage/imageByInsertingIntermediate:`` behaves.
    ///
    @available(visionOS 1.0, *)
    public static let cacheIntermediates: CIContextOption

    /// A Boolean value to control if a Core Image context will use a software renderer.
    /// 
    /// > Note: This option has no effect if the platform does not support OpenCL.
    /// 
    public static let useSoftwareRenderer: CIContextOption

    /// A Boolean value to control the priority Core Image context renders.
    /// 
    /// If this value is True, then rendering with the context from a background thread takes lower priority 
    /// than other GPU usage from the main thread. This allows your app to perform Core Image rendering without 
    /// disturbing the frame rate of UI animations.
    ///
    @available(visionOS 1.0, *)
    public static let priorityRequestLow: CIContextOption

    /// A Boolean value to control the power level of Core Image context renders.
    /// 
    /// This option only affects certain macOS devices with more than one available GPU device.
    /// 
    /// If this value is True, then rendering with the context will use a use allow power GPU device
    /// if available and the high power device is not already in use.
    /// 
    /// Otherwise, the context will use the highest power/performance GPU device.
    /// 
    @available(visionOS 1.0, *)
    public static let allowLowPower: CIContextOption

    /// A Boolean value to specify a client-provided name for a context.
    /// 
    /// This name will be used in QuickLook graphs and the output of CI_PRINT_TREE.
    /// 
    @available(visionOS 1.0, *)
    public static let name: CIContextOption

    /// A Core Video Metal texture cache object to improve the performance of Core Image context
    /// renders that use Core Video pixel buffers.
    /// 
    /// Creating a Core Image context with this optional `CVMetalTextureCache` can improve the 
    /// performance of creating a Metal texture from a `CVPixelBuffer`. It is recommended 
    /// to specify this option if the context renders to or from pixel buffers that come 
    /// from a `CVPixelBufferPool`.
    /// 
    /// It is the client's responsibility to flush the cache when appropriate.
    /// 
    @available(visionOS 26.0, *)
    public static let cvMetalTextureCache: CIContextOption

    /// A number value to control the maximum memory in megabytes that the context allocates for render tasks.  
    /// 
    /// Larger values could increase memory  footprint while smaller values could reduce performance.
    /// 
    @available(visionOS 1.0, *)
    public static let memoryTarget: CIContextOption
}

extension CIContext {

    /// Creates a Core Graphics image from a region of a Core Image image instance.
    /// 
    /// The color space of the created `CGImage` will be sRGB unless the receiving ``CIContext``
    /// was created with a `kCIContextOutputColorSpace` option.
    /// 
    /// Normally the pixel format of the created CGImage will be 8 bits-per-component.
    /// It will be 16 bits-per-component float if the above color space is HDR.
    ///
    /// - Parameters:
    ///    - image: A ``CIImage`` image instance for which to create a `CGImage`.
    ///    - fromRect: The `CGRect` region of the `image` to use. 
    ///        This region relative to the cartesean coordinate system of `image`.
    ///        This region will be intersected with integralized and intersected with `image.extent`.
    ///
    /// - Returns:
    ///    Returns a new `CGImage` instance. 
    ///    You are responsible for releasing the returned image when you no longer need it. 
    ///    The returned value will be `null` if the extent is empty or too big.
    ///
    open func createCGImage(_ image: CIImage, from fromRect: CGRect) -> CGImage?

    /// Creates a Core Graphics image from a region of a Core Image image instance
    /// with an option for controlling the pixel format and color space of the `CGImage`.
    ///
    /// - Parameters:
    ///    - image: A ``CIImage`` image instance for which to create a `CGImage`.
    ///    - fromRect: The `CGRect` region of the `image` to use. 
    ///        This region relative to the cartesean coordinate system of `image`.
    ///        This region will be intersected with integralized and intersected with `image.extent`.
    ///    - format: A ``CIFormat`` to specify the pixel format of the created `CGImage`.
    ///        For example, if `kCIFormatRGBX16` is specified, then the created `CGImage` will 
    ///        be 16 bits-per-component and opaque.
    ///    - colorSpace: The `CGColorSpace` for the output image. 
    ///        This color space must have either `CGColorSpaceModel.rgb` or `CGColorSpaceModel.monochrome` 
    ///        and be compatible with the specified pixel format.
    ///
    /// - Returns:
    ///    Returns a new `CGImage` instance. 
    ///    You are responsible for releasing the returned image when you no longer need it. 
    ///    The returned value will be `null` if the extent is empty or too big.
    ///
    open func createCGImage(_ image: CIImage, from fromRect: CGRect, format: CIFormat, colorSpace: CGColorSpace?) -> CGImage?

    /// Creates a Core Graphics image from a region of a Core Image image instance
    /// with an option for controlling when the image is rendered.
    ///
    /// - Parameters:
    ///    - image: A ``CIImage`` image instance for which to create a `CGImage`.
    ///    - fromRect: The `CGRect` region of the `image` to use. 
    ///        This region relative to the cartesean coordinate system of `image`.
    ///        This region will be intersected with integralized and intersected with `image.extent`.
    ///    - format: A ``CIFormat`` to specify the pixel format of the created `CGImage`.
    ///        For example, if `kCIFormatRGBX16` is specified, then the created `CGImage` will 
    ///        be 16 bits-per-component and opaque.
    ///    - colorSpace: The `CGColorSpace` for the output image. 
    ///        This color space must have either `CGColorSpaceModel.rgb` or `CGColorSpaceModel.monochrome` 
    ///        and be compatible with the specified pixel format.
    ///    - deferred: Controls when Core Image renders `image`.
    ///        * True: rendering of `image` is deferred until the created `CGImage` rendered. 
    ///        * False: the `image` is rendered immediately.
    ///
    /// - Returns:
    ///    Returns a new `CGImage` instance. 
    ///    You are responsible for releasing the returned image when you no longer need it. 
    ///    The returned value will be `null` if the extent is empty or too big.
    ///
    @available(visionOS 1.0, *)
    open func createCGImage(_ image: CIImage, from fromRect: CGRect, format: CIFormat, colorSpace: CGColorSpace?, deferred: Bool) -> CGImage?

    /// Creates a Core Graphics image from a region of a Core Image image instance
    /// with an option for calculating HDR statistics.
    ///
    /// - Parameters:
    ///    - image: A ``CIImage`` image instance for which to create a `CGImage`.
    ///    - fromRect: The `CGRect` region of the `image` to use. 
    ///        This region relative to the cartesean coordinate system of `image`.
    ///        This region will be intersected with integralized and intersected with `image.extent`.
    ///    - format: A ``CIFormat`` to specify the pixel format of the created `CGImage`.
    ///        For example, if `kCIFormatRGBX16` is specified, then the created `CGImage` will 
    ///        be 16 bits-per-component and opaque.
    ///    - colorSpace: The `CGColorSpace` for the output image. 
    ///        This color space must have either `CGColorSpaceModel.rgb` or `CGColorSpaceModel.monochrome` 
    ///        and be compatible with the specified pixel format.
    ///    - deferred: Controls when Core Image renders `image`.
    ///        * True: rendering of `image` is deferred until the created `CGImage` rendered. 
    ///        * False: the `image` is rendered immediately.
    ///    - calculateHDRStats: Controls if Core Image calculates HDR statistics.
    ///        * True: Core Image will immediately render `image`, calculate the HDR statistics
    ///        and create a `CGImage` that has the calculated values.
    ///        * False:  the created `CGImage` will not have any HDR statistics.
    ///
    /// - Returns:
    ///    Returns a new `CGImage` instance. 
    ///    You are responsible for releasing the returned image when you no longer need it. 
    ///    The returned value will be `null` if the extent is empty or too big.
    ///
    @available(visionOS 26.0, *)
    open func createCGImage(_ image: CIImage, from fromRect: CGRect, format: CIFormat, colorSpace: CGColorSpace?, deferred: Bool, calculateHDRStats: Bool) -> CGImage?
}

extension CIContext {

    /// Given an IOSurface, use the receiving Core Image context to calculate its 
    /// HDR statistics (content headroom and content average light level)
    /// and then update the surface's attachments to store the values.
    /// 
    /// If the `IOSurface` has a Clean Aperture rectangle then only pixels within
    /// that rectangle are considered.
    ///
    /// - Parameters:
    ///    - surface: A mutable `IOSurfaceRef` for which to calculate and attach statistics.
    ///    
    @available(visionOS 26.0, *)
    open func calculateHDRStats(for surface: IOSurfaceRef)

    /// Given a CVPixelBuffer, use the receiving Core Image context to calculate its 
    /// HDR statistics (content headroom and content average light level)
    /// and then update the buffers's attachments to store the values.
    /// 
    /// If the `CVPixelBuffer` has a Clean Aperture rectangle then only pixels within
    /// that rectangle are considered.
    ///
    /// - Parameters:
    ///    - buffer: A mutable `CVPixelBuffer` for which to calculate and attach statistics.
    ///    
    @available(visionOS 26.0, *)
    open func calculateHDRStats(for buffer: CVPixelBuffer)

    /// Given a Core Graphics image, use the receiving Core Image context to calculate its 
    /// HDR statistics (content headroom and content average light level)
    /// and then return a new Core Graphics image that has the calculated values.
    ///
    /// - Parameters:
    ///    - cgimage: An immutable `CGImage` for which to calculate statistics.
    /// - Returns:
    ///    Returns a new `CGImage` instance that has the calculated statistics attached.
    ///
    @available(visionOS 26.0, *)
    open func calculateHDRStats(for cgimage: CGImage) -> CGImage

    /// Given a Core Image image, use the receiving Core Image context to calculate its 
    /// HDR statistics (content headroom and content average light level)
    /// and then return a new Core Image image that has the calculated values.
    ///
    /// If the image extent is not finite, then nil will be returned.
    ///
    /// - Parameters:
    ///    - image: An immutable ``CIImage`` for which to calculate statistics.
    /// - Returns:
    ///    Returns a new ``CIImage`` instance that has the calculated statistics attached.
    ///    
    @available(visionOS 26.0, *)
    open func calculateHDRStats(for image: CIImage) -> CIImage?
}

/// An enum string type that your code can use to select different options when saving to image representations such as JPEG and HEIF.
/// 
/// Some of the methods that support these options are:
/// * ``/CIContext/JPEGRepresentationOfImage:colorSpace:options:``
/// * ``/CIContext/HEIFRepresentationOfImage:format:colorSpace:options:``
/// 
public struct CIImageRepresentationOption : Hashable, Equatable, RawRepresentable, @unchecked Sendable {

    public init(rawValue: String)
}

extension CIContext {

    @available(visionOS 1.0, *)
    open func tiffRepresentation(of image: CIImage, format: CIFormat, colorSpace: CGColorSpace, options: [CIImageRepresentationOption : Any] = [:]) -> Data?

    @available(visionOS 1.0, *)
    open func jpegRepresentation(of image: CIImage, colorSpace: CGColorSpace, options: [CIImageRepresentationOption : Any] = [:]) -> Data?

    @available(visionOS 1.0, *)
    open func heifRepresentation(of image: CIImage, format: CIFormat, colorSpace: CGColorSpace, options: [CIImageRepresentationOption : Any] = [:]) -> Data?

    @available(visionOS 1.0, *)
    open func heif10Representation(of image: CIImage, colorSpace: CGColorSpace, options: [CIImageRepresentationOption : Any] = [:]) throws -> Data

    @available(visionOS 1.0, *)
    open func pngRepresentation(of image: CIImage, format: CIFormat, colorSpace: CGColorSpace, options: [CIImageRepresentationOption : Any] = [:]) -> Data?

    @available(visionOS 1.0, *)
    open func openEXRRepresentation(of image: CIImage, options: [CIImageRepresentationOption : Any] = [:]) throws -> Data

    @available(visionOS 1.0, *)
    open func writeTIFFRepresentation(of image: CIImage, to url: URL, format: CIFormat, colorSpace: CGColorSpace, options: [CIImageRepresentationOption : Any] = [:]) throws

    @available(visionOS 1.0, *)
    open func writePNGRepresentation(of image: CIImage, to url: URL, format: CIFormat, colorSpace: CGColorSpace, options: [CIImageRepresentationOption : Any] = [:]) throws

    @available(visionOS 1.0, *)
    open func writeJPEGRepresentation(of image: CIImage, to url: URL, colorSpace: CGColorSpace, options: [CIImageRepresentationOption : Any] = [:]) throws

    @available(visionOS 1.0, *)
    open func writeHEIFRepresentation(of image: CIImage, to url: URL, format: CIFormat, colorSpace: CGColorSpace, options: [CIImageRepresentationOption : Any] = [:]) throws

    @available(visionOS 1.0, *)
    open func writeHEIF10Representation(of image: CIImage, to url: URL, colorSpace: CGColorSpace, options: [CIImageRepresentationOption : Any] = [:]) throws

    @available(visionOS 1.0, *)
    open func writeOpenEXRRepresentation(of image: CIImage, to url: URL, options: [CIImageRepresentationOption : Any] = [:]) throws
}

extension CIImageRepresentationOption {

    /// An optional key and value to save additional depth channel information to a JPEG or HEIF representations.
    /// 
    /// The value for this key needs to be an `AVDepthData` instance.
    @available(visionOS 1.0, *)
    public static let avDepthData: CIImageRepresentationOption

    /// An optional key and value to save additional depth channel information to a JPEG or HEIF.
    /// 
    /// The value for this key needs to be a monochrome depth ``CIImage`` instance.
    @available(visionOS 1.0, *)
    public static let depthImage: CIImageRepresentationOption

    /// An optional key and value to save additional depth channel information to a JPEG or HEIF.
    /// 
    /// The value for this key needs to be a monochrome disparity ``CIImage`` instance.
    @available(visionOS 1.0, *)
    public static let disparityImage: CIImageRepresentationOption

    /// An optional key and value to save a portrait matte channel information to a JPEG or HEIF.
    /// 
    /// The value for this key needs to be a an `AVPortraitEffectsMatte` instance.
    @available(visionOS 1.0, *)
    public static let avPortraitEffectsMatte: CIImageRepresentationOption

    /// An optional key and value to save a portrait matte channel to a JPEG or HEIF.
    /// 
    /// The value for this key needs to be a portrait matte ``CIImage`` instance where black pixels
    /// represent the background region and white pixels represent the primary people in the image.
    /// The image will be converted to monochrome before it is saved to the JPEG or HEIF.
    @available(visionOS 1.0, *)
    public static let portraitEffectsMatteImage: CIImageRepresentationOption

    /// An optional key and value to save one or more segmentation matte channels to a JPEG or HEIF.
    /// 
    /// The value for this key needs to be an array of AVSemanticSegmentationMatte instances.
    @available(visionOS 1.0, *)
    public static let avSemanticSegmentationMattes: CIImageRepresentationOption

    /// An optional key and value to save a skin segmentation channel to a JPEG or HEIF.
    /// 
    /// The value for this key needs to be a ``CIImage`` instance where white pixels 
    /// represent the areas of person's skin are found in the image.
    /// The image will be converted to monochrome before it is saved to the JPEG or HEIF.
    @available(visionOS 1.0, *)
    public static let semanticSegmentationSkinMatteImage: CIImageRepresentationOption

    /// An optional key and value to save a skin segmentation channel to a JPEG or HEIF.
    /// 
    /// The value for this key needs to be a ``CIImage`` instance where white pixels
    /// represent the areas of person's head and facial hair are found in the image.
    /// The image will be converted to monochrome before it is saved to the JPEG or HEIF.
    @available(visionOS 1.0, *)
    public static let semanticSegmentationHairMatteImage: CIImageRepresentationOption

    /// An optional key and value to save a skin segmentation channel to a JPEG or HEIF.
    /// 
    /// The value for this key needs to be a ``CIImage`` instance where white pixels
    /// represent the areas where a person's teeth are found in the image.
    /// The image will be converted to monochrome before it is saved to the JPEG or HEIF.
    @available(visionOS 1.0, *)
    public static let semanticSegmentationTeethMatteImage: CIImageRepresentationOption

    /// An optional key and value to save a skin segmentation channel to a JPEG or HEIF.
    /// 
    /// The value for this key needs to be a ``CIImage`` instance where white pixels 
    /// represent the areas where a person's glasses are found in the image.
    /// The image will be converted to monochrome before it is saved to the JPEG or HEIF.
    @available(visionOS 1.0, *)
    public static let semanticSegmentationGlassesMatteImage: CIImageRepresentationOption

    /// An optional key and value to save a skin segmentation channel to a JPEG or HEIF.
    /// 
    /// The value for this key needs to be a ``CIImage`` instance where white pixels
    /// represent the areas where a person's skin are found in the image.
    /// The image will be converted to monochrome before it is saved to the JPEG or HEIF.
    @available(visionOS 1.0, *)
    public static let semanticSegmentationSkyMatteImage: CIImageRepresentationOption

    /// An optional key and value to save a HDR image using the gain map channel to a JPEG or HEIF.
    /// 
    /// The value for this key needs to be a HDR CIImage instance.
    ///
    /// When provided, Core Image will calculate a gain map auxiliary image 
    /// from the ratio of the HDR image to the primary SDR image.
    ///
    /// If the the HDR ``CIImage`` instance has a ``/CIImage/contentHeadroom`` property, 
    /// then that will be used when calculating the HDRGainMap image and metadata.
    ///
    @available(visionOS 2.0, *)
    public static let hdrImage: CIImageRepresentationOption

    /// An optional key and value to save a gain map channel to a JPEG or HEIF.
    /// 
    /// The value for this key needs to be a monochrome ``CIImage`` instance.
    /// 
    /// If the ``kCIImageRepresentationHDRGainMapAsRGB`` option it true, then it needs to
    /// be an RGB ``CIImage`` instance.
    /// 
    /// The ``/CIImage/properties`` should contain metadata information equivalent to what is returned when 
    /// initializing an image using ``kCIImageAuxiliaryHDRGainMap``.
    ///
    @available(visionOS 1.0, *)
    public static let hdrGainMapImage: CIImageRepresentationOption

    /// An optional key and value to request the gain map channel to be color instead of monochrome.
    /// 
    /// This key affects how the gain map image is calculated from the SDR receiver and
    /// the ``kCIImageRepresentationHDRImage`` image value.
    /// 
    /// The value for this is a Boolean where:
    ///  * True: the gain map is created as a color ratio between the HDR and SDR images. 
    ///  * False: the gain map is created as a brightness ratio between the HDR and SDR images.
    ///  * Not specified: the default behavior False. 
    /// 
    @available(visionOS 2.0, *)
    public static let hdrGainMapAsRGB: CIImageRepresentationOption
}

extension CIContext {

    @available(visionOS 1.0, *)
    open func depthBlurEffectFilter(forImageURL url: URL, options: [AnyHashable : Any]? = nil) -> CIFilter?

    @available(visionOS 1.0, *)
    open func depthBlurEffectFilter(forImageData data: Data, options: [AnyHashable : Any]? = nil) -> CIFilter?

    @available(visionOS 1.0, *)
    open func depthBlurEffectFilter(for image: CIImage, disparityImage: CIImage, portraitEffectsMatte: CIImage?, orientation: CGImagePropertyOrientation, options: [AnyHashable : Any]? = nil) -> CIFilter?

    @available(visionOS 1.0, *)
    open func depthBlurEffectFilter(for image: CIImage, disparityImage: CIImage, portraitEffectsMatte: CIImage?, hairSemanticSegmentation: CIImage?, orientation: CGImagePropertyOrientation, options: [AnyHashable : Any]? = nil) -> CIFilter?

    @available(visionOS 1.0, *)
    open func depthBlurEffectFilter(for image: CIImage, disparityImage: CIImage, portraitEffectsMatte: CIImage?, hairSemanticSegmentation: CIImage?, glassesMatte: CIImage?, gainMap: CIImage?, orientation: CGImagePropertyOrientation, options: [AnyHashable : Any]? = nil) -> CIFilter?
}

