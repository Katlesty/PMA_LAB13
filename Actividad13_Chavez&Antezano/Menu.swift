//
//  Menu.swift
//  Actividad13_Chavez&Antezano
//
//  Created by Mac15 on 24/11/24.
//

import SwiftUI

struct Menu: View {
    var body: some View {
            NavigationView {
                TabView {
                    CalculoCTS()
                        .tabItem {
                            Label("CTS", systemImage: "dollarsign.circle")
                        }

                    CalculoGRAT()
                        .tabItem {
                            Label("Gratificación", systemImage: "gift")
                        }

                    CalculoPAG()
                        .tabItem {
                            Label("Pago a Instructores", systemImage: "person.2.circle")
                        }
                }
                .navigationTitle("CALCULADORA")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.cyan, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                                ToolbarItem(placement: .principal) {
                                    Text("CALCULADORA")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }            }
        }
}

#Preview {
    Menu()
}
