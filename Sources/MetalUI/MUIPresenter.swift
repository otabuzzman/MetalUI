import MetalKit
    
public protocol MUIPresenter: MTKView {
    var renderer: MUIRenderer! { get set }
    
    init()
    
    func configure(device: MTLDevice?)
    
    func configureMTKView()
    func renderer(forDevice device: MTLDevice) -> MUIRenderer
}
    
public extension MUIPresenter {
    func configure(device: MTLDevice? = MTLCreateSystemDefaultDevice()) {
        guard let defaultDevice = device else {
            fatalError("initialize GPU failed")
        }
        
        self.renderer = renderer(forDevice: defaultDevice)
        self.delegate = renderer
        self.configureMTKView()
    }
}
