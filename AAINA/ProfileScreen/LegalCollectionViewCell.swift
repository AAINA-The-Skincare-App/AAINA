import UIKit

class LegalCollectionViewCell: UICollectionViewCell {

    //Connections
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var row1Stack: UIStackView!
    @IBOutlet weak var row2Stack: UIStackView!
    
    @IBOutlet weak var icon1: UIImageView!
    @IBOutlet weak var icon2: UIImageView!
    
    @IBOutlet weak var title1Label: UILabel!
    @IBOutlet weak var title2Label: UILabel!
    
    // MARK: - Callback
    
    var onItemSelected: ((Int) -> Void)?
    
    
    //Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        configureContent()
        setupTapGestures()
    }
    
    
    // UI Styling
    
    private func setupUI() {
        
        containerView.layer.cornerRadius = 20
        containerView.backgroundColor = .systemBackground
        
        // Optional light shadow
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 5)
        containerView.layer.shadowRadius = 10
    }
    
    
    // Content
    
    private func configureContent() {
        
        // Row 1
        icon1.image = UIImage(systemName: "hand.raised")
        icon1.tintColor = .systemGray
        icon1.contentMode = .scaleAspectFit
        
        title1Label.text = "Privacy Policy"
        title1Label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        
        // Row 2
        icon2.image = UIImage(systemName: "doc.text")
        icon2.tintColor = .systemGray
        icon2.contentMode = .scaleAspectFit
        
        title2Label.text = "Terms of Use"
        title2Label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    
    // Tap Handling
    
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
