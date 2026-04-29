//
//  ProgressPhotoSectionView.swift
//  AAINA
//

import UIKit
import PhotosUI

final class ProgressPhotoSectionView: UIView {

    // MARK: - Public
    private(set) var selectedImages: [UIImage] = []
    var selectedImage: UIImage? { selectedImages.first }
    weak var presentingViewController: UIViewController?

    private let maxPhotos = 5

    // MARK: - Views
    private let card        = UIView()
    private let photoScroll = UIScrollView()
    private let photoStrip  = UIStackView()

    // MARK: - Factory
    static func create() -> ProgressPhotoSectionView {
        let v = ProgressPhotoSectionView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setup()
        return v
    }

    // MARK: - Setup

    private func setup() {
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyGlass(cornerRadius: 20)
        addSubview(card)

        // Header
        let badge = makeIconBadge()
        let titleLbl = UILabel()
        titleLbl.attributedText = NSAttributedString(string: "PROGRESS PHOTOS", attributes: [
            .font: UIFont.systemFont(ofSize: 11, weight: .bold),
            .foregroundColor: UIColor.secondaryLabel,
            .kern: 1.4
        ])
        titleLbl.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLbl = UILabel()
        subtitleLbl.text          = "Capture your skin journey — add up to 5 photos"
        subtitleLbl.font          = .systemFont(ofSize: 13)
        subtitleLbl.textColor     = .secondaryLabel
        subtitleLbl.numberOfLines = 0
        subtitleLbl.translatesAutoresizingMaskIntoConstraints = false

        let sep = UIView()
        sep.backgroundColor = UIColor.ainaCoralPink.withAlphaComponent(0.12)
        sep.translatesAutoresizingMaskIntoConstraints = false

        // Photo strip
        photoScroll.showsHorizontalScrollIndicator = false
        photoScroll.translatesAutoresizingMaskIntoConstraints = false

        photoStrip.axis      = .horizontal
        photoStrip.spacing   = 10
        photoStrip.alignment = .center
        photoStrip.translatesAutoresizingMaskIntoConstraints = false
        photoScroll.addSubview(photoStrip)

        [badge, titleLbl, subtitleLbl, sep, photoScroll].forEach { card.addSubview($0) }

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: topAnchor),
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor),

            badge.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            badge.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),

            titleLbl.centerYAnchor.constraint(equalTo: badge.centerYAnchor),
            titleLbl.leadingAnchor.constraint(equalTo: badge.trailingAnchor, constant: 10),

            subtitleLbl.topAnchor.constraint(equalTo: badge.bottomAnchor, constant: 4),
            subtitleLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            subtitleLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            sep.topAnchor.constraint(equalTo: subtitleLbl.bottomAnchor, constant: 12),
            sep.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            sep.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            sep.heightAnchor.constraint(equalToConstant: 1),

            photoScroll.topAnchor.constraint(equalTo: sep.bottomAnchor, constant: 14),
            photoScroll.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            photoScroll.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            photoScroll.heightAnchor.constraint(equalToConstant: 110),
            photoScroll.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),

            photoStrip.topAnchor.constraint(equalTo: photoScroll.topAnchor),
            photoStrip.leadingAnchor.constraint(equalTo: photoScroll.leadingAnchor, constant: 16),
            photoStrip.trailingAnchor.constraint(equalTo: photoScroll.trailingAnchor, constant: -16),
            photoStrip.bottomAnchor.constraint(equalTo: photoScroll.bottomAnchor),
            photoStrip.heightAnchor.constraint(equalTo: photoScroll.heightAnchor)
        ])

        rebuildStrip()
    }

    // MARK: - Strip builder

    private func rebuildStrip() {
        photoStrip.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (i, img) in selectedImages.enumerated() {
            photoStrip.addArrangedSubview(makePhotoTile(img, index: i))
        }

        if selectedImages.count < maxPhotos {
            photoStrip.addArrangedSubview(makeAddTile())
        }
    }

    private func makePhotoTile(_ image: UIImage, index: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 96),
            container.heightAnchor.constraint(equalToConstant: 96)
        ])

        let iv = UIImageView(image: image)
        iv.contentMode      = .scaleAspectFill
        iv.clipsToBounds    = true
        iv.layer.cornerRadius = 16
        iv.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(iv)

        let del = UIButton(type: .system)
        del.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        del.tintColor          = .ainaDustyRose
        del.backgroundColor    = UIColor.white.withAlphaComponent(0.9)
        del.layer.cornerRadius = 11
        del.tag = index
        del.addTarget(self, action: #selector(removePhoto(_:)), for: .touchUpInside)
        del.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(del)

        NSLayoutConstraint.activate([
            iv.topAnchor.constraint(equalTo: container.topAnchor),
            iv.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iv.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            iv.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            del.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            del.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            del.widthAnchor.constraint(equalToConstant: 22),
            del.heightAnchor.constraint(equalToConstant: 22)
        ])
        return container
    }

    private func makeAddTile() -> UIView {
        let tile = UIView()
        tile.backgroundColor    = UIColor.ainaCoralPink.withAlphaComponent(0.08)
        tile.layer.cornerRadius = 16
        tile.layer.borderWidth  = 1.5
        tile.layer.borderColor  = UIColor.ainaCoralPink.withAlphaComponent(0.35).cgColor
        tile.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tile.widthAnchor.constraint(equalToConstant: 96),
            tile.heightAnchor.constraint(equalToConstant: 96)
        ])

        let icon = UIImageView(image: UIImage(systemName: "camera.fill"))
        icon.tintColor   = .ainaDustyRose
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        tile.addSubview(icon)

        let lbl = UILabel()
        lbl.text      = "Add Photo"
        lbl.font      = .systemFont(ofSize: 11, weight: .medium)
        lbl.textColor = .ainaDustyRose
        lbl.translatesAutoresizingMaskIntoConstraints = false
        tile.addSubview(lbl)

        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: tile.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: tile.centerYAnchor, constant: -10),
            icon.widthAnchor.constraint(equalToConstant: 26),
            icon.heightAnchor.constraint(equalToConstant: 26),
            lbl.centerXAnchor.constraint(equalTo: tile.centerXAnchor),
            lbl.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 5)
        ])

        tile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addTapped)))
        tile.isUserInteractionEnabled = true
        return tile
    }

    private func makeIconBadge() -> UIView {
        let v = UIView()
        v.backgroundColor    = .ainaTintedGlassMedium
        v.layer.cornerRadius = 18
        v.translatesAutoresizingMaskIntoConstraints = false
        let icon = UIImageView(image: UIImage(systemName: "camera.fill"))
        icon.tintColor   = .ainaDustyRose
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(icon)
        NSLayoutConstraint.activate([
            v.widthAnchor.constraint(equalToConstant: 36),
            v.heightAnchor.constraint(equalToConstant: 36),
            icon.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: v.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.heightAnchor.constraint(equalToConstant: 16)
        ])
        return v
    }

    // MARK: - Actions

    @objc private func addTapped() {
        guard let vc = presentingViewController else { return }
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            self?.presentCamera()
        })
        sheet.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            self?.presentPicker()
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        vc.present(sheet, animated: true)
    }

    @objc private func removePhoto(_ sender: UIButton) {
        guard sender.tag < selectedImages.count else { return }
        selectedImages.remove(at: sender.tag)
        rebuildStrip()
    }

    private func presentCamera() {
        guard let vc = presentingViewController,
              UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let cam           = UIImagePickerController()
        cam.sourceType    = .camera
        cam.allowsEditing = true
        cam.delegate      = self
        vc.present(cam, animated: true)
    }

    private func presentPicker() {
        guard let vc = presentingViewController else { return }
        var cfg            = PHPickerConfiguration()
        cfg.filter         = .images
        cfg.selectionLimit = max(1, maxPhotos - selectedImages.count)
        let picker         = PHPickerViewController(configuration: cfg)
        picker.delegate    = self
        vc.present(picker, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension ProgressPhotoSectionView: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        let remaining = maxPhotos - selectedImages.count
        results.prefix(remaining).forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] obj, _ in
                guard let self, let img = obj as? UIImage else { return }
                DispatchQueue.main.async {
                    self.selectedImages.append(img)
                    self.rebuildStrip()
                }
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ProgressPhotoSectionView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let img = (info[.editedImage] ?? info[.originalImage]) as? UIImage {
            selectedImages.append(img)
            rebuildStrip()
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
