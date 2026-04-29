//
//  ProductCardView.swift
//  AAINA
//
//  Created by GEU on 09/04/26.
//
//
//  ProductCardView.swift
//  AAINA
//
//  Created by GEU on 09/04/26.
//

import UIKit

final class ProductCardView: UIView {

    private let imageView    = UIImageView()
    private let brandLabel   = UILabel()
    private let titleLabel   = UILabel()
    private let button       = UIButton(type: .system)

    var onExploreTapped: (() -> Void)?

   

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

   

    private func setup() {
        backgroundColor      = UIColor(red: 252/255, green: 250/255, blue: 255/255, alpha: 1)
        layer.cornerRadius   = 20
        layer.cornerCurve    = .continuous
        layer.shadowColor    = UIColor.black.cgColor
        layer.shadowOpacity  = 0.06
        layer.shadowRadius   = 12
        layer.shadowOffset   = CGSize(width: 0, height: 4)
        layer.masksToBounds  = false

        // Image
        imageView.contentMode          = .scaleAspectFill
        imageView.clipsToBounds        = true
        imageView.layer.cornerRadius   = 14
        imageView.layer.cornerCurve    = .continuous
        imageView.backgroundColor      = UIColor(red: 245/255, green: 241/255, blue: 238/255, alpha: 1)
        imageView.image                = UIImage(systemName: "drop.fill")
        imageView.tintColor            = UIColor(red: 190/255, green: 180/255, blue: 200/255, alpha: 1)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // Brand
        brandLabel.font      = .systemFont(ofSize: 9, weight: .semibold)
        brandLabel.textColor = UIColor(red: 160/255, green: 155/255, blue: 175/255, alpha: 1)
        brandLabel.translatesAutoresizingMaskIntoConstraints = false

        // Title
        titleLabel.font          = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.textColor     = UIColor(red: 28/255, green: 22/255, blue: 48/255, alpha: 1)
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Button
        button.setTitle("Explore Product  ↗", for: .normal)
        button.titleLabel?.font  = .systemFont(ofSize: 12, weight: .semibold)
        button.backgroundColor   = UIColor.ainaCoralPink
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.cornerCurve  = .continuous
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(exploreTapped), for: .touchUpInside)

        addSubview(imageView)
        addSubview(brandLabel)
        addSubview(titleLabel)
        addSubview(button)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            imageView.heightAnchor.constraint(equalToConstant: 300),

            brandLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            brandLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            brandLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            titleLabel.topAnchor.constraint(equalTo: brandLabel.bottomAnchor, constant: 3),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            button.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            button.heightAnchor.constraint(equalToConstant: 36),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

 

    func configure(product: SkincareProduct) {
        brandLabel.text = product.brand.uppercased()
        titleLabel.text = product.name

        // Load remote image
        if let urlString = product.imageURL, let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self?.imageView.image       = image
                    self?.imageView.contentMode = .scaleAspectFill
                    self?.imageView.tintColor   = nil
                }
            }.resume()
        }

        // Wire up explore button
        onExploreTapped = {
            guard let urlString = product.productURL,
                  let url = URL(string: urlString) else { return }
            UIApplication.shared.open(url)
        }
    }



    @objc private func exploreTapped() {
        onExploreTapped?()
    }
}
