import SwiftUI

struct CalculoCTS: View {
    @State private var fechaIngreso: Date = Date()
    @State private var periodoSeleccionado: String = "Nov-Abr"
    @State private var tipoEmpresa: String = "General"
    @State private var tieneAsignacionFamiliar: Bool = false
    @State private var faltas: Int = 0
    @State private var tipoSueldo: String = "Fijo"
    @State private var sueldoFijo: Double = 0.0
    @State private var sueldosVariables: [Double] = Array(repeating: 0.0, count: 6)
    @State private var ultimaGratificacion: Double = 0.0
    @State private var tieneComisiones: Bool = false
    @State private var comisiones: [Double] = Array(repeating: 0.0, count: 6)
    @State private var tieneBonificaciones: Bool = false
    @State private var bonificaciones: [Double] = Array(repeating: 0.0, count: 6)
    @State private var tieneHorasExtras: Bool = false
    @State private var horasExtras: [Double] = Array(repeating: 0.0, count: 6)
    @State private var resultadoCTS: String = ""
    @State private var mostrarAlerta: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Fecha y Periodo
                    SectionView(title: "Datos Generales") {
                        DatePicker("Fecha de Ingreso", selection: $fechaIngreso, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())

                        Picker("Periodo", selection: $periodoSeleccionado) {
                            Text("PER Nov - Abr").tag("Nov-Abr")
                            Text("PER May - Oct").tag("May-Oct")
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        Picker("Tipo de Empresa", selection: $tipoEmpresa) {
                            Text("General").tag("General")
                            Text("Microempresa").tag("Micro")
                            Text("Pequeña Empresa").tag("Pequeña")
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        Toggle("Asignación Familiar", isOn: $tieneAsignacionFamiliar)
                            .onChange(of: tieneAsignacionFamiliar) { newValue in
                                // No se necesita acción adicional, simplemente aseguramos que el valor está activado.
                            }

                        // Nueva línea de texto para faltas
                        Text("Faltas en el Periodo")
                            .font(.headline)
                            .foregroundColor(Color.primary)
                        
                        TextField("Faltas en el Periodo", value: $faltas, format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    // Sueldo y Beneficios
                    SectionView(title: "Sueldo y Beneficios") {
                        Picker("Tipo de Sueldo", selection: $tipoSueldo) {
                            Text("Fijo").tag("Fijo")
                            Text("Variable").tag("Variable")
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        if tipoSueldo == "Fijo" {
                            TextField("Ingrese Sueldo Fijo", value: $sueldoFijo, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            ForEach(0..<6, id: \.self) { index in
                                TextField("Sueldo Mes \(index + 1)", value: $sueldosVariables[index], format: .number)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }

                        TextField("Última Gratificación", value: $ultimaGratificacion, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    // Componentes adicionales
                    AdditionalComponentsView(
                        title: "Comisiones", isActive: $tieneComisiones, values: $comisiones
                    )
                    AdditionalComponentsView(
                        title: "Bonificaciones Regulares", isActive: $tieneBonificaciones, values: $bonificaciones
                    )
                    AdditionalComponentsView(
                        title: "Horas Extras", isActive: $tieneHorasExtras, values: $horasExtras
                    )

                    // Botón de Cálculo
                    Button(action: calcularCTS) {
                        Text("Calcular CTS")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.vertical, 20)

                    // Resultado
                    if !resultadoCTS.isEmpty {
                        Text(resultadoCTS)
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding()
                    }
                }
                .padding()
                .alert(isPresented: $mostrarAlerta) {
                    Alert(title: Text("Error"), message: Text("Se requiere al menos 1 mes completo de trabajo para calcular CTS."), dismissButton: .default(Text("OK")))
                }
            }
            .navigationTitle("Cálculo CTS")
        }
    }

    func calcularCTS() {
        let calendario = Calendar.current
        let ultimaFechaPeriodo: Date

        // Definir la última fecha del periodo según selección
        if periodoSeleccionado == "Nov-Abr" {
            ultimaFechaPeriodo = calendario.date(from: DateComponents(year: calendario.component(.year, from: Date()), month: 4, day: 30)) ?? Date()
        } else {
            ultimaFechaPeriodo = calendario.date(from: DateComponents(year: calendario.component(.year, from: Date()), month: 10, day: 31)) ?? Date()
        }

        // Calcular meses y días trabajados
        let componentes = calendario.dateComponents([.year, .month, .day], from: fechaIngreso, to: ultimaFechaPeriodo)
        let mesesTrabajados = max(0, (componentes.year ?? 0) * 12 + (componentes.month ?? 0))
        let diasTrabajados = max(0, componentes.day ?? 0)
        let diasEfectivos = max(0, diasTrabajados - faltas)

        // Verificar si cumple con al menos 1 mes
        if mesesTrabajados == 0 && diasTrabajados < 30 {
            resultadoCTS = "Error: No se puede calcular CTS. Se requiere al menos 1 mes completo."
            return
        }

        // Calcular la remuneración computable
        let remuneracionBasica = tipoSueldo == "Fijo" ? sueldoFijo : sueldosVariables.reduce(0, +) / 6
        let asignacionFamiliar = tieneAsignacionFamiliar ? 102.5 : 0.0
        let gratificacion = ultimaGratificacion / 6
        let promedioComisiones = tieneComisiones ? comisiones.reduce(0, +) / 6 : 0.0
        let promedioBonificaciones = tieneBonificaciones ? bonificaciones.reduce(0, +) / 6 : 0.0
        let promedioHorasExtras = tieneHorasExtras ? horasExtras.reduce(0, +) / 6 : 0.0

        let totalComputable = remuneracionBasica + asignacionFamiliar + gratificacion + promedioComisiones + promedioBonificaciones + promedioHorasExtras

        // Cálculo de importe por mes y por día
        let importePorMes: Double
        let importePorDia: Double

        if tipoEmpresa == "Micro" || tipoEmpresa == "Pequeña" {
            importePorMes = (totalComputable / 12) * Double(mesesTrabajados) * 0.5
            importePorDia = (totalComputable / 360) * Double(diasEfectivos) * 0.5
        } else {
            importePorMes = (totalComputable / 12) * Double(mesesTrabajados)
            importePorDia = (totalComputable / 360) * Double(diasEfectivos)
        }

        // Calcular el monto total de CTS
        let cts = importePorMes + importePorDia
        resultadoCTS = "El monto de CTS calculado es: S/ \(String(format: "%.2f", cts))"
    }

}

// Componentes reutilizables
struct SectionView<Content: View>: View {
    let title: String
    let content: () -> Content

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 5)

            content()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct AdditionalComponentsView: View {
    let title: String
    @Binding var isActive: Bool
    @Binding var values: [Double]

    var body: some View {
        SectionView(title: title) {
            Toggle("¿Tiene \(title)?", isOn: $isActive)

            if isActive {
                ForEach(0..<6, id: \.self) { index in
                    TextField("\(title) \(index + 1)", value: $values[index], format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
        }
    }
}

struct CalculoCTS_Previews: PreviewProvider {
    static var previews: some View {
        CalculoCTS()
    }
}
