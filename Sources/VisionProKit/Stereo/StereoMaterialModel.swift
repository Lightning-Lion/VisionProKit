import os
import SwiftUI
import RealityKit

// MARK: - StereoMaterialModel
/// 立体材质模型
/// 管理双目立体材质的创建和配置
/// 负责将左右眼图像合成为可在RealityKit中渲染的ShaderGraphMaterial
@MainActor
@Observable
public class StereoMaterialModel {
    
    /// StereoMaterial 的 USDA 定义
    /// 从 EyeCover/Packages/RealityKitContent 迁移而来
    private static let stereoMaterialUSDA = """
#usda 1.0
(
    customLayerData = {
        string creator = "Reality Composer Pro Version 2.0 (494.60.2)"
    }
    defaultPrim = "Root"
    metersPerUnit = 1
    upAxis = "Y"
)

def Xform "Root"
{
    def Material "Material"
    {
        asset inputs:LeftEye (
            customData = {
                dictionary realitykit = {
                    float2 positionInSubgraph = (-1250.4203, -254.57945)
                    int stackingOrderInSubgraph = 84
                }
            }
        )
        asset inputs:RightEye (
            customData = {
                dictionary realitykit = {
                    float2 positionInSubgraph = (-1241.2996, 192.42935)
                    int stackingOrderInSubgraph = 84
                }
            }
        )
        token outputs:mtlx:surface.connect = </Root/Material/UnlitSurface.outputs:out>
        token outputs:realitykit:vertex
        float2 ui:nodegraph:realitykit:subgraphOutputs:pos = (440.38092, 134.79507)
        int ui:nodegraph:realitykit:subgraphOutputs:stackingOrder = 1374

        def Shader "RightEyeImage"
        {
            uniform token info:id = "ND_RealityKitTexture2D_vector4"
            float inputs:bias
            float4 inputs:default
            float inputs:dynamic_min_lod_clamp
            asset inputs:file.connect = </Root/Material.inputs:RightEye>
            float inputs:min_lod_clamp
            bool inputs:no_flip_v = 1
            int2 inputs:offset
            float2 inputs:texcoord
            string inputs:u_wrap_mode
            float4 outputs:out
            float2 ui:nodegraph:node:pos = (-991.7627, 314.30814)
            int ui:nodegraph:node:stackingOrder = 81
        }

        def Shader "LeftEyeImage"
        {
            uniform token info:id = "ND_RealityKitTexture2D_vector4"
            float inputs:bias
            float inputs:dynamic_min_lod_clamp
            asset inputs:file.connect = </Root/Material.inputs:LeftEye>
            bool inputs:no_flip_v = 1
            int2 inputs:offset
            string inputs:u_wrap_mode
            float4 outputs:out
            float2 ui:nodegraph:node:pos = (-991.8921, -132.53119)
            int ui:nodegraph:node:stackingOrder = 82
        }

        def Shader "CameraIndexSwitch_2"
        {
            uniform token info:id = "ND_realitykit_geometry_switch_cameraindex_vector4"
            float4 inputs:left.connect = </Root/Material/LeftEyeImage.outputs:out>
            float4 inputs:mono.connect = None
            float4 inputs:right.connect = </Root/Material/RightEyeImage.outputs:out>
            float4 outputs:out
            float2 ui:nodegraph:node:pos = (-629.5773, 61.20944)
            int ui:nodegraph:node:stackingOrder = 1376
        }

        def Shader "UnlitSurface"
        {
            uniform token info:id = "ND_realitykit_unlit_surfaceshader"
            bool inputs:applyPostProcessToneMap = 0
            color3f inputs:color.connect = </Root/Material/Combine3.outputs:out>
            bool inputs:hasPremultipliedAlpha = 0
            float inputs:opacity.connect = </Root/Material/Separate4.outputs:outw>
            float inputs:opacityThreshold
            token outputs:out
            float2 ui:nodegraph:node:pos = (165.03322, 84.31668)
            int ui:nodegraph:node:stackingOrder = 1374
            string[] ui:nodegraph:realitykit:node:attributesShowingChildren = ["inputs:applyPostProcessToneMap", "inputs:applyPostProcessToneMap"]
        }

        def Shader "Separate4"
        {
            uniform token info:id = "ND_separate4_vector4"
            float4 inputs:in.connect = </Root/Material/CameraIndexSwitch_2.outputs:out>
            float outputs:outw
            float outputs:outx
            float outputs:outy
            float outputs:outz
            float2 ui:nodegraph:node:pos = (-296.18848, 80.46213)
            int ui:nodegraph:node:stackingOrder = 1377
        }

        def Shader "Combine3"
        {
            uniform token info:id = "ND_combine3_color3"
            float inputs:in1.connect = </Root/Material/Separate4.outputs:outx>
            float inputs:in2.connect = </Root/Material/Separate4.outputs:outy>
            float inputs:in3.connect = </Root/Material/Separate4.outputs:outz>
            color3f outputs:out
            float2 ui:nodegraph:node:pos = (-74.98843, 64.129265)
            int ui:nodegraph:node:stackingOrder = 1380
        }
    }
}
"""
    
    /// 初始化立体材质模型
    public init() {}
    
    public func createMaterial(leftEye: CGImage, rightEye: CGImage) async throws -> ShaderGraphMaterial {
        os_log("开始加载")
        
        // 将 USDA 字符串转为 Data
        guard let materialData = StereoMaterialModel.stereoMaterialUSDA.data(using: .utf8) else {
            throw NSError(domain: "StereoMaterialModel", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "无法将 USDA 字符串编码为 Data"])
        }
        
        // 从 Data 加载材质
        var matX = try await ShaderGraphMaterial(named: "/Root/Material", from: materialData)
        os_log("ShaderGraphMaterial加载成功")
        
        let left = try await createColorAccurateTexture(from: leftEye, isHDR: false)
        try matX.setParameter(name: "LeftEye", value: .textureResource(left))
        
        let right = try await createColorAccurateTexture(from: rightEye, isHDR: false)
        try matX.setParameter(name: "RightEye", value: .textureResource(right))
        
        return matX
    }
    
    public func createColorAccurateTexture(from cgImage: CGImage, isHDR: Bool = false) async throws -> TextureResource {
        var createOptions = TextureResource.CreateOptions(semantic: .color)
        createOptions.compression = .none
        createOptions.semantic = isHDR ? .hdrColor : .color
        
        guard cgImage.colorSpace != nil else {
            throw NSError(domain: "TextureConversion", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "CGImage缺少色彩空间，无法保证颜色精度"])
        }
        
        let texture = try await TextureResource(image: cgImage, options: createOptions)
        return texture
    }
}

// MARK: - StereoMaterialModelActor
/// 在独立线程中处理透明图像的创建
public actor StereoMaterialModelActor {
    public init() {}
    
    public func create1x1TransparentCGImage() throws -> CGImage {
        let width = 1; let height = 1
        let bitsPerComponent = 8
        let bytesPerRow = width * 4
        var transparentPixel: [UInt8] = [0, 0, 0, 0]
        
        guard let context = CGContext(
            data: &transparentPixel, width: width, height: height,
            bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw NSError(domain: "TransparentCGImageError", code: 1, userInfo: [NSLocalizedDescriptionKey: "创建 1×1 位图上下文失败"])
        }
        
        guard let cgImage = context.makeImage() else {
            throw NSError(domain: "TransparentCGImageError", code: 2, userInfo: [NSLocalizedDescriptionKey: "从上下文转换为 CGImage 失败"])
        }
        return cgImage
    }
}
