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

        // Hide row1 and eliminate the spacing gap it leaves behind
        row1Stack.isHidden = true
        if let outerStack = row1Stack.superview as? UIStackView {
            outerStack.setCustomSpacing(0, after: row1Stack)
        }

        configureIcons()
        setupUI()
        setupTapGestures()
    }
    private func setupUI() {
        containerView.backgroundColor = .ainaGlassSurface

        containerView.layer.cornerRadius = 20
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor

        containerView.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        containerView.layer.shadowRadius = 16
    }
    
    // MARK: - Configure Icons
    
    private func configureIcons() {
        
        icon1.image = UIImage(systemName: "doc.text")
        icon2.image = UIImage(systemName: "square.and.arrow.up")
        icon3.image = UIImage(systemName: "star")
        icon4.image = UIImage(systemName: "hand.thumbsup")
        
        let icons = [icon1, icon2, icon3, icon4]
        
        icons.forEach {
            $0?.contentMode = .scaleAspectFit
        }
    }   // YOU WERE MISSING THIS BRACKET
    
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
