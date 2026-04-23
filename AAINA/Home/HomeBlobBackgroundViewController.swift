//
//  HomeBlobBackgroundViewController.swift
//  AAINA
//

import UIKit

final class HomeBlobBackgroundViewController: UIViewController {

    private let blob1 = UIView()
    private let blob2 = UIView()
    private var didSetupBlobs = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyAINABackground()
        setupBlobsIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyAINABackground()
        view.sendSubviewToBack(blob2)
        view.sendSubviewToBack(blob1)
    }

    private func setupBlobsIfNeeded() {
        guard !didSetupBlobs else { return }
        didSetupBlobs = true

        blob1.backgroundColor = UIColor.ainaCoralPink.withAlphaComponent(0.34)
        blob1.layer.cornerRadius = 150
        blob1.layer.cornerCurve = .continuous
        blob1.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blob1, at: 0)

        blob2.backgroundColor = UIColor.ainaDustyRose.withAlphaComponent(0.28)
        blob2.layer.cornerRadius = 120
        blob2.layer.cornerCurve = .continuous
        blob2.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blob2, aboveSubview: blob1)

        NSLayoutConstraint.activate([
            blob1.widthAnchor.constraint(equalToConstant: 300),
            blob1.heightAnchor.constraint(equalToConstant: 300),
            blob1.topAnchor.constraint(equalTo: view.topAnchor, constant: -60),
            blob1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -60),

            blob2.widthAnchor.constraint(equalToConstant: 240),
            blob2.heightAnchor.constraint(equalToConstant: 240),
            blob2.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 50),
            blob2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 50)
        ])

        UIView.animate(
            withDuration: 8,
            delay: 0,
            options: [.autoreverse, .repeat, .allowUserInteraction]
        ) {
            self.blob1.transform = CGAffineTransform(translationX: 18, y: 18)
                .scaledBy(x: 1.05, y: 1.05)
        }

        UIView.animate(
            withDuration: 10,
            delay: 1.5,
            options: [.autoreverse, .repeat, .allowUserInteraction]
        ) {
            self.blob2.transform = CGAffineTransform(translationX: -12, y: -20)
                .scaledBy(x: 1.07, y: 1.07)
        }
    }
}
