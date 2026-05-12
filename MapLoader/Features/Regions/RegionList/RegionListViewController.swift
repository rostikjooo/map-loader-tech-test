//
//  RegionListViewController.swift
//  MapLoader
//
//  Created by Rost on 11.05.2026.
//
import UIKit

final class RegionListViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let viewModel: RegionListViewModel
    
    init(viewModel: RegionListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }
    
    func setupView() {
        title = viewModel.title
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemGroupedBackground
        setupTableView()
    }

    private func setupTableView() {
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        
        viewModel.tableViewDataSource.registerCells(in: tableView)
        tableView.dataSource = viewModel.tableViewDataSource
        tableView.delegate = viewModel.tableViewDataSource
        viewModel.tableViewDataSource.reloadTable = { [weak tableView] in
            tableView?.reloadData()
        }
    }
}

