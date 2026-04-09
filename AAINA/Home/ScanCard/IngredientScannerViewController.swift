//
//  IngredientScannerViewController.swift
//  ScanCard
//
//  Created by GEU on 18/03/26.
//
import UIKit

class IngredientScannerViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var items: [ScanItem] = []
    private var selectedItem: ScanItem?
    var dataModel: DataModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Scan"
        
        setupCollectionView()
        loadData()
        
        navigationItem.largeTitleDisplayMode = .never
    }
}

private extension IngredientScannerViewController {
    
    func setupCollectionView() {
        registerCells()
        
        collectionView.collectionViewLayout = generateLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.contentInset = .zero
    }
    
    func registerCells() {
        collectionView.register(
            UINib(nibName: "ScanCardCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "scan_card_cell"
        )
    }
}

private extension IngredientScannerViewController {
    
    func loadData() {
        items = dataModel.getScanItems()
        collectionView.reloadData()
    }
}

private extension IngredientScannerViewController {
    
    func generateLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = .zero
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.5)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 1
        )
        
        group.interItemSpacing = .fixed(0)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = .zero
        section.interGroupSpacing = 0
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension IngredientScannerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "scan_card_cell",
            for: indexPath
        ) as! ScanCardCollectionViewCell
        
        let item = items[indexPath.item]
        
        cell.configure(
            title: item.title,
            subtitle: item.subtitle,
            image: UIImage(named: item.imageName)
        )
        
        return cell
    }
}

extension IngredientScannerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItem = items[indexPath.item]
        performSegue(withIdentifier: "scan_to_scanner", sender: nil)
    }
}

extension IngredientScannerViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "scan_to_scanner",
           let scannerVC = segue.destination as? ScannerViewController,
           let item = selectedItem {
            scannerVC.title = item.title
            scannerVC.step = item.title
        }
    }
}
