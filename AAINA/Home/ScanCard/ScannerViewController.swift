//
//  ScannerViewController.swift
//  AAINA
//
//  Ingredient Scanner — camera-first UI with square frame,
//  stability-gated OCR, and routine-match result screen.
//

import UIKit
import AVFoundation
import Vision
import CoreImage

class ScannerViewController: UIViewController {

    // ── IBOutlets kept so the XIB/storyboard still compiles ──
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var scanButton: UIButton!

    // ── Camera ──
    private let sessionQueue  = DispatchQueue(label: "scanner.session")
    private let videoQueue    = DispatchQueue(label: "scanner.video")
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private weak var cameraDevice: AVCaptureDevice?
    private let ciContext = CIContext()
    private var cameraAuthorizationInFlight = false

    // ── UI ──
    private let cameraContainer   = UIView()          // square frame
    private let cornerOverlay     = ScanFrameView()   // animated corners
    private let statusLabel       = UILabel()
    private let hintLabel         = UILabel()
    private let actionButton      = UIButton(type: .custom)
    private let dimView           = UIView()

    // ── OCR state ──
    var step: String = ""
    private var isScanning        = false
    private var isFinishingScan   = false
    private var lastOCRDate       = Date.distantPast
    private var lastStableText    = ""
    private var stableReadCount   = 0
    private var scannedLabelText  = ""
    private var scannedIngredients: [String] = []

    private let routineManager    = RoutineManager()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ingredient Scanner"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
        view.applyAINABackground()
        buildUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ensureCameraPreview()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutCameraFrame()
        previewLayer?.frame = cameraContainer.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCamera()
    }

    // Keep IBAction wired up in case storyboard still references it
    @IBAction func startScanningTapped(_ sender: UIButton) {
        beginScanning()
    }
}

// MARK: - UI Construction

private extension ScannerViewController {

    func buildUI() {
        // ── background dim (behind camera frame) ──
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // ── square camera container ──
        cameraContainer.backgroundColor = .black
        cameraContainer.layer.cornerRadius = 20
        cameraContainer.layer.cornerCurve = .continuous
        cameraContainer.clipsToBounds = true
        cameraContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraContainer)

        // ── corner overlay drawn on top of preview ──
        cornerOverlay.translatesAutoresizingMaskIntoConstraints = false
        cornerOverlay.backgroundColor = .clear
        cornerOverlay.isUserInteractionEnabled = false
        cameraContainer.addSubview(cornerOverlay)
        NSLayoutConstraint.activate([
            cornerOverlay.topAnchor.constraint(equalTo: cameraContainer.topAnchor),
            cornerOverlay.leadingAnchor.constraint(equalTo: cameraContainer.leadingAnchor),
            cornerOverlay.trailingAnchor.constraint(equalTo: cameraContainer.trailingAnchor),
            cornerOverlay.bottomAnchor.constraint(equalTo: cameraContainer.bottomAnchor)
        ])

        // ── status label (inside/below frame when scanning) ──
        statusLabel.text = ""
        statusLabel.textColor = .ainaTextPrimary
        statusLabel.font = .systemFont(ofSize: 14, weight: .medium)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 2
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)

        // ── hint label ──
        hintLabel.text = "Place your product label inside the frame.\nTap Start Scanning when it looks clear."
        hintLabel.textColor = .ainaTextSecondary
        hintLabel.font = .systemFont(ofSize: 15)
        hintLabel.textAlignment = .center
        hintLabel.numberOfLines = 0
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hintLabel)

        // ── action button ──
        actionButton.setTitle("Start Scanning", for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        actionButton.backgroundColor = .ainaCoralPink
        actionButton.layer.cornerRadius = 16
        actionButton.layer.cornerCurve = .continuous
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        // subtle shadow
        actionButton.layer.shadowColor  = UIColor.ainaDustyRose.cgColor
        actionButton.layer.shadowOpacity = 0.35
        actionButton.layer.shadowOffset  = CGSize(width: 0, height: 6)
        actionButton.layer.shadowRadius  = 10
        view.addSubview(actionButton)

        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            actionButton.heightAnchor.constraint(equalToConstant: 56),

            hintLabel.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -20),
            hintLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            hintLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            statusLabel.bottomAnchor.constraint(equalTo: hintLabel.topAnchor, constant: -8),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])

        // hide IBOutlets so they don't interfere
        infoLabel?.isHidden = true
        scanButton?.isHidden = true
    }

    /// Called every layout pass — positions the square camera frame
    func layoutCameraFrame() {
        guard cameraContainer.superview != nil else { return }

        let safeTop = view.safeAreaInsets.top
        let buttonAreaHeight: CGFloat = 56 + 24 + 16   // button + bottom + gap
        let hintHeight: CGFloat = 70
        let labelHeight: CGFloat = 40
        let topPadding: CGFloat = 16

        let availableHeight = view.bounds.height
            - safeTop
            - buttonAreaHeight
            - hintHeight
            - labelHeight
            - topPadding * 2

        let side = min(view.bounds.width - 48, availableHeight)
        let x    = (view.bounds.width - side) / 2
        let y    = safeTop + topPadding

        cameraContainer.frame = CGRect(x: x, y: y, width: side, height: side)
    }
}

// MARK: - Camera Flow

private extension ScannerViewController {

    @objc func actionButtonTapped() {
        if !isScanning {
            beginScanning()
        }
    }

    func beginScanning() {
        guard !isScanning else { return }
        isScanning = true
        resetScanState()

        actionButton.isEnabled = false
        actionButton.alpha     = 0.5
        actionButton.setTitle("Scanning…", for: .normal)
        hintLabel.text         = "Hold the label steady inside the frame."
        statusLabel.text       = "Starting scan…"
        ensureCameraPreview()
    }

    func ensureCameraPreview() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCameraIfNeeded()
        case .notDetermined:
            requestCameraAccessIfNeeded()
        default:
            showPermissionDenied()
        }
    }

    func requestCameraAccessIfNeeded() {
        guard !cameraAuthorizationInFlight else { return }
        cameraAuthorizationInFlight = true
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                guard let self else { return }
                self.cameraAuthorizationInFlight = false
                granted ? self.setupCameraIfNeeded() : self.showPermissionDenied()
            }
        }
    }

    func setupCameraIfNeeded() {
        if let session = captureSession {
            if !session.isRunning {
                sessionQueue.async { session.startRunning() }
            }
            updatePreviewUI()
            return
        }

        let session = AVCaptureSession()
        session.sessionPreset = .photo

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input  = try? AVCaptureDeviceInput(device: device)
        else { showPermissionDenied(); return }

        cameraDevice = device
        configureCamera(device)

        if session.canAddInput(input)  { session.addInput(input) }

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        output.setSampleBufferDelegate(self, queue: videoQueue)
        if session.canAddOutput(output) { session.addOutput(output) }
        if let connection = output.connection(with: .video),
           connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
        }

        captureSession = session

        if previewLayer == nil {
            let preview = AVCaptureVideoPreviewLayer(session: session)
            preview.videoGravity = .resizeAspectFill
            preview.frame        = cameraContainer.bounds
            cameraContainer.layer.insertSublayer(preview, at: 0)
            previewLayer = preview
        }

        sessionQueue.async { session.startRunning() }
        updatePreviewUI()
    }

    func stopCamera() {
        sessionQueue.async { [weak self] in
            self?.captureSession?.stopRunning()
        }
    }

    func configureCamera(_ device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                device.whiteBalanceMode = .continuousAutoWhiteBalance
            }
            device.unlockForConfiguration()
        } catch {
            return
        }
    }

    func updatePreviewUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.cornerOverlay.startAnimating()
            if self.isScanning {
                self.statusLabel.text = "Hold steady inside the frame."
            } else {
                self.statusLabel.text = ""
                self.hintLabel.text = "Place your product label inside the frame.\nTap Start Scanning when it looks clear."
            }
        }
    }

    func resetScanState() {
        scannedIngredients = []
        scannedLabelText   = ""
        isFinishingScan    = false
        lastOCRDate        = .distantPast
        lastStableText     = ""
        stableReadCount    = 0
    }

    func showPermissionDenied() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.isScanning            = false
            self.actionButton.isEnabled = true
            self.actionButton.alpha    = 1
            self.actionButton.setTitle("Start Scanning", for: .normal)
            self.statusLabel.text      = ""
            self.hintLabel.text        = "Camera access is required.\nPlease enable it in Settings and try again."
        }
    }
}

// MARK: - OCR Delegate

extension ScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        guard CMSampleBufferGetImageBuffer(sampleBuffer) != nil,
              isScanning,
              !isFinishingScan,
              Date().timeIntervalSince(lastOCRDate) > 0.45 else { return }

        lastOCRDate = Date()
        guard let cgImage = makeCenterCropImage(from: sampleBuffer) else {
            setStatus("Point the label inside the square frame.")
            return
        }

        let request = VNRecognizeTextRequest { [weak self] req, _ in
            guard let self,
                  let obs = req.results as? [VNRecognizedTextObservation] else { return }

            let candidates   = obs.compactMap { $0.topCandidates(1).first }
            let text         = candidates.map(\.string).joined(separator: " ")
            let confidence   = candidates.isEmpty ? 0
                : candidates.map(\.confidence).reduce(0, +) / Float(candidates.count)

            self.evaluateOCR(text: text, confidence: confidence)
        }
        request.recognitionLevel      = .accurate
        request.usesLanguageCorrection = true
        request.minimumTextHeight = 0.02
        request.recognitionLanguages = ["en-US"]

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }

    private func makeCenterCropImage(from sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }

        let oriented = CIImage(cvPixelBuffer: pixelBuffer).oriented(.right)
        let cropInsetRatio: CGFloat = 0.12
        let cropSide = min(oriented.extent.width, oriented.extent.height) * (1 - cropInsetRatio * 2)
        let cropRect = CGRect(
            x: oriented.extent.midX - (cropSide / 2),
            y: oriented.extent.midY - (cropSide / 2),
            width: cropSide,
            height: cropSide
        ).integral

        guard cropRect.width > 0, cropRect.height > 0 else { return nil }
        let cropped = oriented.cropped(to: cropRect)
        return ciContext.createCGImage(cropped, from: cropped.extent)
    }

    private func evaluateOCR(text: String, confidence: Float) {
        let norm = normalized(text)
        guard norm.count > 24 else {
            setStatus("Move closer to the ingredients list.")
            stableReadCount = 0
            return
        }

        guard confidence > 0.35 else {
            setStatus("Hold steady for a sharper read.")
            stableReadCount = 0
            return
        }

        let adjusting = (cameraDevice?.isAdjustingFocus ?? false) ||
                        (cameraDevice?.isAdjustingExposure ?? false)
        if adjusting {
            stableReadCount = 0
            setStatus("Focusing… hold still.")
            return
        }

        let similarity = jaccard(norm, lastStableText)
        if similarity > 0.82 {
            stableReadCount += 1
        } else {
            stableReadCount  = 1
            lastStableText   = norm
        }

        switch stableReadCount {
        case 1:    setStatus("Reading label…")
        case 2:    setStatus("Almost stable…")
        default:   setStatus("✓ Capturing…")
        }

        guard stableReadCount >= 3, !isFinishingScan else { return }
        isFinishingScan    = true
        scannedLabelText   = text.trimmingCharacters(in: .whitespacesAndNewlines)
        scannedIngredients = routineManager.identifyIngredients(in: norm)

        DispatchQueue.main.async { [weak self] in self?.finishScan() }
    }

    private func setStatus(_ msg: String) {
        DispatchQueue.main.async { [weak self] in
            self?.statusLabel.text = msg
        }
    }

    private func normalized(_ text: String) -> String {
        text.lowercased()
            .replacingOccurrences(of: "[^a-z0-9,]+", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+",        with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func jaccard(_ a: String, _ b: String) -> Double {
        guard !a.isEmpty, !b.isEmpty else { return 0 }
        let sa = Set(a.split(separator: " ").map(String.init))
        let sb = Set(b.split(separator: " ").map(String.init))
        let i  = sa.intersection(sb).count
        let u  = sa.union(sb).count
        return u == 0 ? 0 : Double(i) / Double(u)
    }
}

// MARK: - Result Presentation

private extension ScannerViewController {

    func finishScan() {
        stopCamera()
        cornerOverlay.stopAnimating()
        statusLabel.text = ""

        let result = routineManager.analyze(scannedIngredients: scannedIngredients, for: step)
        showResultSheet(result)
    }

    func showResultSheet(_ result: ScanAnalysisResult) {
        let vc = ScanResultViewController(result: result)
        vc.onScanAgain = { [weak self] in
            self?.resetAfterResult()
        }
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents             = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
        present(vc, animated: true)
    }

    func resetAfterResult() {
        // clean up previous camera layer
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
        captureSession = nil

        resetScanState()
        isScanning             = false
        actionButton.isEnabled = true
        actionButton.alpha     = 1
        actionButton.setTitle("Start Scanning", for: .normal)
        statusLabel.text       = ""
        hintLabel.text         = "Place your product label inside the frame.\nTap Start Scanning when it looks clear."
        cornerOverlay.stopAnimating()
        ensureCameraPreview()
    }
}

// MARK: - Scan Frame View (animated corner brackets)

final class ScanFrameView: UIView {

    private let shapeLayer  = CAShapeLayer()
    private let scanLine    = CALayer()
    private var scanning    = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        shapeLayer.strokeColor = UIColor.ainaCoralPink.cgColor
        shapeLayer.fillColor   = UIColor.clear.cgColor
        shapeLayer.lineWidth   = 3
        shapeLayer.lineCap     = .round
        layer.addSublayer(shapeLayer)

        scanLine.backgroundColor = UIColor.ainaCoralPink.withAlphaComponent(0.6).cgColor
        scanLine.isHidden        = true
        layer.addSublayer(scanLine)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        drawCorners()
        scanLine.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 2)
    }

    private func drawCorners() {
        let w = bounds.width, h = bounds.height
        let c: CGFloat = 28   // corner arm length

        let path = UIBezierPath()
        // top-left
        path.move(to: CGPoint(x: 0, y: c));      path.addLine(to: CGPoint(x: 0, y: 0));      path.addLine(to: CGPoint(x: c, y: 0))
        // top-right
        path.move(to: CGPoint(x: w - c, y: 0));  path.addLine(to: CGPoint(x: w, y: 0));      path.addLine(to: CGPoint(x: w, y: c))
        // bottom-right
        path.move(to: CGPoint(x: w, y: h - c));  path.addLine(to: CGPoint(x: w, y: h));      path.addLine(to: CGPoint(x: w - c, y: h))
        // bottom-left
        path.move(to: CGPoint(x: c, y: h));      path.addLine(to: CGPoint(x: 0, y: h));      path.addLine(to: CGPoint(x: 0, y: h - c))

        shapeLayer.path  = path.cgPath
        shapeLayer.frame = bounds
    }

    func startAnimating() {
        scanning             = true
        scanLine.isHidden    = false
        scanLine.frame       = CGRect(x: 0, y: 0, width: bounds.width, height: 2)
        shapeLayer.opacity   = 1

        let anim             = CABasicAnimation(keyPath: "position.y")
        anim.fromValue       = 0
        anim.toValue         = bounds.height
        anim.duration        = 1.8
        anim.autoreverses    = true
        anim.repeatCount     = .infinity
        scanLine.add(anim, forKey: "scan")

        // pulse corners
        let pulse            = CABasicAnimation(keyPath: "opacity")
        pulse.fromValue      = 1
        pulse.toValue        = 0.4
        pulse.duration       = 0.9
        pulse.autoreverses   = true
        pulse.repeatCount    = .infinity
        shapeLayer.add(pulse, forKey: "pulse")
    }

    func stopAnimating() {
        scanning          = false
        scanLine.isHidden = true
        scanLine.removeAllAnimations()
        shapeLayer.removeAllAnimations()
        shapeLayer.opacity = 1
    }
}

// MARK: - Result Sheet

final class ScanResultViewController: UIViewController {

    var onScanAgain: (() -> Void)?

    private let result: ScanAnalysisResult
    private let scrollView   = UIScrollView()
    private let stack        = UIStackView()

    init(result: ScanAnalysisResult) {
        self.result = result
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyAINABackground()
        buildLayout()
    }

    private func buildLayout() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        stack.axis    = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48)
        ])

        addBadge()
        addTitle()
        addDetailCard()
        if !result.detectedIngredients.isEmpty { addIngredientsCard() }
        addButtons()
    }

    private func addBadge() {
        let badge = UIView()
        badge.layer.cornerRadius = 36
        badge.layer.cornerCurve  = .continuous
        badge.translatesAutoresizingMaskIntoConstraints = false

        let icon = UILabel()
        icon.font = .systemFont(ofSize: 36)
        icon.textAlignment = .center
        icon.translatesAutoresizingMaskIntoConstraints = false

        if result.isRecommended {
            badge.backgroundColor = UIColor.ainaSageGreen.withAlphaComponent(0.15)
            icon.text = "✅"
        } else if !result.conflicts.isEmpty {
            badge.backgroundColor = UIColor.ainaSoftRed.withAlphaComponent(0.15)
            icon.text = "⚠️"
        } else {
            badge.backgroundColor = UIColor.ainaTextSecondary.withAlphaComponent(0.12)
            icon.text = "🚫"
        }

        badge.addSubview(icon)
        NSLayoutConstraint.activate([
            badge.widthAnchor.constraint(equalToConstant: 72),
            badge.heightAnchor.constraint(equalToConstant: 72),
            icon.centerXAnchor.constraint(equalTo: badge.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: badge.centerYAnchor)
        ])

        let wrapper = UIView()
        wrapper.addSubview(badge)
        badge.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            badge.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor),
            badge.topAnchor.constraint(equalTo: wrapper.topAnchor),
            badge.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor)
        ])
        stack.addArrangedSubview(wrapper)
    }

    private func addTitle() {
        let label = UILabel()
        label.text = result.title
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = result.isRecommended ? .ainaSageGreen
            : (!result.conflicts.isEmpty ? .ainaSoftRed : .ainaTextPrimary)
        label.textAlignment = .center
        label.numberOfLines = 0
        stack.addArrangedSubview(label)
    }

    private func addDetailCard() {
        let card = makeCard()
        let label = UILabel()
        label.text = result.detail
        label.font = .systemFont(ofSize: 15)
        label.textColor = .ainaTextPrimary
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        stack.addArrangedSubview(card)
    }

    private func addIngredientsCard() {
        let card = makeCard()
        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.spacing = 8
        vStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            vStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            vStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        let header = UILabel()
        header.text = "Detected Ingredients"
        header.font = .systemFont(ofSize: 13, weight: .semibold)
        header.textColor = .ainaTextSecondary
        vStack.addArrangedSubview(header)

        for ingredient in result.detectedIngredients {
            let row = UIStackView()
            row.axis    = .horizontal
            row.spacing = 8

            let dot = UILabel()
            let isMatch    = result.matchedIngredients.contains(ingredient)
            let isConflict = result.conflicts.contains(where: { $0.lowercased().contains(ingredient) })

            dot.text      = isConflict ? "⚠️" : (isMatch ? "✓" : "•")
            dot.textColor = isConflict ? .ainaSoftRed : (isMatch ? .ainaSageGreen : .ainaTextSecondary)
            dot.font      = .systemFont(ofSize: 15, weight: .semibold)
            dot.setContentHuggingPriority(.required, for: .horizontal)

            let name = UILabel()
            name.text      = ingredient.capitalized
            name.font      = .systemFont(ofSize: 15)
            name.textColor = .ainaTextPrimary
            name.numberOfLines = 0

            row.addArrangedSubview(dot)
            row.addArrangedSubview(name)
            vStack.addArrangedSubview(row)
        }
        stack.addArrangedSubview(card)
    }

    private func addButtons() {
        let scanAgain = UIButton(type: .custom)
        scanAgain.setTitle("Scan Again", for: .normal)
        scanAgain.setTitleColor(.white, for: .normal)
        scanAgain.titleLabel?.font   = .systemFont(ofSize: 17, weight: .semibold)
        scanAgain.backgroundColor    = .ainaCoralPink
        scanAgain.layer.cornerRadius = 16
        scanAgain.layer.cornerCurve  = .continuous
        scanAgain.translatesAutoresizingMaskIntoConstraints = false
        scanAgain.heightAnchor.constraint(equalToConstant: 52).isActive = true
        scanAgain.addTarget(self, action: #selector(scanAgainTapped), for: .touchUpInside)

        let done = UIButton(type: .system)
        done.setTitle("Done", for: .normal)
        done.setTitleColor(.ainaTextSecondary, for: .normal)
        done.titleLabel?.font = .systemFont(ofSize: 16)
        done.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)

        stack.addArrangedSubview(scanAgain)
        stack.addArrangedSubview(done)
    }

    private func makeCard() -> UIView {
        let card = UIView()
        card.backgroundColor    = UIColor.white.withAlphaComponent(0.65)
        card.layer.cornerRadius = 16
        card.layer.cornerCurve  = .continuous
        card.layer.shadowColor  = UIColor.ainaCardShadowColor.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowRadius  = 8
        card.layer.shadowOffset  = CGSize(width: 0, height: 4)
        return card
    }

    @objc private func scanAgainTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onScanAgain?()
        }
    }

    @objc private func doneTapped() {
        dismiss(animated: true)
    }
}
