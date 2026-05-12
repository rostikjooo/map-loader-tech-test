//
//  AppComposer.swift
//  MapLoader
//
//  Created by Rost on 11.05.2026.
//

import UIKit

final class AppComposer {

    private var regionsCoordinator: RegionsCoordinator?

    func makeRootVC() -> UIViewController {
        let regionsCoordinator = RegionsCoordinator()
        regionsCoordinator.start()
        self.regionsCoordinator = regionsCoordinator

        return regionsCoordinator.navigationController
    }
}
