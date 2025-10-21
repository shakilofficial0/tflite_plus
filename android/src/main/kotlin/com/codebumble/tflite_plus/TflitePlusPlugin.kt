package com.codebumble.tflite_plus

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.content.Context
import android.content.res.AssetManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.util.Log
import java.io.*
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.channels.FileChannel
import java.util.concurrent.Executors
import kotlinx.coroutines.*

import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.gpu.GpuDelegate
import org.tensorflow.lite.nnapi.NnApiDelegate
import org.tensorflow.lite.support.common.FileUtil
import org.tensorflow.lite.support.image.ImageProcessor
import org.tensorflow.lite.support.image.TensorImage
import org.tensorflow.lite.support.image.ops.ResizeOp
import org.tensorflow.lite.support.image.ops.ResizeWithCropOrPadOp
import org.tensorflow.lite.support.image.ops.Rot90Op
import org.tensorflow.lite.task.vision.detector.ObjectDetector
import org.tensorflow.lite.task.vision.detector.Detection
import org.tensorflow.lite.task.vision.classifier.ImageClassifier
import org.tensorflow.lite.task.vision.classifier.Classifications



/** TflitePlusPlugin */
class TflitePlusPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private var interpreter: Interpreter? = null
  private var labels: List<String>? = null
  private var gpuDelegate: GpuDelegate? = null
  private var nnApiDelegate: NnApiDelegate? = null
  private val executorService = Executors.newCachedThreadPool()
  
  companion object {
    private const val TAG = "TflitePlusPlugin"
    private const val CHANNEL_NAME = "tflite_plus"
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "loadModel" -> {
        loadModel(call, result)
      }
      "detectObjectOnImage" -> {
        detectObjectOnImage(call, result)
      }
      "detectObjectOnBinary" -> {
        detectObjectOnBinary(call, result)
      }
      "runModelOnImage" -> {
        runModelOnImage(call, result)
      }
      "runModelOnBinary" -> {
        runModelOnBinary(call, result)
      }
      "runPoseNetOnImage" -> {
        runPoseNetOnImage(call, result)
      }
      "runPoseNetOnBinary" -> {
        runPoseNetOnBinary(call, result)
      }
      "runSegmentationOnImage" -> {
        runSegmentationOnImage(call, result)
      }
      "runSegmentationOnBinary" -> {
        runSegmentationOnBinary(call, result)
      }
      "close" -> {
        close(result)
      }
      "getModelInputShape" -> {
        getModelInputShape(result)
      }
      "getModelOutputShape" -> {
        getModelOutputShape(result)
      }
      "isModelLoaded" -> {
        result.success(interpreter != null)
      }
      "getAvailableDelegates" -> {
        getAvailableDelegates(result)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun loadModel(call: MethodCall, result: Result) {
    val modelPath = call.argument<String>("model")!!
    val labelsPath = call.argument<String?>("labels")
    val numThreads = call.argument<Int>("numThreads") ?: 1
    val isAsset = call.argument<Boolean>("isAsset") ?: true
    val useGpuDelegate = call.argument<Boolean>("useGpuDelegate") ?: false
    val useNnApiDelegate = call.argument<Boolean>("useNnApiDelegate") ?: false

    try {
      // Close existing interpreter and delegates
      close()

      // Load model
      val modelBuffer = if (isAsset) {
        FileUtil.loadMappedFile(context, modelPath)
      } else {
        loadModelFile(modelPath)
      }

      // Create interpreter options
      val options = Interpreter.Options()
      options.setNumThreads(numThreads)

      // Add delegates
      if (useGpuDelegate) {
        try {
          gpuDelegate = GpuDelegate()
          options.addDelegate(gpuDelegate)
          Log.d(TAG, "GPU delegate added successfully")
        } catch (e: Exception) {
          Log.w(TAG, "Failed to add GPU delegate: ${e.message}")
        }
      }

      if (useNnApiDelegate && android.os.Build.VERSION.SDK_INT >= 27) {
        try {
          nnApiDelegate = NnApiDelegate()
          options.addDelegate(nnApiDelegate)
          Log.d(TAG, "NNAPI delegate added successfully")
        } catch (e: Exception) {
          Log.w(TAG, "Failed to add NNAPI delegate: ${e.message}")
        }
      }

      interpreter = Interpreter(modelBuffer, options)

      // Load labels if provided
      if (labelsPath != null) {
        labels = if (isAsset) {
          FileUtil.loadLabels(context, labelsPath)
        } else {
          loadLabelsFromFile(labelsPath)
        }
      }

      result.success("Model loaded successfully")
    } catch (e: Exception) {
      Log.e(TAG, "Error loading model", e)
      result.error("LOAD_MODEL_ERROR", e.message, null)
    }
  }

  private fun detectObjectOnImage(call: MethodCall, result: Result) {
    val imagePath = call.argument<String>("path")!!
    val imageMean = call.argument<Double>("imageMean")?.toFloat() ?: 127.5f
    val imageStd = call.argument<Double>("imageStd")?.toFloat() ?: 127.5f
    val numResultsPerClass = call.argument<Int>("numResultsPerClass") ?: 5
    val threshold = call.argument<Double>("threshold")?.toFloat() ?: 0.1f
    val asynch = call.argument<Boolean>("asynch") ?: true

    if (asynch) {
      executorService.execute {
        try {
          val detections = performObjectDetection(imagePath, imageMean, imageStd, numResultsPerClass, threshold)
          Handler(Looper.getMainLooper()).post {
            result.success(detections)
          }
        } catch (e: Exception) {
          Handler(Looper.getMainLooper()).post {
            result.error("DETECTION_ERROR", e.message, null)
          }
        }
      }
    } else {
      try {
        val detections = performObjectDetection(imagePath, imageMean, imageStd, numResultsPerClass, threshold)
        result.success(detections)
      } catch (e: Exception) {
        result.error("DETECTION_ERROR", e.message, null)
      }
    }
  }

  private fun detectObjectOnBinary(call: MethodCall, result: Result) {
    val bytesList = call.argument<ByteArray>("bytesList")!!
    val imageHeight = call.argument<Int>("imageHeight")!!
    val imageWidth = call.argument<Int>("imageWidth")!!
    val imageMean = call.argument<Double>("imageMean")?.toFloat() ?: 127.5f
    val imageStd = call.argument<Double>("imageStd")?.toFloat() ?: 127.5f
    val rotation = call.argument<Int>("rotation") ?: 0
    val numResultsPerClass = call.argument<Int>("numResultsPerClass") ?: 5
    val threshold = call.argument<Double>("threshold")?.toFloat() ?: 0.1f
    val asynch = call.argument<Boolean>("asynch") ?: true

    if (asynch) {
      executorService.execute {
        try {
          val detections = performObjectDetectionOnBinary(
            bytesList, imageHeight, imageWidth, imageMean, imageStd, 
            rotation, numResultsPerClass, threshold
          )
          Handler(Looper.getMainLooper()).post {
            result.success(detections)
          }
        } catch (e: Exception) {
          Handler(Looper.getMainLooper()).post {
            result.error("DETECTION_ERROR", e.message, null)
          }
        }
      }
    } else {
      try {
        val detections = performObjectDetectionOnBinary(
          bytesList, imageHeight, imageWidth, imageMean, imageStd, 
          rotation, numResultsPerClass, threshold
        )
        result.success(detections)
      } catch (e: Exception) {
        result.error("DETECTION_ERROR", e.message, null)
      }
    }
  }

  private fun runModelOnImage(call: MethodCall, result: Result) {
    val imagePath = call.argument<String>("path")!!
    val numResults = call.argument<Int>("numResults") ?: 5
    val threshold = call.argument<Double>("threshold")?.toFloat() ?: 0.1f
    val imageMean = call.argument<Double>("imageMean")?.toFloat() ?: 117.0f
    val imageStd = call.argument<Double>("imageStd")?.toFloat() ?: 1.0f
    val asynch = call.argument<Boolean>("asynch") ?: true

    if (asynch) {
      executorService.execute {
        try {
          val classifications = performImageClassification(imagePath, numResults, threshold, imageMean, imageStd)
          Handler(Looper.getMainLooper()).post {
            result.success(classifications)
          }
        } catch (e: Exception) {
          Handler(Looper.getMainLooper()).post {
            result.error("CLASSIFICATION_ERROR", e.message, null)
          }
        }
      }
    } else {
      try {
        val classifications = performImageClassification(imagePath, numResults, threshold, imageMean, imageStd)
        result.success(classifications)
      } catch (e: Exception) {
        result.error("CLASSIFICATION_ERROR", e.message, null)
      }
    }
  }

  private fun runModelOnBinary(call: MethodCall, result: Result) {
    val bytesList = call.argument<ByteArray>("bytesList")!!
    val imageHeight = call.argument<Int>("imageHeight")!!
    val imageWidth = call.argument<Int>("imageWidth")!!
    val numResults = call.argument<Int>("numResults") ?: 5
    val threshold = call.argument<Double>("threshold")?.toFloat() ?: 0.1f
    val imageMean = call.argument<Double>("imageMean")?.toFloat() ?: 117.0f
    val imageStd = call.argument<Double>("imageStd")?.toFloat() ?: 1.0f
    val asynch = call.argument<Boolean>("asynch") ?: true

    if (asynch) {
      executorService.execute {
        try {
          val classifications = performImageClassificationOnBinary(
            bytesList, imageHeight, imageWidth, numResults, threshold, imageMean, imageStd
          )
          Handler(Looper.getMainLooper()).post {
            result.success(classifications)
          }
        } catch (e: Exception) {
          Handler(Looper.getMainLooper()).post {
            result.error("CLASSIFICATION_ERROR", e.message, null)
          }
        }
      }
    } else {
      try {
        val classifications = performImageClassificationOnBinary(
          bytesList, imageHeight, imageWidth, numResults, threshold, imageMean, imageStd
        )
        result.success(classifications)
      } catch (e: Exception) {
        result.error("CLASSIFICATION_ERROR", e.message, null)
      }
    }
  }

  private fun runPoseNetOnImage(call: MethodCall, result: Result) {
    val imagePath = call.argument<String>("path")!!
    val numResults = call.argument<Int>("numResults") ?: 5
    val threshold = call.argument<Double>("threshold")?.toFloat() ?: 0.1f
    val imageMean = call.argument<Double>("imageMean")?.toFloat() ?: 127.5f
    val imageStd = call.argument<Double>("imageStd")?.toFloat() ?: 127.5f
    val asynch = call.argument<Boolean>("asynch") ?: true

    if (asynch) {
      executorService.execute {
        try {
          val poses = performPoseEstimation(imagePath, numResults, threshold, imageMean, imageStd)
          Handler(Looper.getMainLooper()).post {
            result.success(poses)
          }
        } catch (e: Exception) {
          Handler(Looper.getMainLooper()).post {
            result.error("POSE_ESTIMATION_ERROR", e.message, null)
          }
        }
      }
    } else {
      try {
        val poses = performPoseEstimation(imagePath, numResults, threshold, imageMean, imageStd)
        result.success(poses)
      } catch (e: Exception) {
        result.error("POSE_ESTIMATION_ERROR", e.message, null)
      }
    }
  }

  private fun runPoseNetOnBinary(call: MethodCall, result: Result) {
    val bytesList = call.argument<ByteArray>("bytesList")!!
    val imageHeight = call.argument<Int>("imageHeight")!!
    val imageWidth = call.argument<Int>("imageWidth")!!
    val numResults = call.argument<Int>("numResults") ?: 5
    val threshold = call.argument<Double>("threshold")?.toFloat() ?: 0.1f
    val imageMean = call.argument<Double>("imageMean")?.toFloat() ?: 127.5f
    val imageStd = call.argument<Double>("imageStd")?.toFloat() ?: 127.5f
    val asynch = call.argument<Boolean>("asynch") ?: true

    if (asynch) {
      executorService.execute {
        try {
          val poses = performPoseEstimationOnBinary(
            bytesList, imageHeight, imageWidth, numResults, threshold, imageMean, imageStd
          )
          Handler(Looper.getMainLooper()).post {
            result.success(poses)
          }
        } catch (e: Exception) {
          Handler(Looper.getMainLooper()).post {
            result.error("POSE_ESTIMATION_ERROR", e.message, null)
          }
        }
      }
    } else {
      try {
        val poses = performPoseEstimationOnBinary(
          bytesList, imageHeight, imageWidth, numResults, threshold, imageMean, imageStd
        )
        result.success(poses)
      } catch (e: Exception) {
        result.error("POSE_ESTIMATION_ERROR", e.message, null)
      }
    }
  }

  private fun runSegmentationOnImage(call: MethodCall, result: Result) {
    val imagePath = call.argument<String>("path")!!
    val imageMean = call.argument<Double>("imageMean")?.toFloat() ?: 127.5f
    val imageStd = call.argument<Double>("imageStd")?.toFloat() ?: 127.5f
    val labelColors = call.argument<List<Map<String, Int>>?>("labelColors")
    val outputType = call.argument<String>("outputType") ?: "png"
    val asynch = call.argument<Boolean>("asynch") ?: true

    if (asynch) {
      executorService.execute {
        try {
          val segmentation = performSegmentation(imagePath, imageMean, imageStd, labelColors, outputType)
          Handler(Looper.getMainLooper()).post {
            result.success(segmentation)
          }
        } catch (e: Exception) {
          Handler(Looper.getMainLooper()).post {
            result.error("SEGMENTATION_ERROR", e.message, null)
          }
        }
      }
    } else {
      try {
        val segmentation = performSegmentation(imagePath, imageMean, imageStd, labelColors, outputType)
        result.success(segmentation)
      } catch (e: Exception) {
        result.error("SEGMENTATION_ERROR", e.message, null)
      }
    }
  }

  private fun runSegmentationOnBinary(call: MethodCall, result: Result) {
    val bytesList = call.argument<ByteArray>("bytesList")!!
    val imageHeight = call.argument<Int>("imageHeight")!!
    val imageWidth = call.argument<Int>("imageWidth")!!
    val imageMean = call.argument<Double>("imageMean")?.toFloat() ?: 127.5f
    val imageStd = call.argument<Double>("imageStd")?.toFloat() ?: 127.5f
    val labelColors = call.argument<List<Map<String, Int>>?>("labelColors")
    val outputType = call.argument<String>("outputType") ?: "png"
    val asynch = call.argument<Boolean>("asynch") ?: true

    if (asynch) {
      executorService.execute {
        try {
          val segmentation = performSegmentationOnBinary(
            bytesList, imageHeight, imageWidth, imageMean, imageStd, labelColors, outputType
          )
          Handler(Looper.getMainLooper()).post {
            result.success(segmentation)
          }
        } catch (e: Exception) {
          Handler(Looper.getMainLooper()).post {
            result.error("SEGMENTATION_ERROR", e.message, null)
          }
        }
      }
    } else {
      try {
        val segmentation = performSegmentationOnBinary(
          bytesList, imageHeight, imageWidth, imageMean, imageStd, labelColors, outputType
        )
        result.success(segmentation)
      } catch (e: Exception) {
        result.error("SEGMENTATION_ERROR", e.message, null)
      }
    }
  }

  private fun close(result: Result? = null) {
    try {
      interpreter?.close()
      interpreter = null
      
      gpuDelegate?.close()
      gpuDelegate = null
      
      nnApiDelegate?.close()
      nnApiDelegate = null
      
      labels = null
      
      result?.success(null)
    } catch (e: Exception) {
      result?.error("CLOSE_ERROR", e.message, null)
    }
  }

  private fun getModelInputShape(result: Result) {
    try {
      val inputTensor = interpreter?.getInputTensor(0)
      val shape = inputTensor?.shape()?.toList()
      result.success(shape)
    } catch (e: Exception) {
      result.error("INPUT_SHAPE_ERROR", e.message, null)
    }
  }

  private fun getModelOutputShape(result: Result) {
    try {
      val outputTensor = interpreter?.getOutputTensor(0)
      val shape = outputTensor?.shape()?.toList()
      result.success(shape)
    } catch (e: Exception) {
      result.error("OUTPUT_SHAPE_ERROR", e.message, null)
    }
  }

  private fun getAvailableDelegates(result: Result) {
    val delegates = mutableListOf<String>()
    delegates.add("CPU")
    
    // Check GPU delegate availability
    try {
      val testDelegate = GpuDelegate()
      delegates.add("GPU")
      testDelegate.close()
    } catch (e: Exception) {
      Log.d(TAG, "GPU delegate not available")
    }
    
    // Check NNAPI delegate availability (Android 8.1+)
    if (android.os.Build.VERSION.SDK_INT >= 27) {
      delegates.add("NNAPI")
    }
    
    result.success(delegates)
  }

  // Helper methods for actual ML operations
  private fun performObjectDetection(
    imagePath: String,
    imageMean: Float,
    imageStd: Float,
    numResultsPerClass: Int,
    threshold: Float
  ): List<Map<String, Any>> {
    // Implementation for object detection
    // This is a placeholder - you would implement the actual detection logic here
    return emptyList()
  }

  private fun performObjectDetectionOnBinary(
    bytesList: ByteArray,
    imageHeight: Int,
    imageWidth: Int,
    imageMean: Float,
    imageStd: Float,
    rotation: Int,
    numResultsPerClass: Int,
    threshold: Float
  ): List<Map<String, Any>> {
    // Implementation for object detection on binary data
    return emptyList()
  }

  private fun performImageClassification(
    imagePath: String,
    numResults: Int,
    threshold: Float,
    imageMean: Float,
    imageStd: Float
  ): List<Map<String, Any>> {
    // Implementation for image classification
    return emptyList()
  }

  private fun performImageClassificationOnBinary(
    bytesList: ByteArray,
    imageHeight: Int,
    imageWidth: Int,
    numResults: Int,
    threshold: Float,
    imageMean: Float,
    imageStd: Float
  ): List<Map<String, Any>> {
    // Implementation for image classification on binary data
    return emptyList()
  }

  private fun performPoseEstimation(
    imagePath: String,
    numResults: Int,
    threshold: Float,
    imageMean: Float,
    imageStd: Float
  ): List<Map<String, Any>> {
    // Implementation for pose estimation
    return emptyList()
  }

  private fun performPoseEstimationOnBinary(
    bytesList: ByteArray,
    imageHeight: Int,
    imageWidth: Int,
    numResults: Int,
    threshold: Float,
    imageMean: Float,
    imageStd: Float
  ): List<Map<String, Any>> {
    // Implementation for pose estimation on binary data
    return emptyList()
  }

  private fun performSegmentation(
    imagePath: String,
    imageMean: Float,
    imageStd: Float,
    labelColors: List<Map<String, Int>>?,
    outputType: String
  ): Map<String, Any> {
    // Implementation for segmentation
    return emptyMap()
  }

  private fun performSegmentationOnBinary(
    bytesList: ByteArray,
    imageHeight: Int,
    imageWidth: Int,
    imageMean: Float,
    imageStd: Float,
    labelColors: List<Map<String, Int>>?,
    outputType: String
  ): Map<String, Any> {
    // Implementation for segmentation on binary data
    return emptyMap()
  }

  private fun loadModelFile(modelPath: String): ByteBuffer {
    val file = File(modelPath)
    val inputStream = FileInputStream(file)
    val fileChannel = inputStream.channel
    val startOffset = 0L
    val declaredLength = fileChannel.size()
    return fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength)
  }

  private fun loadLabelsFromFile(labelsPath: String): List<String> {
    val labels = mutableListOf<String>()
    File(labelsPath).forEachLine { line ->
      labels.add(line.trim())
    }
    return labels
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    close()
    executorService.shutdown()
  }
}