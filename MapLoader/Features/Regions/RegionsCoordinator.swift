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
        let viewModel = RegionListViewModel(
            mapsProvider: composer.mapsProvider,
            storageInfoProvider: composer.storageInfoProvider,
            downloader: composer.fileDownloader
        )
        let viewController = RegionListViewController(viewModel: viewModel)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.setViewControllers([viewController], animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.openSubregion()
        }
    }
    
    func openSubregion(/*for region: Region*/) {
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        vc.title = "detail"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController.pushViewController(vc, animated: true)
    }
}
