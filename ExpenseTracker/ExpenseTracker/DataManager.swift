import CoreData
import SwiftUI
import Foundation

extension Notification.Name {
    static let didUpdateExpenses = Notification.Name("didUpdateExpenses")
}

class DataManager: ObservableObject {
    
    @Published var items: [ExpensesEntity] = []
    @Published var categories: [String] = []
    
     var viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchExpenses()
        fetchCategories()
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextDidChange(notification:)),
            name: .NSManagedObjectContextObjectsDidChange,
            object: viewContext
        )
    }
    
    @objc private func contextDidChange(notification: Notification) {
        fetchExpenses()
        fetchCategories()
    }
    
    // Fetches all expenses from Core Data
    func fetchExpenses() {
        viewContext.perform {
            let request: NSFetchRequest<ExpensesEntity> = ExpensesEntity.fetchRequest()
            do {
                let fetchedItems = try self.viewContext.fetch(request)
                DispatchQueue.main.async {
                    self.items = fetchedItems
                    print("Remaining expenses by category: \(self.expensesByCategory)")
                }
            } catch {
                print("Failed to fetch expenses: \(error)")
                DispatchQueue.main.async {
                    self.items = []
                }
            }
        }
    }

    // Fetches all unique categories from Core Data. Updating the categories on the main thread
    func fetchCategories() {
        let request: NSFetchRequest<CategoriesEntity> = CategoriesEntity.fetchRequest()
        do {
            let results = try viewContext.fetch(request)
            let uniqueCategories = Set(results.map { $0.name ?? "" }).filter { !$0.isEmpty }
            DispatchQueue.main.async {
                self.categories = Array(uniqueCategories).sorted()
                print("Fetched Categories: \(self.categories)")
                NotificationCenter.default.post(name: .didUpdateExpenses, object: nil)
            }
        } catch {
            print("Failed to fetch categories: \(error)")
            DispatchQueue.main.async {
                self.categories = ["Personal", "Business", "Entertainment", "Home"]  // Fallback categories
            }
        }
    }


    // Adds a new expense to Core Data
    func addExpense(amount: Double, category: String, expenseDescription: String) {
        let newExpense = ExpensesEntity(context: viewContext)
        newExpense.id = UUID()
        newExpense.amount = amount
        newExpense.expenseDescription = expenseDescription
        
        setCategory(for: newExpense, withName: category)

        saveContext()  // Save the new expense to Core Data
        fetchCategories()  // Ensure categories are updated
        NotificationCenter.default.post(name: .didUpdateExpenses, object: nil)  // Notify observers
    }

    private func setCategory(for expense: ExpensesEntity, withName categoryName: String) {
        viewContext.perform {
            let categoryRequest: NSFetchRequest<CategoriesEntity> = CategoriesEntity.fetchRequest()
            categoryRequest.predicate = NSPredicate(format: "name == %@", categoryName)
            
            let category = (try? self.viewContext.fetch(categoryRequest).first) ?? {
                let newCategory = CategoriesEntity(context: self.viewContext)
                newCategory.name = categoryName
                return newCategory
            }()
            
            // Directly assign the category without switching to the main thread
            expense.categoryRel = category
        }
    }


    // Saves the current state of the Core Data context
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .didUpdateExpenses, object: nil)  // Notify observers
                }
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }


    // Groups expenses by their categories
    var expensesByCategory: [String: [ExpensesEntity]] {
        Dictionary(grouping: items, by: { $0.categoryRel?.name ?? "UncategorizedD" })
    }
    
    // Deletes an expense from Core Data
    func deleteExpense(_ expense: ExpensesEntity) {
        viewContext.delete(expense)
        do {
            try viewContext.save()
            // Post notification after successfully saving the context
            NotificationCenter.default.post(name: .didUpdateExpenses, object: nil)
            print("Expense deleted and context saved")
        } catch {
            print("Failed to delete expense: \(error)")
        }
    }
    
    // Deletes a category and handles the associated expenses
    func deleteCategory(categoryName: String) {
        let request: NSFetchRequest<CategoriesEntity> = CategoriesEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", categoryName)
        
        if let result = try? viewContext.fetch(request), let categoryToDelete = result.first {
            // Handle expenses before deleting the category
            handleExpensesBeforeDeletingCategory(categoryToDelete)

            viewContext.delete(categoryToDelete)
            do {
                try viewContext.save()
                NotificationCenter.default.post(name: .didUpdateExpenses, object: nil)
                print("Category deleted and context saved")
                fetchCategories()  // Refresh categories after deletion
            } catch {
                print("Failed to delete category: \(error)")
            }
        }
    }

    // Handles expenses before deleting a category
    func handleExpensesBeforeDeletingCategory(_ categoryToDelete: CategoriesEntity) {
        let expensesRequest: NSFetchRequest<ExpensesEntity> = ExpensesEntity.fetchRequest()
        expensesRequest.predicate = NSPredicate(format: "categoryRel == %@", categoryToDelete)
        
        do {
            let expensesToHandle = try viewContext.fetch(expensesRequest)
            print("Expenses to delete: \(expensesToHandle.count) for category \(categoryToDelete.name ?? "Unknown")")
            
            // Option 1: Delete all expenses in the category
            for expense in expensesToHandle {
                viewContext.delete(expense)
                print("Deleted expense: \(expense.id ?? UUID())")
            }
            
            // Option 2: Reassign all expenses to a default category
            /*
             let defaultCategoryRequest: NSFetchRequest<CategoriesEntity> = CategoriesEntity.fetchRequest()
             defaultCategoryRequest.predicate = NSPredicate(format: "name == %@", "Default Category")
             if let defaultCategory = try? viewContext.fetch(defaultCategoryRequest).first {
             for expense in expensesToHandle {
             expense.categoryRel = defaultCategory
             }
             }
             */
            
            // Save the changes
            try viewContext.save()
            print("Handled expenses for deleted category.")
            
        } catch {
            print("Failed to handle expenses for category: \(error)")
        }
    }
}
