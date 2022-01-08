import MetalKit
    
public protocol MUIRenderer: NSObject, MTKViewDelegate {
    var commandQueue:        MTLCommandQueue? { get set }
    var renderPipelineState: MTLRenderPipelineState? { get set }
    var vertexBuffer:        MTLBuffer? { get set }
    
    var vertices: [MUIVertex] { get set }
    
    init()
    init(vertices: [MUIVertex], device: MTLDevice)
    
    func createCommandQueue(device: MTLDevice)
    func createPipelineState(withLibrary library: MTLLibrary?, forDevice device: MTLDevice)
    func createBuffers(device: MTLDevice)
    
    // MARK: MTKViewDelegate
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize)
    func draw(in view: MTKView)
}
    
public extension MUIRenderer {
    init(vertices: [MUIVertex], device: MTLDevice) {
        self.init()
        
        self.vertices = vertices
        
        createCommandQueue(device: device)
        createPipelineState(withLibrary: device.makeDefaultLibrary(), forDevice: device)
        createBuffers(device: device)
    }
}
