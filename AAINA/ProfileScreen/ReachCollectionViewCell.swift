import UIKit

class ReachCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var row1Stack: UIStackView!
    @IBOutlet weak var row2Stack: UIStackView!
    
    @IBOutlet weak var icon1: UIImageView!
    @IBOutlet weak var icon2: UIImageView!
    @IBOutlet weak var icon3: UIImageView!
    @IBOutlet weak var icon4: UIImageView!
    
    // MARK: - Callback
    
    var onItemSelected: ((Int) -> Void)?
    
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        configureIcons()
        setupTapGestures()
    }
    
    
    // MARK: - UI Setup
    
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
        
        icon1.image = UIImage(systemName: "envelope")
        icon2.image = UIImage(systemName: "ladybug")
        icon3.image = UIImage(systemName: "chevron.right")
        icon4.image = UIImage(systemName: "chevron.right")
        
        let icons = [icon1, icon2,icon3,icon4]
        
        icons.forEach {
            $0?.contentMode = .scaleAspectFit
        }
    }
    
    
    // MARK: - Tap Gestures
    
    private func setupTapGestures() {
        
        row1Stack.isUserInteractionEnabled = true
        row2Stack.isUserInteractionEnabled = true
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(rowTapped(_:)))
        row1Stack.addGestureRecognizer(tap1)
        row1Stack.tag = 0
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(rowTapped(_:)))
        row2Stack.addGestureRecognizer(tap2)
        row2Stack.tag = 1
    }
    
    
    @objc private func rowTapped(_ sender: UITapGestureRecognizer) {
        if let index = sender.view?.tag {
            onItemSelected?(index)
        }
    }
}
