import MetalKit
import SwiftUI
    
public struct MUIView<Content>: UIViewRepresentable where Content: MUIPresenting {
    public var wrappedView: Content
    
    private var handleMakeUIView:   ((Context) -> Content)?
    private var handleUpdateUIView: ((Content, Context) -> Void)?
    
    public init(closure: () -> Content) {
        wrappedView = closure()
    }
    
    public func makeUIView(context: Context) -> Content {
        guard let handler = handleMakeUIView else {
            return wrappedView
        }
        
        return handler(context)
    }
    
    public func updateUIView(_ uiView: Content, context: Context) {
        handleUpdateUIView?(uiView, context)
    }
}
    
public extension MUIView {
    mutating func setMakeUIView(handler: @escaping (Context) -> Content) -> Self {
        handleMakeUIView = handler
        
        return self
    }
    
    mutating func setUpdateUIView(handler: @escaping (Content, Context) -> Void) -> Self {
        handleUpdateUIView = handler
        
        return self
    }
}
