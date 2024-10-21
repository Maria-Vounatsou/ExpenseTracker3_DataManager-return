//
//  ExpenseDetailView.swift
//  ExperimentApp
//
//  Created by Vounatsou, Maria on 6/9/24.
//

import Foundation
import SwiftUI

struct ExpenseDetailView: View {

    @ObservedObject var viewModel: ExpenseDetailViewModel
    var expenses: [ExpensesEntity]

    var body: some View {
        List {
            ForEach(expenses, id: \.id) { expense in
                VStack(alignment: .leading) {
                    Text(expense.expenseDescription ?? "No description")
                    Text("Amount: \(expense.amount, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .onDelete(perform: viewModel.deleteExpense)
        }
        .navigationTitle("Details")
    }
}
