//
//  ExpenseViewModel.swift
//  ExpenseTracker
//
//  Created by Vounatsou, Maria on 14/10/24.
//

import SwiftUI
import CoreData
import Combine

class ExpenseViewModel: ObservableObject {
    @Published var categoriesWithExpenses: [String] = []
    @Published var shouldRefresh = false
    var dataManager: DataManager
    private var cancellables = Set<AnyCancellable>()
    
    // A local list to keep track of categories marked as "deleted" for ExpenseView only
    var deletedCategories: Set<String> = []
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
        fetchCategoriesWithExpenses()
        
        NotificationCenter.default.publisher(for: .didUpdateExpenses)
            .receive(on: RunLoop.main)
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)  // Throttle updates
            .sink { [weak self] _ in
                self?.fetchCategoriesWithExpenses()
                self?.shouldRefresh.toggle()  // Force refresh
            }
            .store(in: &cancellables)
    }
    
    deinit {
        // Not needed with Combine as Combine manages deallocation of observers
    }
    
    func fetchCategoriesWithExpenses() {
        // Fetch categories from DataManager and filter out those marked as deleted in ExpenseView
        self.categoriesWithExpenses = dataManager.categories.filter { category in
            !(dataManager.expensesByCategory[category]?.isEmpty ?? true) && !deletedCategories.contains(category)
        }
    }
    
    func expenses(for category: String) -> [ExpensesEntity] {
        return dataManager.expensesByCategory[category] ?? []
    }
    
    func deleteCategory(at offsets: IndexSet) {
        let categoriesToDelete = offsets.map { categoriesWithExpenses[$0] }
        for category in categoriesToDelete {
            // Call DataManager to delete the category and its associated expenses
            dataManager.deleteCategory(categoryName: category)
        }
        fetchCategoriesWithExpenses()  // Refresh the local list of categories
    }
}
