//
//  ScannerViewController.swift
//  ScanCard
//
//  Created by GEU on 18/03/26.
//

import UIKit
import AVFoundation
import Vision

class ScannerViewController: UIViewController {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var scanButton: UIButton!
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    var step: String = ""
    private var scannedIngredients: [String] = []
    private var isProcessing = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    @IBAction func startScanningTapped(_ sender: UIButton) {
        
        scanButton.isHidden = true
        infoLabel.isHidden = false
        infoLabel.text = "Scanning..."
        
        setupCamera()
    }
    
}

private extension ScannerViewController {
    
    func setupUI() {
        infoLabel.textColor = .white
        infoLabel.textAlignment = .center
        infoLabel.isHidden = true
    }
}

private extension ScannerViewController {
    
    func setupCamera() {
        
        captureSession = AVCaptureSession()
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        
        view.layer.insertSublayer(previewLayer, at: 0)
        
        captureSession.startRunning()
    }
}

extension ScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              !isProcessing else { return }
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            
            guard let self = self,
                  let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            let texts = observations.compactMap { $0.topCandidates(1).first?.string }
            
            print("OCR:", texts.joined(separator: " | "))
            
            let ingredients = self.extractIngredients(from: texts.joined(separator: " "))
            
            if ingredients.count > 3 && !self.isProcessing {
                DispatchQueue.main.async {
                    self.isProcessing = true
                    self.captureSession.stopRunning()
                    
                    self.scannedIngredients = ingredients
                    
                    self.performSegue(withIdentifier: "scanner_to_result", sender: nil)
                }
            }
        }
        
        request.recognitionLevel = VNRequestTextRecognitionLevel.accurate
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "scanner_to_result",
           let resultVC = segue.destination as? ResultViewController {
            
            resultVC.ingredients = scannedIngredients
            resultVC.step = step
        }
    }
    
}

private extension ScannerViewController {
    
    func extractIngredients(from text: String) -> [String] {
        
        let cleaned = text
            .lowercased()
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: ".", with: "")
        
        let words = cleaned
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.count > 2 }
        
        return words
    }
}
