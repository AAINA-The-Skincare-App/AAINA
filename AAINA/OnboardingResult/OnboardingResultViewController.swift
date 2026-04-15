//
//  OnboardingResultViewController.swift
//  AAINA
//
//  Created by GEU on 26/03/26.
//

import UIKit

class OnboardingResultViewController: UIViewController {
    
    var onboardingData: OnboardingData!
    var dataModel: AppDataModel!
    
    private let defaultDataModel = DataModel()
    private var morningSteps: [AIRoutineStep] {
        if let ai = dataModel.aiRoutine {
            return ai.morning
        }
        let userID = defaultDataModel.currentUser().id
        return defaultDataModel.morningSteps(for: userID).map { makeAIStep(from: $0) }
    }

    private var eveningSteps: [AIRoutineStep] {
        if let ai = dataModel.aiRoutine {
            return ai.evening
        }
        let userID = defaultDataModel.currentUser().id
        return defaultDataModel.eveningSteps(for: userID).map { makeAIStep(from: $0) }
    }

        // Converts a static RoutineStep into an AIRoutineStep so the same cell can render both
    private func makeAIStep(from step: RoutineStep) -> AIRoutineStep {
        AIRoutineStep(
            id: step.id,
            stepNumber: step.stepOrder,
            productType: step.type,
            productName: step.stepTitle,
            keyIngredients: defaultDataModel.ingredientNames(for: step),
            reason: step.productDescription,
            usage: step.instructionText,
            isUserAdded: false
        )
    }
    
    @IBOutlet weak var OnboardingResultCollectionView: UICollectionView!
    override func viewDidLoad() {
            super.viewDidLoad()

            setupUI()
            registerCells()
            setupCollectionView()
            navigationItem.hidesBackButton = true
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false

            view.applyAINABackground()
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            view.applyAINABackground()
        }

        // MARK: - Setup

        private func setupUI() {
            title = "Your Profile"
            view.backgroundColor = .systemGroupedBackground
            OnboardingResultCollectionView.backgroundColor = .clear
        }

        private func registerCells() {
            OnboardingResultCollectionView.register(
                UINib(nibName: "ResultProfileCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "profile_cell"
            )
            OnboardingResultCollectionView.register(
                UINib(nibName: "OnboardingResultRoutineCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "routine_cell"
            )
            OnboardingResultCollectionView.register(
                UINib(nibName: "StartJourneyButtonCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "button_cell"
            )
            OnboardingResultCollectionView.register(
                UINib(nibName: "OnboardingResultSecHeadingCollectionReusableView", bundle: nil),
                forSupplementaryViewOfKind: "header",
                withReuseIdentifier: "heading_view"
            )
        }

        private func setupCollectionView() {
            OnboardingResultCollectionView.delegate = self
            OnboardingResultCollectionView.dataSource = self
            OnboardingResultCollectionView.collectionViewLayout = generateLayout()
            OnboardingResultCollectionView.showsVerticalScrollIndicator = false
            OnboardingResultCollectionView.alwaysBounceVertical = true
        }

        // MARK: - Layout

        private func generateLayout() -> UICollectionViewLayout {

            UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
                guard let self else { return nil }

                switch sectionIndex {
                case 0: return self.profileSection()
                case 1:
                    let section = self.routineSection()
                    section.boundarySupplementaryItems = [self.sectionHeader()]
                    return section
                case 2: return self.routineSection()
                case 3: return self.buttonSection()
                default: return self.routineSection()
                }
            }
        }

        /// Fixed height — profile card is always 200pt tall
        private func profileSection() -> NSCollectionLayoutSection {

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(200)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            return section
        }

        /// Self-sizing — card height grows/shrinks with the number of steps inside
        private func routineSection() -> NSCollectionLayoutSection {

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(300)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(300)
            )
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            return section
        }

        /// Fixed height — CTA button is always 72pt
        private func buttonSection() -> NSCollectionLayoutSection {

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(40)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 32, trailing: 0)
            return section
        }

        private func sectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(44)
            )
            return NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: "header",
                alignment: .topLeading
            )
        }
    }

    // MARK: - Supplementary Views

    extension OnboardingResultViewController {

        func collectionView(_ collectionView: UICollectionView,
                            viewForSupplementaryElementOfKind kind: String,
                            at indexPath: IndexPath) -> UICollectionReusableView {

            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "heading_view",
                for: indexPath
            ) as! OnboardingResultSecHeadingCollectionReusableView

            if indexPath.section == 1 {
                let isAI = dataModel.aiRoutine != nil
                headerView.configure(title: isAI ? "Your Personalized Routine" : "Recommended Routine")
            }

            return headerView
        }
    }

    // MARK: - UICollectionViewDataSource

    extension OnboardingResultViewController: UICollectionViewDataSource {

        func numberOfSections(in collectionView: UICollectionView) -> Int { 4 }

        func collectionView(_ collectionView: UICollectionView,
                            numberOfItemsInSection section: Int) -> Int { 1 }

        func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

            switch indexPath.section {

            case 0:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "profile_cell", for: indexPath
                ) as! ResultProfileCollectionViewCell
                cell.configure(with: onboardingData, name: "Sarah")
                return cell

            case 1:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "routine_cell", for: indexPath
                ) as! OnboardingResultRoutineCollectionViewCell
                cell.configure(title: "Morning Routine", steps: morningSteps)
                return cell

            case 2:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "routine_cell", for: indexPath
                ) as! OnboardingResultRoutineCollectionViewCell
                cell.configure(title: "Evening Routine", steps: eveningSteps)
                return cell

            case 3:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "button_cell", for: indexPath
                ) as! StartJourneyButtonCollectionViewCell
                cell.onTap = { [weak self] in self?.goToHome() }
                return cell

            default:
                return UICollectionViewCell()
            }
        }

        private func goToHome() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let tabBarVC = storyboard.instantiateViewController(
                withIdentifier: "MainTabBarViewController"
            ) as? UITabBarController else { return }

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = tabBarVC
                sceneDelegate.window?.makeKeyAndVisible()
            }
        }
    }

    // MARK: - UICollectionViewDelegate

    extension OnboardingResultViewController: UICollectionViewDelegate {}
