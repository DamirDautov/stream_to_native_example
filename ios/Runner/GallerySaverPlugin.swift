public class GallerySaverPlugin: NSObject {

    private var onResult: FlutterResult?

    func register(with controller: FlutterViewController, name: String) {
        FlutterMethodChannel(
                name: name,
                binaryMessenger: controller.binaryMessenger
        ).setMethodCallHandler(execute)
    }

    private func execute(call: FlutterMethodCall, result: @escaping FlutterResult) {
        onResult = result

        if call.method == "saveBytesToFile" {
            guard let arguments = call.arguments as? [String: Any] else {
                return
            }

            if let name = arguments["fileName"] as? String {
                if let bytes = (arguments["bytes"] as? FlutterStandardTypedData)?.data {
                    let documentsPath1 = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
                    _ = documentsPath1.appendingPathComponent("file")
                    var fileName = name
                    do {
                        let fileManager = FileManager.default
                        try FileManager.default.createDirectory(atPath: documentsPath1.path!, withIntermediateDirectories: true, attributes: nil)

                        var fileURL = documentsPath1.appendingPathComponent(fileName)

                        try Data(bytes).write(to: fileURL!)
                        result([
                            "uri": fileURL!.path,
                            "filename": fileName,
                        ])
                    } catch let error as NSError {
                        result(FlutterError(code: "UNKNOWN", message: "Invalid arguments", details: "Unable to create directory \(error.debugDescription)"))
                    }
                } else {
                    // TODO: error message
                    result(FlutterError(code: "UNKNOWN", message: "Invalid arguments", details: "Bytes required"))
                }
            } else {
                result(FlutterError(code: "UNKNOWN", message: "Invalid arguments", details: "Filename required"))
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}
