//
//  ContentView.swift
//  ExperimentApp
//
//  Created by Vounatsou, Maria on 6/9/24.
//

import SwiftUI
import CoreData
import DGCharts

struct ExpenseView: View {
    @Binding var presentSideMenu: Bool
    @State private var isNavigationActive = false
    @StateObject private var PieViewModel: PieChartViewModel
    @StateObject private var expenseViewModel: ExpenseViewModel
    
    init(presentSideMenu: Binding<Bool>, dataManager: DataManager, context: NSManagedObjectContext) {
        _presentSideMenu = presentSideMenu  // Initialize the Binding
        _PieViewModel = StateObject(wrappedValue: PieChartViewModel(context: context))
        _expenseViewModel = StateObject(wrappedValue: ExpenseViewModel(dataManager: dataManager))
    }
    
    var body: some View {
           ZStack {
               Color.colorT
                   .edgesIgnoringSafeArea(.all)
               VStack {
                   HStack {
                       Button {
                           presentSideMenu.toggle()
                       } label: {
                           Image(systemName: "list.bullet.circle")
                               .resizable()
                               .frame(width: 30, height: 30)
                               .foregroundColor(.gray)
                               .padding(.horizontal)
                       }
                       Spacer()
                   }
                   
                   // Pass deletedCategories to the PieChartViewModel
                   PieChartWrapper(viewModel: PieViewModel)
                       .frame(height: 300)
                       .padding(.horizontal)
                       .onAppear {
                           // Ensure PieChartViewModel knows about the deleted categories
                           PieViewModel.deletedCategories = expenseViewModel.deletedCategories
                           PieViewModel.updateChartData()
                       }
                   
                   NavigationStack {
                       List {
                           // Use categories from ExpenseViewModel and wrap each category in a NavigationLink
                           ForEach(expenseViewModel.categoriesWithExpenses, id: \.self) { category in
                               NavigationLink(destination: {
                                   let expenses = expenseViewModel.expenses(for: category)
                                   let viewModel = ExpenseDetailViewModel(expenses: expenses, dataManager: expenseViewModel.dataManager)
                                   ExpenseDetailView(viewModel: viewModel, expenses: expenses)
                               }) {
                                   Text(category)
                               }
                           }
                           .onDelete(perform: expenseViewModel.deleteCategory)
                       }
                       .navigationTitle("Categories")
                   }
               }
           }
           .onChange(of: expenseViewModel.shouldRefresh) { _ in
               // Update both the view and pie chart when data changes
               expenseViewModel.fetchCategoriesWithExpenses()
               PieViewModel.deletedCategories = expenseViewModel.deletedCategories
               PieViewModel.updateChartData()
           }
       }
   }

struct ExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let dataManager = DataManager(context: context)
        
        return ExpenseView(presentSideMenu: .constant(false), dataManager: dataManager, context: context)
            .environmentObject(dataManager)
            .environment(\.managedObjectContext, context)
    }
}




