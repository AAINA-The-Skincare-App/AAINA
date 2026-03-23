import UIKit

final class RoutineViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

            private let dataModel = DataModel()
            private var selectedSegment: Int = 0
            private var steps: [RoutineStep] = []
            private var aiSteps: [AIRoutineStep] = []
            private var aiOutput: AIRoutineOutput?
            private var checkedSteps: Set<String> = []

            private var currentUserID: String {
                dataModel.currentUser().id
            }

            override func viewDidLoad() {
                super.viewDidLoad()
             
                navigationController?.navigationBar.prefersLargeTitles = true
                   navigationItem.largeTitleDisplayMode = .always

                  collectionView.setContentOffset(CGPoint(x: 0, y: -collectionView.adjustedContentInset.top), animated: false)
               title = "Routine"
               view.backgroundColor = .systemGroupedBackground

                aiOutput = dataModel.loadAIRoutine()

                setupCollectionView()
                reloadSteps()
            }

            override func viewDidLayoutSubviews() {
                super.viewDidLayoutSubviews()
                guard let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
                let width = collectionView.bounds.width - 32
                guard flow.estimatedItemSize.width != width else { return }
                flow.estimatedItemSize = CGSize(width: width, height: 200)
                collectionView.collectionViewLayout.invalidateLayout()
            }
        }

        // MARK: - Setup

        extension RoutineViewController {

            private func setupCollectionView() {
                collectionView.contentInsetAdjustmentBehavior = .automatic
                collectionView.delegate = self
                collectionView.dataSource = self
                collectionView.backgroundColor = .clear

                collectionView.register(
                    UINib(nibName: "Segmented_CollectionReusableView", bundle: nil),
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: Segmented_CollectionReusableView.identifier
                )

                collectionView.register(
                    UINib(nibName: "StepCollectionViewCell", bundle: nil),
                    forCellWithReuseIdentifier: StepCollectionViewCell.identifier
                )

                guard let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

                // FULL WIDTH (IMPORTANT)
                flow.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
                flow.minimumLineSpacing = 16
                flow.minimumInteritemSpacing = 0
                flow.sectionHeadersPinToVisibleBounds = false

                // Width fixed to collection view width minus horizontal insets; height self-sizes per content
                flow.estimatedItemSize = CGSize(width: collectionView.bounds.width - 32, height: 200)
            }
        }

        // MARK: - Data

        extension RoutineViewController {

            private func reloadSteps() {
                if let ai = aiOutput {
                    aiSteps = selectedSegment == 0 ? ai.morning : ai.evening
                    steps = []
                } else {
                    aiSteps = []
                    steps = selectedSegment == 0
                        ? dataModel.morningSteps(for: currentUserID)
                        : dataModel.eveningSteps(for: currentUserID)
                }
                collectionView.reloadData()
            }
        }

        // MARK: - DataSource

        extension RoutineViewController: UICollectionViewDataSource {

            func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

            func collectionView(_ collectionView: UICollectionView,
                                numberOfItemsInSection section: Int) -> Int {
                aiOutput != nil ? aiSteps.count : steps.count
            }

            func collectionView(_ collectionView: UICollectionView,
                                cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: StepCollectionViewCell.identifier,
                    for: indexPath
                ) as! StepCollectionViewCell

                if aiOutput != nil {
                    let aiStep = aiSteps[indexPath.item]
                    let isChecked = checkedSteps.contains(aiStep.id)
                    cell.configure(aiStep: aiStep, isChecked: isChecked)
                    cell.checkChanged = { [weak self] checked in
                        if checked { self?.checkedSteps.insert(aiStep.id) }
                        else { self?.checkedSteps.remove(aiStep.id) }
                    }
                } else {
                    let step = steps[indexPath.item]
                    let ingredients = dataModel.ingredientNames(for: step)
                    let isChecked = checkedSteps.contains(step.id)
                    cell.configure(step: step, ingredients: ingredients, isChecked: isChecked)
                    cell.checkChanged = { [weak self] checked in
                        if checked { self?.checkedSteps.insert(step.id) }
                        else { self?.checkedSteps.remove(step.id) }
                    }
                }

                return cell
            }
        }

        // MARK: - Header

        extension RoutineViewController {

            func collectionView(_ collectionView: UICollectionView,
                                viewForSupplementaryElementOfKind kind: String,
                                at indexPath: IndexPath) -> UICollectionReusableView {

                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: Segmented_CollectionReusableView.identifier,
                    for: indexPath
                ) as! Segmented_CollectionReusableView

                header.segmentChanged = { [weak self] index in
                    self?.selectedSegment = index
                    self?.reloadSteps()
                }

                return header
            }
        }

        // MARK: - Layout

        extension RoutineViewController: UICollectionViewDelegateFlowLayout {

            func collectionView(_ collectionView: UICollectionView,
                                layout collectionViewLayout: UICollectionViewLayout,
                                referenceSizeForHeaderInSection section: Int) -> CGSize {

                CGSize(width: collectionView.frame.width, height: 60)
            }
        }

        // MARK: - Navigation

        extension RoutineViewController: UICollectionViewDelegate {

            func collectionView(_ collectionView: UICollectionView,
                                didSelectItemAt indexPath: IndexPath) {

                let vc = RoutineDetailViewController()
                vc.dataModel = dataModel

                if aiOutput != nil {
                    vc.aiStep = aiSteps[indexPath.item]
                } else {
                    vc.step = steps[indexPath.item]
                }

                navigationController?.pushViewController(vc, animated: true)
            }
        }
