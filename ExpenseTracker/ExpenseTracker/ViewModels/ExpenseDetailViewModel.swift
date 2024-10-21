//
//  ExpenseDetailViewModel.swift
//  ExpenseTracker
//
//  Created by Vounatsou, Maria on 20/9/24.
//

import Foundation
import SwiftUI

class ExpenseDetailViewModel: ObservableObject {
    @Published var expenses: [ExpensesEntity]
    private var dataManager: DataManager

    init(expenses: [ExpensesEntity], dataManager: DataManager) {
        self.expenses = expenses
        self.dataManager = dataManager
    }

    func deleteExpense(at offsets: IndexSet) {
        offsets.forEach { index in
            let expenseEntity = expenses[index]
            dataManager.deleteExpense(expenseEntity)
        }
        expenses.remove(atOffsets: offsets)
    }
}
