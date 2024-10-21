//
//  SwiftUIView.swift
//  ExperimentApp
//
//  Created by Vounatsou, Maria on 9/9/24.
//

import SwiftUI

struct AddAmountView: View {
    @Binding var presentSideMenu: Bool
    @ObservedObject var viewModel: AddAmountViewModel
    @State private var isPressed = false
    @State private var showSheet = false
    
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
                VStack {
                    NavigationView {
                        VStack {
                            HStack {
                                Spacer()
                                    .frame(width: 40, height: 80)

                                TextField("", value: $viewModel.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                    .font(.largeTitle)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.leading)
                                    .frame(width: 200, height: 100)
                                
                                Text(viewModel.currencySymbol)
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 2)
                                    .shadow(radius: 5, x: 5, y: 5)
                                    .padding(5)
                            )
                            .padding(10)
                            Spacer()
                            
                            Divider()
                            
                            Form {
                                Picker("Select Category", selection: $viewModel.selectedCategory) {
                                    ForEach(viewModel.categories, id: \.self) { category in
                                        Text(category)
                                            .bold()
                                    }
                                }
                                .bold()
                                .foregroundColor(.colorT)
                                .onAppear {
                                    // Ensure that a valid category is selected when the view appears
                                    if viewModel.selectedCategory.isEmpty && !viewModel.categories.isEmpty {
                                        viewModel.selectedCategory = viewModel.categories.first ?? ""
                                    }
                                }

                                .bold()
                                .foregroundColor(.colorT)
                                HStack {
                                    Text("Edit Category")
                                        .foregroundStyle(Color("ColorT"))
                                        .bold()
                                    Spacer()
                                    Button(action: {
                                        showSheet = true
                                    }) {
                                        Image(systemName: "square.and.pencil")
                                            .foregroundColor(Color("ColorT"))
                                    }
                                }

                                Section(header:
                                            Text("Add Description")
                                    .bold()
                                    .font(.title3)
                                    .foregroundColor(.colorT)
                                ){
                                    TextField("Description",text: $viewModel.expenseDescription)
                                        .padding()
                                        .background(Color(.systemGray5))
                                        .cornerRadius(30)
                                }
                                VStack {
                                    Spacer(minLength: 50)
                                    Spacer()
                                    Button(action: {
                                        // Leave empty if using the gesture to trigger the action
                                    }) {
                                        Text("Save")
                                            .padding()
                                            .bold()
                                            .font(.system(size: 23))
                                            .frame(width: 100, height: 40)
                                            .foregroundColor(.white)
                                            .background(Color("ColorT"))
                                            .cornerRadius(15)
                                    }
                                    .scaleEffect(isPressed ? 0.95 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: isPressed)
                                    .padding(.bottom, 20)
                                    .shadow(radius: 5, x: 5, y: 5)
                                    .onLongPressGesture(minimumDuration: 0.1, pressing: { isCurrentlyPressing in
                                        withAnimation {
                                            self.isPressed = isCurrentlyPressing
                                        }
                                    }, perform: {
                                        viewModel.addExpenseAmount()  // Call ViewModel's method to add the expense
                                    })
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                            }
                            .scrollContentBackground(.hidden)
                            .navigationBarTitle("Add Amount", displayMode: .inline)
                        }
                    }
                }
            }
            .sheet(isPresented: $showSheet) {
                let viewContext = PersistenceController.shared.container.viewContext  // Assuming CoreData setup
                let dataManager = DataManager(context: viewContext)
                let viewModel = EditCategoryViewModel(dataManager: dataManager)
                
                EditCategoryView(viewModel: viewModel)
            }
        }
        .onAppear {
            // Ensure that a valid category is selected when the view appears
            if viewModel.selectedCategory.isEmpty && !viewModel.categories.isEmpty {
                viewModel.selectedCategory = viewModel.categories.first ?? ""
            }
        }
    }
}
struct AddAmountView_Previews: PreviewProvider {
    static var previews: some View {
        // Setup a preview managed object context
        let context = PersistenceController.preview.container.viewContext
        
        // Create an instance of the DataManager
        let expenseService = DataManager(context: context)
        
        // Create the ViewModel, passing the DataManager
        let viewModel = AddAmountViewModel(dataManager: expenseService)
        
        // Pass the ViewModel to the AddAmountView
        AddAmountView(presentSideMenu: .constant(false), viewModel: viewModel)
    }
}
