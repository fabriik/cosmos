// 
// Created by Equaleyes Solutions Ltd
// 

import UIKit

protocol KYCTutorialDisplayLogic: AnyObject {
    // MARK: Display logic functions
    
    func displayTutorialPages(viewModel: KYCTutorial.FetchTutorialPages.ViewModel)
    func displayNextTutorial(viewModel: KYCTutorial.HandleTutorialPaging.ViewModel)
}

class KYCTutorialViewController: KYCViewController, KYCTutorialDisplayLogic, UICollectionViewDataSource,
                                 UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var interactor: KYCTutorialBusinessLogic?
    var router: (NSObjectProtocol & KYCTutorialRoutingLogic)?
    
    // MARK: Object lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    private func setup() {
        let viewController = self
        let interactor = KYCTutorialInteractor()
        let presenter = KYCTutorialPresenter()
        let router = KYCTutorialRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: - Properties
    enum Rows {
        case tutorial1
        case tutorial2
    }
    
    private let rows: [Rows] = [
        .tutorial1,
        .tutorial2
    ]
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceHorizontal = false
        collectionView.alwaysBounceVertical = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.isUserInteractionEnabled = false
        pageControl.currentPageIndicatorTintColor = .vibrantYellow
        
        return pageControl
    }()
    
    private var nextPage = 0
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(KYCTutorial1CollectionView.self)
        collectionView.register(KYCTutorial2CollectionView.self)
        
        interactor?.fetchTutorialPages(request: .init())
    }
    
    override func setupUI() {
        tableView.isHidden = true
        roundedView.isHidden = true
        footerView.isHidden = true
        
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        view.addSubview(pageControl)
        pageControl.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -72).isActive = true
        pageControl.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor).isActive = true
        pageControl.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor).isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        nextPage = indexPath.row
        pageControl.currentPage = nextPage
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width,
                      height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return getTutorialCell(indexPath)
    }
    
    private func getTutorialCell(_ indexPath: IndexPath) -> UICollectionViewCell {
        switch rows[indexPath.row] {
        case .tutorial1:
            guard let cell: KYCTutorial1CollectionView = collectionView.dequeueReusableCell(for: indexPath) else {
                return UICollectionViewCell()
            }
            
            cell.didTapCloseButton = { [weak self] in
                self?.router?.dismissFlow()
            }
            
            cell.didTapNextButton = { [weak self] in
                guard let self = self else { return }
                self.interactor?.nextTutorial(request: .init(row: indexPath.row,
                                                             pageCount: self.rows.count))
            }
            
            return cell
            
        case .tutorial2:
            guard let cell: KYCTutorial2CollectionView = collectionView.dequeueReusableCell(for: indexPath) else {
                return UICollectionViewCell()
            }
            
            cell.didTapNextButton = { [weak self] in
                self?.router?.showKYCAddressScene()
            }
            
            return cell
            
        }
    }
    
    func displayTutorialPages(viewModel: KYCTutorial.FetchTutorialPages.ViewModel) {
        collectionView.reloadData()
        
        pageControl.numberOfPages = rows.count
    }
    
    func displayNextTutorial(viewModel: KYCTutorial.HandleTutorialPaging.ViewModel) {
        nextPage = viewModel.nextPage
        pageControl.currentPage = nextPage
        collectionView.isPagingEnabled = false
        collectionView.scrollToItem(at: IndexPath(item: nextPage, section: 0),
                                    at: .right,
                                    animated: true)
        collectionView.isPagingEnabled = true
    }
}
