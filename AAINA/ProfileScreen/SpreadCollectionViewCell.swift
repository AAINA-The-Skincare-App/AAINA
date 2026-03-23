import UIKit

class SpreadCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!

    
    @IBOutlet weak var row1Stack: UIStackView!
    @IBOutlet weak var row2Stack: UIStackView!
    @IBOutlet weak var row3Stack: UIStackView!
    @IBOutlet weak var row4Stack: UIStackView!
    
    @IBOutlet weak var icon1: UIImageView!
    @IBOutlet weak var icon2: UIImageView!
    @IBOutlet weak var icon3: UIImageView!
    @IBOutlet weak var icon4: UIImageView!
    
    // MARK: - Callback
    
    var onItemSelected: ((Int) -> Void)?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureIcons()
        setupUI()
        setupTapGestures()
    }
    private func setupUI() {
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        containerView.backgroundColor = .systemBackground
    }
    
    // MARK: - Configure Icons
    
    private func configureIcons() {
        
        icon1.image = UIImage(systemName: "doc.text")
        icon2.image = UIImage(systemName: "square.and.arrow.up")
        icon3.image = UIImage(systemName: "star")
        icon4.image = UIImage(systemName: "hand.thumbsup")
        
        let icons = [icon1, icon2, icon3, icon4]
        
        icons.forEach {
            $0?.tintColor = .systemGray
            $0?.contentMode = .scaleAspectFit
        }
    }   // ✅ YOU WERE MISSING THIS BRACKET
    
    // MARK: - Tap Setup
    
    private func setupTapGestures() {
        
        let stacks = [row1Stack, row2Stack, row3Stack, row4Stack]
        
        for (index, stack) in stacks.enumerated() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(rowTapped(_:)))
            stack?.addGestureRecognizer(tap)
            stack?.isUserInteractionEnabled = true
            stack?.tag = index
        }
    }
    
    @objc private func rowTapped(_ sender: UITapGestureRecognizer) {
        if let tag = sender.view?.tag {
            onItemSelected?(tag)
        }
    }
}
