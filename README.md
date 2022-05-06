# MetalUI
Metal for SwiftUI. A [custom wrapper for UIView](https://www.hackingwithswift.com/quick-start/swiftui/how-to-wrap-a-custom-uiview-for-swiftui) to support Metal in SwiftUI. Renders a colored triangle, the _Hello World_ in graphics programming.

## Usage
- Create App with SP4<br>
  Name must differ from _MetalUI_

- Import package repository
  
  **From code given below:**
- Update `ContentView.swift` to use wrapper
- Prepare and import Metal files `*.msl`
- Create `AppPresenter.swift`
- Create `AppRenderer.swift`

### ContentView.swift
```swift
import MetalUI
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            MUIView {
                AppPresenter()
            }
        }
    }
}
```

### AppPresenter.swift
```swift
import MetalKit
import MetalUI

class AppPresenter: MTKView, MUIPresenter {
    var renderer: MUIRenderer!
    
    required init() {
        super.init(frame: .zero, device: MTLCreateSystemDefaultDevice())
        configure(device: device)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureMTKView() {
        colorPixelFormat = .bgra8Unorm
        clearColor = MTLClearColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1)
    }
    
    func renderer(forDevice device: MTLDevice) -> MUIRenderer {
        AppRenderer(vertices: [
            MUIVertex(position: SIMD3(0,1,0),   color: SIMD4(1,0,0,1)),
            MUIVertex(position: SIMD3(-1,-1,0), color: SIMD4(0,1,0,1)),
            MUIVertex(position: SIMD3(1,-1,0),  color: SIMD4(0,0,1,1))
        ], device: device)
    }
}
```

### AppRenderer.swift
```swift
import MetalKit
import MetalUI

final class AppRenderer: NSObject, MUIRenderer {
    var commandQueue:        MTLCommandQueue?
    var renderPipelineState: MTLRenderPipelineState?
    var vertexBuffer:        MTLBuffer?
    
    var vertices: [MUIVertex] = []
    
    func createCommandQueue(device: MTLDevice) {
        commandQueue = device.makeCommandQueue()
    }
    
    func createPipelineState(
        withLibrary library: MTLLibrary?,
        forDevice device: MTLDevice
    ) {
        var vertexFunction: MTLFunction?
        var fragmentFunction: MTLFunction?
        if (library == nil) {
            guard let mtllibrary = device.makeLibrary(fromResourcesWithSuffixes: ["msl"]) else {
                fatalError("no shader programs")
            }
            vertexFunction = makeFunction(fromMTLLibraries: mtllibrary, name: "vert_function")
            fragmentFunction = makeFunction(fromMTLLibraries: mtllibrary, name: "frag_function")
        } else {
            vertexFunction   = library?.makeFunction(name: "vert_function")
            fragmentFunction = library?.makeFunction(name: "frag_function")
        }
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.vertexFunction                  = vertexFunction
        renderPipelineDescriptor.fragmentFunction                = fragmentFunction
        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func createBuffers(device: MTLDevice) {
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: MemoryLayout<MUIVertex>.stride * vertices.count,
                                         options: [])
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        // Get the current drawable and descriptor
        guard let drawable             = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let commandQueue         = commandQueue,
              let renderPipelineState  = renderPipelineState else {
                  return
              }
        let commandBuffer  = commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.setRenderPipelineState(renderPipelineState)
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
```

### frag.msl
```metal
#include <metal_stdlib>

using namespace metal;

struct VertexOut {
    float4 position [[ position ]];
    float4 color;
};

fragment float4 frag_function(VertexOut vIn [[ stage_in ]]) {
    return vIn.color;
}
```

### vert.msl
```metal
#include <metal_stdlib>
    
using namespace metal;
    
struct VertexIn {
    float3 position;
    float4 color;
};
    
struct VertexOut {
    float4 position [[ position ]];
    float4 color;
};
    
vertex VertexOut vert_function(const device VertexIn *vertices [[ buffer(0) ]],
                                       uint vertexID [[ vertex_id  ]]) {
    VertexOut vOut;
    vOut.position = float4(vertices[vertexID].position,1);
    vOut.color    = vertices[vertexID].color;
    
    return vOut;
}
```
