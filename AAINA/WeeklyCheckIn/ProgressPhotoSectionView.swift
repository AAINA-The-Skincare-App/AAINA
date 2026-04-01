//
//  ProgressPhotoSectionView.swift
//  AAINA
//

import UIKit
import PhotosUI

final class ProgressPhotoSectionView: UIView {

    // MARK: - Outlets
    @IBOutlet private weak var photoContainerView: UIView!
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var addPhotoLabel: UILabel!
    @IBOutlet private weak var addPhotoSubLabel: UILabel!
    @IBOutlet private weak var iconBackground: UIView!

    // MARK: - Public property
    var selectedImage: UIImage? { photoImageView.image }

    // Reference to VC for presenting picker
    weak var presentingViewController: UIViewController?

    // MARK: - Factory
    static func create() -> ProgressPhotoSectionView {
        let views = Bundle.main.loadNibNamed("ProgressPhotoSectionView", owner: nil, options: nil)!
        return views.first as! ProgressPhotoSectionView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupPhotoContainer()
    }

    private func setupPhotoContainer() {
        photoContainerView.layer.cornerRadius = 16
        photoContainerView.backgroundColor = UIColor.ainaGlassElevated
        photoContainerView.layer.borderWidth = 1.5
        photoContainerView.layer.borderColor = UIColor.ainaTextTertiary.withAlphaComponent(0.5).cgColor
        photoContainerView.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(photoTapped))
        photoContainerView.addGestureRecognizer(tap)

        iconBackground.backgroundColor = UIColor.ainaTintedGlassLight
        iconBackground.layer.cornerRadius = 30

        photoImageView.contentMode = .scaleAspectFill
        photoImageView.layer.cornerRadius = 16
        photoImageView.clipsToBounds = true
        photoImageView.isHidden = true

        addPhotoLabel.text = "Add this week's photo"
        addPhotoLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        addPhotoLabel.textColor = .ainaTextPrimary

        addPhotoSubLabel.text = "Track your skin's progress visually"
        addPhotoSubLabel.font = .systemFont(ofSize: 13)
        addPhotoSubLabel.textColor = .ainaTextSecondary
    }

    // MARK: - Actions
    @objc private func photoTapped() {
        guard let vc = presentingViewController else { return }
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        vc.present(picker, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension ProgressPhotoSectionView: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] obj, _ in
            guard let image = obj as? UIImage else { return }
            DispatchQueue.main.async {
                self?.photoImageView.image = image
                self?.photoImageView.isHidden = false
                self?.photoContainerView.subviews
                    .filter { $0 !== self?.photoImageView }
                    .forEach { $0.isHidden = true }
            }
        }
    }
}
