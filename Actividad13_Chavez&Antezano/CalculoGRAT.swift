import SwiftUI

struct CalculoGRAT: View {
    @State private var tipoEmpresa: String = ""
    @State private var periodo: String = ""
    @State private var fechaIngreso: Date = Date()
    @State private var esSueldoFijo: Bool = true
    @State private var sueldoFijo: String = ""
    @State private var sueldosVariables: [String] = Array(repeating: "", count: 6)
    @State private var tipoSeguro: String = ""
    @State private var asignacionFamiliar: Bool = false
    @State private var tieneComisiones: Bool = false
    @State private var comisiones: [String] = Array(repeating: "", count: 6)
    @State private var faltas: String = ""
    @State private var resultado: String = ""
    @State private var mostrarAlerta: Bool = false
    @State private var mensajeAlerta: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tipo de Empresa")) {
                    Picker("Tipo de Empresa", selection: $tipoEmpresa) {
                        Text("Régimen General").tag("Regimen General")
                        Text("Microempresa").tag("Microempresa")
                        Text("Pequeña Empresa").tag("Pequeña Empresa")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                if tipoEmpresa == "Microempresa" {
                    Text("No recibe gratificación.")
                        .foregroundColor(.red)
                } else {
                    Section(header: Text("Datos del Periodo")) {
                        Picker("Periodo", selection: $periodo) {
                            Text("PER Ene - Jun").tag("PER Ene - Jun")
                            Text("PER Jul - Dic").tag("PER Jul - Dic")
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        DatePicker("Fecha de Ingreso", selection: $fechaIngreso, displayedComponents: .date)
                    }

                    Section(header: Text("Sueldo")) {
                        Toggle("¿Es Sueldo Fijo?", isOn: $esSueldoFijo)
                        if esSueldoFijo {
                            TextField("Sueldo Fijo", text: $sueldoFijo)
                                .keyboardType(.decimalPad)
                        } else {
                            ForEach(0..<6) { index in
                                TextField("Sueldo S\(index + 1)", text: $sueldosVariables[index])
                                    .keyboardType(.decimalPad)
                            }
                        }
                    }

                    Section(header: Text("Otros Datos")) {
                        Picker("Tipo de Seguro", selection: $tipoSeguro) {
                            Text("ESSALUD").tag("ESSALUD")
                            Text("EPS").tag("EPS")
                        }

                        Toggle("Asignación Familiar", isOn: $asignacionFamiliar)

                        Toggle("¿Más de 3 comisiones?", isOn: $tieneComisiones)
                        if tieneComisiones {
                            ForEach(0..<6) { index in
                                TextField("Comisión C\(index + 1)", text: $comisiones[index])
                                    .keyboardType(.decimalPad)
                            }
                        }

                        TextField("Faltas del Periodo", text: $faltas)
                            .keyboardType(.numberPad)
                    }

                    Button(action: calcularGratificacion) {
                        Text("Calcular Gratificación")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    if !resultado.isEmpty {
                        Section(header: Text("Resultado")) {
                            Text(resultado)
                        }
                    }
                }
            }
            .navigationTitle("Cálculo de Gratificación")
            .alert(isPresented: $mostrarAlerta) {
                Alert(title: Text("Atención"), message: Text(mensajeAlerta), dismissButton: .default(Text("OK")))
            }
        }
    }

    func calcularGratificacion() {
        // Conversión de valores ingresados
        let faltasPeriodo = Int(faltas) ?? 0
        let sueldos = esSueldoFijo ? [Double(sueldoFijo) ?? 0.0] : sueldosVariables.compactMap { Double($0) }
        let promedioSueldo = sueldos.reduce(0, +) / Double(sueldos.count)
        let comisionesValores = tieneComisiones ? comisiones.compactMap { Double($0) } : []
        let promedioComisiones = comisionesValores.reduce(0, +) / max(Double(comisionesValores.count), 1)
        let asignacionFamiliarValor = asignacionFamiliar ? 102.50 : 0.0

        let remuneracionComputable = promedioSueldo + promedioComisiones + asignacionFamiliarValor

        // Cálculo de meses y días trabajados en el período
        let calendario = Calendar.current

        let fechaFinalPeriodo: Date
        let fechaInicioPeriodo: Date

        if periodo == "PER Ene - Jun" {
            fechaInicioPeriodo = calendario.date(from: DateComponents(year: calendario.component(.year, from: fechaIngreso), month: 1, day: 1))!
            fechaFinalPeriodo = calendario.date(from: DateComponents(year: calendario.component(.year, from: fechaIngreso), month: 6, day: 30))!
        } else {
            fechaInicioPeriodo = calendario.date(from: DateComponents(year: calendario.component(.year, from: fechaIngreso), month: 7, day: 1))!
            fechaFinalPeriodo = calendario.date(from: DateComponents(year: calendario.component(.year, from: fechaIngreso), month: 12, day: 31))!
        }

        let componentes = calendario.dateComponents([.month, .day], from: fechaIngreso, to: fechaFinalPeriodo)
        let mesesTrabajados = componentes.month ?? 0
        let diasTrabajados = componentes.day ?? 0

        if mesesTrabajados == 0 && diasTrabajados < 30 {
            mensajeAlerta = """
            No cumple con los requisitos para la gratificación.
            """
            mostrarAlerta = true
            return
        }

        // Calcular gratificación (si aplica)
        let importePorMes = (remuneracionComputable / 6) * Double(mesesTrabajados)
        let importePorDia = ((remuneracionComputable / 6) / 30) * Double(diasTrabajados - faltasPeriodo)
        let gratificacionTrunca = importePorMes + importePorDia
        let bonoExtraordinario = tipoSeguro == "ESSALUD" ? gratificacionTrunca * 0.09 : gratificacionTrunca * 0.0675
        let gratificacionFinal = gratificacionTrunca + bonoExtraordinario

        resultado = """
        Cálculos Detallados:
        - Promedio Sueldo: S/ \(String(format: "%.2f", promedioSueldo))
        - Promedio Comisiones: S/ \(String(format: "%.2f", promedioComisiones))
        - Asignación Familiar: S/ \(String(format: "%.2f", asignacionFamiliarValor))
        - Total Computable: S/ \(String(format: "%.2f", remuneracionComputable))
        
        Tiempo Trabajado:
        - Meses: \(mesesTrabajados)
        - Días: \(diasTrabajados)
        - Faltas: \(faltasPeriodo)
        
        Importes:
        - Por Mes: S/ \(String(format: "%.2f", importePorMes))
        - Por Día: S/ \(String(format: "%.2f", importePorDia))
        
        Totales:
        - Gratificación Trunca: S/ \(String(format: "%.2f", gratificacionTrunca))
        - Bono Extraordinario: S/ \(String(format: "%.2f", bonoExtraordinario))
        - Total Gratificación: S/ \(String(format: "%.2f", gratificacionFinal))
        """
    }
}

struct CalculoGRAT_Previews: PreviewProvider {
    static var previews: some View {
        CalculoGRAT()
    }
}
