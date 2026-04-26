import UIKit

//
//  CalendarDateCell.swift
//  AAINA
//
//  Created by GEU on 27/03/26.
//

import UIKit

final class CalendarDateCell: UICollectionViewCell {

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(text: String, selected: Bool) {
        label.text = text

        if selected {
            contentView.backgroundColor = .ainaCoralPink.withAlphaComponent(0.75)
            contentView.layer.cornerRadius = 22
            label.textColor = .white
        } else {
            contentView.backgroundColor = .clear
            label.textColor = .label
        }
    }
}
