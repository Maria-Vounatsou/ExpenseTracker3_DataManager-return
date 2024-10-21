import SwiftUI
import Combine

class AddAmountViewModel: ObservableObject {
    @Published var categories: [String] = []
    @Published var selectedCategory: String = ""
    @Published var amount: Double = 0
    @Published var currencySymbol: String = Locale.current.currencySymbol ?? "$"
    @Published var expenseDescription: String = ""

    private var dataManager: DataManager

    init(dataManager: DataManager) {
        self.dataManager = dataManager
        loadInitialData()

        NotificationCenter.default.addObserver(self, selector: #selector(handleCategoryUpdateNotification), name: .didUpdateExpenses, object: nil)
    }

    private func loadInitialData() {
        self.categories = dataManager.categories
        if !categories.isEmpty {
            self.selectedCategory = categories.first ?? ""
        }
    }
    
    @objc func handleCategoryUpdateNotification() {
        updateCategories()
    }

     func updateCategories() {
        self.categories = dataManager.categories
        // Ensure selectedCategory is valid
        if selectedCategory.isEmpty || !categories.contains(selectedCategory) {
            self.selectedCategory = categories.first ?? ""
        }
    }
    
    deinit {
         // Remove observer when the instance is deallocated
         NotificationCenter.default.removeObserver(self, name: .didUpdateExpenses, object: nil)
     }

    // Add expense, ensuring a valid category is always selected
    func addExpenseAmount() {
        guard !selectedCategory.isEmpty else {
            // Handle case where no category is selected (e.g., show a validation error to the user)
            print("No category selected. Cannot save expense.")
            return
        }
        dataManager.addExpense(amount: amount, category: selectedCategory, expenseDescription: expenseDescription)
        clearFields()
    }

    func clearFields() {
        self.amount = 0
        self.expenseDescription = ""
    }
}

