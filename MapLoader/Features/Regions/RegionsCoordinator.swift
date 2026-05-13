//
//  RegionsCoordinator.swift
//  MapLoader
//
//  Created by Rost on 11.05.2026.
//
import UIKit

final class RegionsCoordinator {

    let navigationController: UINavigationController
    weak var composer: AppComposer!

    init(
        navigationController: UINavigationController = UINavigationController(),
        composer: AppComposer
    ) {
        self.navigationController = navigationController
        self.composer = composer
    }

    func start() {
        let viewModel = RootRegionListViewModel(
            mapsProvider: composer.mapsProvider,
            storageInfoProvider: composer.storageInfoProvider,
            downloader: composer.fileDownloader,
            coordinator: self
        )
        let viewController = RegionListViewController(viewModel: viewModel)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.setViewControllers([viewController], animated: false)
        
    }
    
    func openSubregion(_ region: MapModel) {
        let viewModel = RegionListViewModel(model: region, downloader: composer.fileDownloader, coordinator: self)
        let viewController = RegionListViewController(viewModel: viewModel)
        viewController.navigationItem.largeTitleDisplayMode = .never
        navigationController.pushViewController(viewController, animated: true)
    }
}
