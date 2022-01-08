import MetalKit
    
public class MUILibrary {
    var muilibrary: [MTLLibrary] = []
    
    public init(device: MTLDevice) {
        for path in  Bundle.main.paths(forResourcesOfType: "msl", inDirectory: nil) {
            do {
                let code = try String(contentsOfFile: path)
                muilibrary.append(try device.makeLibrary(source: code, options: nil))
            } catch {}
        }
    }
    
    public func makeFunction(name: String) -> MTLFunction? {
        for mtllibrary in muilibrary {
            if (mtllibrary.functionNames.contains(name)) {
                return mtllibrary.makeFunction(name: name)
            }
        }
        
        return nil
    }
}
