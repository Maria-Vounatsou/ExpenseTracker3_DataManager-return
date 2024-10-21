//
//  EditCategoryViewModel.swift
//  ExpenseTracker
//
//  Created by Vounatsou, Maria on 9/10/24.
//

import SwiftUI
import CoreData

class EditCategoryViewModel: ObservableObject {
    @Published var addCategory: String = ""
    @Published var deleteCategory: String = ""
    
    private var dataManager: DataManager
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    func addCategoryAction() {
        guard !addCategory.isEmpty else {
            print("Category name cannot be empty.")
            return
        }
        
        if dataManager.categories.contains(addCategory) {
            print("Category already exists.")
        } else {
            let newCategory = CategoriesEntity(context: dataManager.viewContext)
            newCategory.name = addCategory
            
            dataManager.saveContext() // Save new category to Core Data
            addCategory = ""  // Clear the input field after adding
            print("Added new category: \(newCategory.name ?? "")")
            dataManager.fetchCategories()  // Refresh the categories list
            NotificationCenter.default.post(name: .didUpdateExpenses, object: nil)  // Notify observers
        }
    }
    
    func deleteCategoryAction() {
        guard !deleteCategory.isEmpty else {
            print("Please specify a category to delete.")
            return
        }
        
        if dataManager.categories.contains(deleteCategory) {
            dataManager.deleteCategory(categoryName: deleteCategory)
            
            NotificationCenter.default.post(name: .didUpdateExpenses, object: nil)  // Notify observers
            deleteCategory = ""  // Clear the input field after deletion
        } else {
            print("Category not found.")
        }
    }
}
