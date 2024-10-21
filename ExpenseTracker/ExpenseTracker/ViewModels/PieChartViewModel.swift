//
//  PieChartViewModel.swift
//  ExpenseTracker
//
//  Created by Vounatsou, Maria on 19/9/24.
//

import Combine
import CoreData
import DGCharts

class PieChartViewModel: ObservableObject {
    @Published var pieChartDataEntries: [PieChartDataEntry] = []
    private var viewContext: NSManagedObjectContext

    // A set to store the categories that should be excluded
    var deletedCategories: Set<String> = []

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        updateChartData()

        // Listen for Core Data updates and refresh the chart when data changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateChartDataNotification),
            name: .didUpdateExpenses,
            object: nil
        )
    }

    @objc private func updateChartDataNotification() {
        updateChartData()
    }

    // Fetch expenses and update the chart data
    func updateChartData() {
        let fetchRequest: NSFetchRequest<ExpensesEntity> = ExpensesEntity.fetchRequest()
        do {
            let expenses = try viewContext.fetch(fetchRequest)
            calculateChartData(from: expenses)
        } catch {
            print("Failed to fetch expenses: \(error)")
        }
    }

    private func calculateChartData(from expenses: [ExpensesEntity]) {
        // Filter out deleted categories
        let filteredExpenses = expenses.filter { expense in
            let categoryName = expense.categoryRel?.name ?? ""
            return !deletedCategories.contains(categoryName)
        }

        // Group expenses by their category
        let groupedExpenses = Dictionary(grouping: filteredExpenses, by: { $0.categoryRel?.name ?? "UncategorizedP" })
        
        // Create PieChartDataEntry for each category
        let newEntries = groupedExpenses.compactMap { category, expenses -> PieChartDataEntry? in
            let totalAmount = expenses.reduce(0) { $0 + $1.amount }
            return PieChartDataEntry(value: Double(totalAmount), label: category)
        }

        DispatchQueue.main.async {
            self.pieChartDataEntries = newEntries.isEmpty ? self.defaultEntries() : newEntries
        }
    }

    private func defaultEntries() -> [PieChartDataEntry] {
        return ["Category1", "Category2", "Category3"].map { PieChartDataEntry(value: 10, label: $0) }
    }
}
