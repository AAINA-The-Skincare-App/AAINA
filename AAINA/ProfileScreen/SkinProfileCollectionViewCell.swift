import UIKit

class SkinProfileCollectionViewCell: UICollectionViewCell {

    // MARK: - Container
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Row Stacks
    @IBOutlet weak var row1Stack: UIStackView!
    @IBOutlet weak var row2Stack: UIStackView!
    @IBOutlet weak var row3Stack: UIStackView!
    @IBOutlet weak var row4Stack: UIStackView!
    @IBOutlet weak var row5Stack: UIStackView!
    
    // MARK: - Row 1
    @IBOutlet weak var icon1: UIImageView!
    @IBOutlet weak var title1: UILabel!
    @IBOutlet weak var subtitle1: UILabel!
    
    // MARK: - Row 2
    @IBOutlet weak var icon2: UIImageView!
    @IBOutlet weak var title2: UILabel!
    @IBOutlet weak var subtitle2: UILabel!
    
    // MARK: - Row 3
    @IBOutlet weak var icon3: UIImageView!
    @IBOutlet weak var title3: UILabel!
    @IBOutlet weak var subtitle3: UILabel!
    
    // MARK: - Row 4
    @IBOutlet weak var icon4: UIImageView!
    @IBOutlet weak var title4: UILabel!
    @IBOutlet weak var subtitle4: UILabel!
    
    // MARK: - Row 5
    @IBOutlet weak var icon5: UIImageView!
    @IBOutlet weak var title5: UILabel!
    @IBOutlet weak var subtitle5: UILabel!
    
    // MARK: - Callback
    var onItemSelected: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        setupData()
        setupGestures()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        containerView.layer.shadowRadius = 10
        containerView.layer.masksToBounds = false
        
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }
    
    // MARK: - Data Setup
    private func setupData() {
        
        icon1.image = UIImage(systemName: "drop.fill")
        title1.text = "Skin Type"
        subtitle1.text = "Combination"
        
        icon2.image = UIImage(systemName: "exclamationmark.circle")
        title2.text = "Skin Concerns"
        subtitle2.text = "4 Concerns"
        
        icon3.image = UIImage(systemName: "waveform.path.ecg")
        title3.text = "Skin Sensitivity"
        subtitle3.text = "Normal"
        
        icon4.image = UIImage(systemName: "target")
        title4.text = "Skin Goals"
        subtitle4.text = "3 Goals"
        
        icon5.image = UIImage(systemName: "bookmark")
        title5.text = "Saved Routines"
        subtitle5.text = ""
    }
    
    // MARK: - Gestures
    private func setupGestures() {
        setupTap(for: row1Stack, index: 0)
        setupTap(for: row2Stack, index: 1)
        setupTap(for: row3Stack, index: 2)
        setupTap(for: row4Stack, index: 3)
        setupTap(for: row5Stack, index: 4)
    }
    
    private func setupTap(for stack: UIStackView, index: Int) {
        stack.isUserInteractionEnabled = true
        stack.tag = index
        stack.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(rowTapped(_:)))
        )
    }
    
    @objc private func rowTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        
        animateSelection(view)
        onItemSelected?(view.tag)
    }
    
    // MARK: - Tap Animation
    private func animateSelection(_ view: UIView) {
        UIView.animate(withDuration: 0.15, animations: {
            view.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                view.alpha = 1.0
            }
        }
    }
}
