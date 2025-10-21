import Flutter
import UIKit
import TensorFlowLite
import TensorFlowLiteTaskVision
import TensorFlowLiteTaskText
import Accelerate
import CoreGraphics
import CoreImage

public class TflitePlusPlugin: NSObject, FlutterPlugin {
    private var interpreter: Interpreter?
    private var labels: [String]?
    private var gpuDelegate: MetalDelegate?
    private var coreMLDelegate: CoreMLDelegate?
    private let dispatchQueue = DispatchQueue(label: "tflite_plus_queue", qos: .userInitiated)
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "tflite_plus", binaryMessenger: registrar.messenger())
        let instance = TflitePlusPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "loadModel":
            loadModel(call: call, result: result)
        case "detectObjectOnImage":
            detectObjectOnImage(call: call, result: result)
        case "detectObjectOnBinary":
            detectObjectOnBinary(call: call, result: result)
        case "runModelOnImage":
            runModelOnImage(call: call, result: result)
        case "runModelOnBinary":
            runModelOnBinary(call: call, result: result)
        case "runPoseNetOnImage":
            runPoseNetOnImage(call: call, result: result)
        case "runPoseNetOnBinary":
            runPoseNetOnBinary(call: call, result: result)
        case "runSegmentationOnImage":
            runSegmentationOnImage(call: call, result: result)
        case "runSegmentationOnBinary":
            runSegmentationOnBinary(call: call, result: result)
        case "close":
            close(result: result)
        case "getModelInputShape":
            getModelInputShape(result: result)
        case "getModelOutputShape":
            getModelOutputShape(result: result)
        case "isModelLoaded":
            result(interpreter != nil)
        case "getAvailableDelegates":
            getAvailableDelegates(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func loadModel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let modelPath = args["model"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Model path is required", details: nil))
            return
        }
        
        let labelsPath = args["labels"] as? String
        let numThreads = args["numThreads"] as? Int ?? 1
        let isAsset = args["isAsset"] as? Bool ?? true
        let useGpuDelegate = args["useGpuDelegate"] as? Bool ?? false
        let useCoreMLDelegate = args["useNnApiDelegate"] as? Bool ?? false // Using CoreML instead of NNAPI on iOS
        
        dispatchQueue.async { [weak self] in
            do {
                // Close existing interpreter and delegates
                self?.close()
                
                // Load model
                let modelData: Data
                if isAsset {
                    guard let modelURL = Bundle.main.url(forResource: modelPath.replacingOccurrences(of: ".tflite", with: ""), withExtension: "tflite") else {
                        DispatchQueue.main.async {
                            result(FlutterError(code: "MODEL_NOT_FOUND", message: "Model file not found in assets", details: nil))
                        }
                        return
                    }
                    modelData = try Data(contentsOf: modelURL)
                } else {
                    modelData = try Data(contentsOf: URL(fileURLWithPath: modelPath))
                }
                
                // Create interpreter options
                var options = Interpreter.Options()
                options.threadCount = numThreads
                
                // Add delegates
                if useGpuDelegate {
                    do {
                        self?.gpuDelegate = MetalDelegate()
                        if let delegate = self?.gpuDelegate {
                            options.delegates = [delegate]
                        }
                        NSLog("GPU delegate added successfully")
                    } catch {
                        NSLog("Failed to add GPU delegate: \\(error.localizedDescription)")
                    }
                }
                
                if useCoreMLDelegate {
                    do {
                        self?.coreMLDelegate = CoreMLDelegate()
                        if let delegate = self?.coreMLDelegate {
                            if options.delegates == nil {
                                options.delegates = [delegate]
                            } else {
                                options.delegates?.append(delegate)
                            }
                        }
                        NSLog("CoreML delegate added successfully")
                    } catch {
                        NSLog("Failed to add CoreML delegate: \\(error.localizedDescription)")
                    }
                }
                
                self?.interpreter = try Interpreter(modelData: modelData, options: options)
                try self?.interpreter?.allocateTensors()
                
                // Load labels if provided
                if let labelsPath = labelsPath {
                    self?.labels = try self?.loadLabels(path: labelsPath, isAsset: isAsset)
                }
                
                DispatchQueue.main.async {
                    result("Model loaded successfully")
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "LOAD_MODEL_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
    }
    
    private func detectObjectOnImage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let imagePath = args["path"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Image path is required", details: nil))
            return
        }
        
        let imageMean = args["imageMean"] as? Double ?? 127.5
        let imageStd = args["imageStd"] as? Double ?? 127.5
        let numResultsPerClass = args["numResultsPerClass"] as? Int ?? 5
        let threshold = args["threshold"] as? Double ?? 0.1
        let asynch = args["asynch"] as? Bool ?? true
        
        let performDetection = {
            do {
                let detections = try self.performObjectDetection(
                    imagePath: imagePath,
                    imageMean: Float(imageMean),
                    imageStd: Float(imageStd),
                    numResultsPerClass: numResultsPerClass,
                    threshold: Float(threshold)
                )
                DispatchQueue.main.async {
                    result(detections)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "DETECTION_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
        
        if asynch {
            dispatchQueue.async(execute: performDetection)
        } else {
            performDetection()
        }
    }
    
    private func detectObjectOnBinary(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let bytesList = args["bytesList"] as? FlutterStandardTypedData,
              let imageHeight = args["imageHeight"] as? Int,
              let imageWidth = args["imageWidth"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for binary detection", details: nil))
            return
        }
        
        let imageMean = args["imageMean"] as? Double ?? 127.5
        let imageStd = args["imageStd"] as? Double ?? 127.5
        let rotation = args["rotation"] as? Int ?? 0
        let numResultsPerClass = args["numResultsPerClass"] as? Int ?? 5
        let threshold = args["threshold"] as? Double ?? 0.1
        let asynch = args["asynch"] as? Bool ?? true
        
        let performDetection = {
            do {
                let detections = try self.performObjectDetectionOnBinary(
                    bytes: bytesList.data,
                    imageHeight: imageHeight,
                    imageWidth: imageWidth,
                    imageMean: Float(imageMean),
                    imageStd: Float(imageStd),
                    rotation: rotation,
                    numResultsPerClass: numResultsPerClass,
                    threshold: Float(threshold)
                )
                DispatchQueue.main.async {
                    result(detections)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "DETECTION_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
        
        if asynch {
            dispatchQueue.async(execute: performDetection)
        } else {
            performDetection()
        }
    }
    
    private func runModelOnImage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let imagePath = args["path"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Image path is required", details: nil))
            return
        }
        
        let numResults = args["numResults"] as? Int ?? 5
        let threshold = args["threshold"] as? Double ?? 0.1
        let imageMean = args["imageMean"] as? Double ?? 117.0
        let imageStd = args["imageStd"] as? Double ?? 1.0
        let asynch = args["asynch"] as? Bool ?? true
        
        let performClassification = {
            do {
                let classifications = try self.performImageClassification(
                    imagePath: imagePath,
                    numResults: numResults,
                    threshold: Float(threshold),
                    imageMean: Float(imageMean),
                    imageStd: Float(imageStd)
                )
                DispatchQueue.main.async {
                    result(classifications)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "CLASSIFICATION_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
        
        if asynch {
            dispatchQueue.async(execute: performClassification)
        } else {
            performClassification()
        }
    }
    
    private func runModelOnBinary(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let bytesList = args["bytesList"] as? FlutterStandardTypedData,
              let imageHeight = args["imageHeight"] as? Int,
              let imageWidth = args["imageWidth"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for binary classification", details: nil))
            return
        }
        
        let numResults = args["numResults"] as? Int ?? 5
        let threshold = args["threshold"] as? Double ?? 0.1
        let imageMean = args["imageMean"] as? Double ?? 117.0
        let imageStd = args["imageStd"] as? Double ?? 1.0
        let asynch = args["asynch"] as? Bool ?? true
        
        let performClassification = {
            do {
                let classifications = try self.performImageClassificationOnBinary(
                    bytes: bytesList.data,
                    imageHeight: imageHeight,
                    imageWidth: imageWidth,
                    numResults: numResults,
                    threshold: Float(threshold),
                    imageMean: Float(imageMean),
                    imageStd: Float(imageStd)
                )
                DispatchQueue.main.async {
                    result(classifications)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "CLASSIFICATION_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
        
        if asynch {
            dispatchQueue.async(execute: performClassification)
        } else {
            performClassification()
        }
    }
    
    private func runPoseNetOnImage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let imagePath = args["path"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Image path is required", details: nil))
            return
        }
        
        let numResults = args["numResults"] as? Int ?? 5
        let threshold = args["threshold"] as? Double ?? 0.1
        let imageMean = args["imageMean"] as? Double ?? 127.5
        let imageStd = args["imageStd"] as? Double ?? 127.5
        let asynch = args["asynch"] as? Bool ?? true
        
        let performPoseEstimation = {
            do {
                let poses = try self.performPoseEstimation(
                    imagePath: imagePath,
                    numResults: numResults,
                    threshold: Float(threshold),
                    imageMean: Float(imageMean),
                    imageStd: Float(imageStd)
                )
                DispatchQueue.main.async {
                    result(poses)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "POSE_ESTIMATION_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
        
        if asynch {
            dispatchQueue.async(execute: performPoseEstimation)
        } else {
            performPoseEstimation()
        }
    }
    
    private func runPoseNetOnBinary(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let bytesList = args["bytesList"] as? FlutterStandardTypedData,
              let imageHeight = args["imageHeight"] as? Int,
              let imageWidth = args["imageWidth"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for binary pose estimation", details: nil))
            return
        }
        
        let numResults = args["numResults"] as? Int ?? 5
        let threshold = args["threshold"] as? Double ?? 0.1
        let imageMean = args["imageMean"] as? Double ?? 127.5
        let imageStd = args["imageStd"] as? Double ?? 127.5
        let asynch = args["asynch"] as? Bool ?? true
        
        let performPoseEstimation = {
            do {
                let poses = try self.performPoseEstimationOnBinary(
                    bytes: bytesList.data,
                    imageHeight: imageHeight,
                    imageWidth: imageWidth,
                    numResults: numResults,
                    threshold: Float(threshold),
                    imageMean: Float(imageMean),
                    imageStd: Float(imageStd)
                )
                DispatchQueue.main.async {
                    result(poses)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "POSE_ESTIMATION_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
        
        if asynch {
            dispatchQueue.async(execute: performPoseEstimation)
        } else {
            performPoseEstimation()
        }
    }
    
    private func runSegmentationOnImage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let imagePath = args["path"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Image path is required", details: nil))
            return
        }
        
        let imageMean = args["imageMean"] as? Double ?? 127.5
        let imageStd = args["imageStd"] as? Double ?? 127.5
        let labelColors = args["labelColors"] as? [[String: Int]]
        let outputType = args["outputType"] as? String ?? "png"
        let asynch = args["asynch"] as? Bool ?? true
        
        let performSegmentation = {
            do {
                let segmentation = try self.performSegmentation(
                    imagePath: imagePath,
                    imageMean: Float(imageMean),
                    imageStd: Float(imageStd),
                    labelColors: labelColors,
                    outputType: outputType
                )
                DispatchQueue.main.async {
                    result(segmentation)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "SEGMENTATION_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
        
        if asynch {
            dispatchQueue.async(execute: performSegmentation)
        } else {
            performSegmentation()
        }
    }
    
    private func runSegmentationOnBinary(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let bytesList = args["bytesList"] as? FlutterStandardTypedData,
              let imageHeight = args["imageHeight"] as? Int,
              let imageWidth = args["imageWidth"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for binary segmentation", details: nil))
            return
        }
        
        let imageMean = args["imageMean"] as? Double ?? 127.5
        let imageStd = args["imageStd"] as? Double ?? 127.5
        let labelColors = args["labelColors"] as? [[String: Int]]
        let outputType = args["outputType"] as? String ?? "png"
        let asynch = args["asynch"] as? Bool ?? true
        
        let performSegmentation = {
            do {
                let segmentation = try self.performSegmentationOnBinary(
                    bytes: bytesList.data,
                    imageHeight: imageHeight,
                    imageWidth: imageWidth,
                    imageMean: Float(imageMean),
                    imageStd: Float(imageStd),
                    labelColors: labelColors,
                    outputType: outputType
                )
                DispatchQueue.main.async {
                    result(segmentation)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "SEGMENTATION_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
        
        if asynch {
            dispatchQueue.async(execute: performSegmentation)
        } else {
            performSegmentation()
        }
    }
    
    private func close(result: FlutterResult? = nil) {
        interpreter = nil
        gpuDelegate = nil
        coreMLDelegate = nil
        labels = nil
        result?("Model closed successfully")
    }
    
    private func getModelInputShape(result: @escaping FlutterResult) {
        guard let interpreter = interpreter else {
            result(FlutterError(code: "NO_MODEL_LOADED", message: "No model is loaded", details: nil))
            return
        }
        
        do {
            let inputTensor = try interpreter.input(at: 0)
            result(inputTensor.shape.dimensions)
        } catch {
            result(FlutterError(code: "INPUT_SHAPE_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    private func getModelOutputShape(result: @escaping FlutterResult) {
        guard let interpreter = interpreter else {
            result(FlutterError(code: "NO_MODEL_LOADED", message: "No model is loaded", details: nil))
            return
        }
        
        do {
            let outputTensor = try interpreter.output(at: 0)
            result(outputTensor.shape.dimensions)
        } catch {
            result(FlutterError(code: "OUTPUT_SHAPE_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    private func getAvailableDelegates(result: @escaping FlutterResult) {
        var delegates = ["CPU"]
        
        // Check Metal delegate availability
        if MTLCreateSystemDefaultDevice() != nil {
            delegates.append("Metal")
        }
        
        // Check CoreML delegate availability
        delegates.append("CoreML")
        
        result(delegates)
    }
    
    // Helper methods for ML operations
    private func loadLabels(path: String, isAsset: Bool) throws -> [String] {
        let labelsData: Data
        if isAsset {
            guard let labelsURL = Bundle.main.url(forResource: path.replacingOccurrences(of: ".txt", with: ""), withExtension: "txt") else {
                throw NSError(domain: "TflitePlusPlugin", code: 1, userInfo: [NSLocalizedDescriptionKey: "Labels file not found in assets"])
            }
            labelsData = try Data(contentsOf: labelsURL)
        } else {
            labelsData = try Data(contentsOf: URL(fileURLWithPath: path))
        }
        
        let labelsString = String(data: labelsData, encoding: .utf8) ?? ""
        return labelsString.components(separatedBy: .newlines).filter { !$0.isEmpty }
    }
    
    private func performObjectDetection(
        imagePath: String,
        imageMean: Float,
        imageStd: Float,
        numResultsPerClass: Int,
        threshold: Float
    ) throws -> [[String: Any]] {
        // Placeholder implementation
        // You would implement the actual object detection logic here
        return []
    }
    
    private func performObjectDetectionOnBinary(
        bytes: Data,
        imageHeight: Int,
        imageWidth: Int,
        imageMean: Float,
        imageStd: Float,
        rotation: Int,
        numResultsPerClass: Int,
        threshold: Float
    ) throws -> [[String: Any]] {
        // Placeholder implementation
        return []
    }
    
    private func performImageClassification(
        imagePath: String,
        numResults: Int,
        threshold: Float,
        imageMean: Float,
        imageStd: Float
    ) throws -> [[String: Any]] {
        // Placeholder implementation
        return []
    }
    
    private func performImageClassificationOnBinary(
        bytes: Data,
        imageHeight: Int,
        imageWidth: Int,
        numResults: Int,
        threshold: Float,
        imageMean: Float,
        imageStd: Float
    ) throws -> [[String: Any]] {
        // Placeholder implementation
        return []
    }
    
    private func performPoseEstimation(
        imagePath: String,
        numResults: Int,
        threshold: Float,
        imageMean: Float,
        imageStd: Float
    ) throws -> [[String: Any]] {
        // Placeholder implementation
        return []
    }
    
    private func performPoseEstimationOnBinary(
        bytes: Data,
        imageHeight: Int,
        imageWidth: Int,
        numResults: Int,
        threshold: Float,
        imageMean: Float,
        imageStd: Float
    ) throws -> [[String: Any]] {
        // Placeholder implementation
        return []
    }
    
    private func performSegmentation(
        imagePath: String,
        imageMean: Float,
        imageStd: Float,
        labelColors: [[String: Int]]?,
        outputType: String
    ) throws -> [String: Any] {
        // Placeholder implementation
        return [:]
    }
    
    private func performSegmentationOnBinary(
        bytes: Data,
        imageHeight: Int,
        imageWidth: Int,
        imageMean: Float,
        imageStd: Float,
        labelColors: [[String: Int]]?,
        outputType: String
    ) throws -> [String: Any] {
        // Placeholder implementation
        return [:]
    }
}