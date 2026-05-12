//
//  RegionsCoordinator.swift
//  MapLoader
//
//  Created by Rost on 11.05.2026.
//
import UIKit

final class RegionsCoordinator {

    let navigationController: UINavigationController

    init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = RegionListViewModel()
        let viewController = RegionListViewController(viewModel: viewModel)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.setViewControllers([viewController], animated: false)
    }
}
