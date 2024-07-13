import UIKit
import SwiftUI
import FileCacheUnit

protocol CalendarViewControllerDelegate: AnyObject {
    func didSelectTodoItem(_ item: Todoitem)
}

class CalendarViewController: UIViewController {
    var viewModel: ViewModel!
    weak var delegate: CalendarViewControllerDelegate?

    private var tableView: UITableView!
    private var calendarView: UICollectionView!
    private var addButton: UIButton!
    private var selectedDate: Date?
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        setupCalendar()
        setupTableView()
        setupAddButton()
        setupConstraints()
    }

    private func setupCalendar() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 100, height: 100)
        calendarView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.backgroundColor = .white
        calendarView.showsHorizontalScrollIndicator = false
        calendarView.bounces = false
        calendarView.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
        view.addSubview(calendarView)
    }

    private func setupTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TodoItemCell.self, forCellReuseIdentifier: TodoItemCell.reuseIdentifier)
        tableView.register(RoundedSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: RoundedSectionHeaderView.reuseIdentifier)
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        view.addSubview(tableView)
    }

    private func setupAddButton() {
        let addButtonView = UIHostingController(rootView: AddButton(viewModel: viewModel))
        addButtonView.view.translatesAutoresizingMaskIntoConstraints = false
        addButtonView.view.backgroundColor = .clear
        addChild(addButtonView)
        view.addSubview(addButtonView.view)
        addButtonView.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            addButtonView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButtonView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            addButtonView.view.widthAnchor.constraint(equalToConstant: 60),
            addButtonView.view.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarView.heightAnchor.constraint(equalToConstant: 60),

            tableView.topAnchor.constraint(equalTo: calendarView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func scrollToSection(for date: Date) {
        if let sectionIndex = viewModel.sections.firstIndex(where: {
            section in
            if let sectionDate = dateFormatter.date(from: section.title),
               Calendar.current.isDate(sectionDate, inSameDayAs: date) {
                return true
            }
            return false
        }) {
            tableView.scrollToRow(at: IndexPath(row: 0, section: sectionIndex), at: .top, animated: true)
        }
    }

    private func updateCalendarSelection(for indexPath: IndexPath) {
        let section = viewModel.sections[indexPath.section]
        if let date = dateFormatter.date(from: section.title) {
            selectedDate = date
            calendarView.reloadData()
        }
    }
}

extension CalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.sections.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
        let section = viewModel.sections[indexPath.item]
        if let date = dateFormatter.date(from: section.title) {
            let item = viewModel.sections[indexPath.item].items.first
            cell.configure(
                with: section.title,
                isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate ?? Date()),
                item: item
            )
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = viewModel.sections[indexPath.item]
        if let date = dateFormatter.date(from: section.title) {
            selectedDate = date
            scrollToSection(for: date)
            calendarView.reloadData()
        }
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TodoItemCell.reuseIdentifier, for: indexPath) as! TodoItemCell
        let item = viewModel.sections[indexPath.section].items[indexPath.row]
        let isTop = indexPath.row == 0
        let isBottom = indexPath.row == viewModel.sections[indexPath.section].items.count - 1
        cell.configure(with: item, isTop: isTop, isBottom: isBottom)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: RoundedSectionHeaderView.reuseIdentifier) as? RoundedSectionHeaderView
        headerView?.configure(with: viewModel.sections[section].title)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.sections[indexPath.section].items[indexPath.row]
        delegate?.didSelectTodoItem(item)
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = viewModel.sections[indexPath.section].items[indexPath.row]
        let toggleCompleteAction = UIContextualAction(style: .normal, title: "Выполнено") { [weak self] (_, _, completionHandler) in
            self?.viewModel.completeItem(item.id)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        toggleCompleteAction.backgroundColor = .green

        return UISwipeActionsConfiguration(actions: [toggleCompleteAction])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = viewModel.sections[indexPath.section].items[indexPath.row]
        let toggleCompleteAction = UIContextualAction(style: .normal, title: "Не выполнено") { [weak self] (_, _, completionHandler) in
            self?.viewModel.activateItem(item.id)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        toggleCompleteAction.backgroundColor = .gray

        return UISwipeActionsConfiguration(actions: [toggleCompleteAction])
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let indexPath = tableView.indexPathsForVisibleRows?.first {
            updateCalendarSelection(for: indexPath)
        }
    }
}
