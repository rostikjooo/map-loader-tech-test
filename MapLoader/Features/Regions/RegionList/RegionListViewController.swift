//
//  RegionListViewController.swift
//  MapLoader
//
//  Created by Rost on 11.05.2026.
//
import UIKit

class RegionListViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let viewModel: RegionListProviding
    
    init(viewModel: RegionListProviding) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
    }
    
    func setupView() {
        title = viewModel.title
        view.backgroundColor = .systemGroupedBackground
        setupTableView()
    }

    private func setupTableView() {
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .init(top: 0, left: 15, bottom: 0, right: 0)
        // FIXME: in design color is #E6E6E6
        tableView.separatorColor = .tableSeparator

        
        viewModel.tableViewDataSource.registerCells(in: tableView)
        tableView.dataSource = viewModel.tableViewDataSource
        tableView.delegate = viewModel.tableViewDataSource
        viewModel.tableViewDataSource.getVisibleCell = { [weak tableView] indexPath in
            tableView?.cellForRow(at: indexPath)
        }
        viewModel.tableViewDataSource.indexPathsForVisibleRows = { [weak tableView] in
            tableView?.indexPathsForVisibleRows ?? []
        }
        viewModel.tableViewDataSource.reloadTable = { [weak tableView] in
            tableView?.reloadData()
        }
    }
}

