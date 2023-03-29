//
//  DetailViewController.swift
//  
//
//  Created by Ian Dundas on 29/03/2023.
//

import UIKit
import Combine

public final class DetailViewController: UIViewController {
    
    typealias Cell = DetailCell
    typealias CellRegistration = UICollectionView.CellRegistration<Cell, DetailRow>

    fileprivate let collectionView = {
        
        // TODO: https://www.kodeco.com/5436806-modern-collection-views-with-compositional-layouts ?
        // TODO: https://www.swiftbysundell.com/articles/building-modern-collection-views-in-swift/

        let layout = UICollectionViewCompositionalLayout.list(
            using: UICollectionLayoutListConfiguration(
                appearance: .plain
            )
        )
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
//    fileprivate let loadingView: UIView = {
//        let view = UIView()
//
//        let spinner = UIActivityIndicatorView(style: .large)
//        spinner.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(spinner)
//        spinner.centerWithin(containingView: view)
//
//        return view
//    }()
    
    fileprivate func makeCellRegistration() -> CellRegistration {
        CellRegistration { [viewModel] cell, indexPath, item in
            cell.title = item.title
            cell.value = item.value
            if item.allowsSearch {
                cell.didTapButtonCallback = {
                    viewModel.userTappedRow(data: item)
                }
            } else {
                cell.didTapButtonCallback = nil
            }
        }
    }
    
    fileprivate lazy var datasource: UICollectionViewDiffableDataSource<Section, DetailRow> = {
        let datasource = UICollectionViewDiffableDataSource<Section, DetailRow>(
            collectionView: collectionView,
            cellProvider: makeCellRegistration().cellProvider
        )
        return datasource
    }()

    fileprivate let viewModel: DetailViewModel
    
    public init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Rijksmuseum Collection", comment: "Overview Title")
                
        setupCollectionView()
        setupBindings()
    }
    
    private var lastLoadedCancellable: AnyCancellable?
    private func setupBindings() {
        
        lastLoadedCancellable = viewModel.items.sink { [weak self] (values: [DetailRow]?) in
            guard let values, let self else { return } // don't need the initial nil
            
            var snapshot = self.datasource.snapshot()
            snapshot.deleteAllItems()
            
            snapshot.appendSections([Section()]) // unnamed section
            snapshot.appendItems(values)

            self.datasource.apply(snapshot)
        }
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.constrainToEdges(ofContainingView: view)

        collectionView.dataSource = datasource
    }
}