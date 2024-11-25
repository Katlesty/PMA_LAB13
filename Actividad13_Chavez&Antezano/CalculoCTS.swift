import SwiftUI

struct CalculoCTS: View {
    @State private var fechaIngreso: Date = Date()
    @State private var periodoSeleccionado: String = ""
    @State private var tipoEmpresa: String = ""
    @State private var asignacionFamiliar: Bool = false
    @State private var faltasPeriodo: Int = 0
    @State private var tipoSueldo: String = ""
    @State private var sueldoFijo: Double? = nil
    @State private var sueldosVariables: [Double] = Array(repeating: 0, count: 6)
    @State private var ultimaGratificacion: Double = 0
    @State private var tieneComisiones: Bool = false
    @State private var comisiones: [Double] = Array(repeating: 0, count: 6)
    @State private var tieneBonificaciones: Bool = false
    @State private var bonificaciones: [Double] = Array(repeating: 0, count: 6)
    @State private var tieneHorasExtras: Bool = false
    @State private var horasExtras: [Double] = Array(repeating: 0, count: 6)
    @State private var resultadoCTS: String = ""
    @State private var mostrarAlerta: Bool = false
    @State private var mensajeAlerta: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Título principal
                Text("Cálculo de CTS")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom)
                
                // Sección: Fecha y periodo
                SectionView(title: "Fecha y Periodo") {
                    DatePicker("Fecha de ingreso:", selection: $fechaIngreso, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                    
                    Picker("Periodo a calcular:", selection: $periodoSeleccionado) {
                        Text("PER Nov - Abr").tag("NovAbr")
                        Text("PER May - Oct").tag("MayOct")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Validar periodo
                if validarPeriodo() {
                    // Sección: Datos de empresa y sueldo
                    SectionView(title: "Datos de la Empresa y Sueldo") {
                        
                        HStack {
                            Text("Tipo de empresa")
                                .font(.headline)
                                .fontWeight(.regular)
                                .foregroundColor(Color(red: 0.0, green: 0.0, blue: 0.0))
                            Spacer()
                            Picker("", selection: $tipoEmpresa) {
                                Text("Régimen General").tag("General")
                                Text("Régimen Microempresa").tag("Micro")
                                Text("Régimen Pequeña Empresa").tag("Pequeña")
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        Toggle("Asignación familiar", isOn: $asignacionFamiliar)
                        
                        HStack {
                            Text("Faltas en el período")
                                .font(.headline)
                                .fontWeight(.regular)
                                .foregroundColor(Color(red: 0.0, green: 0.0, blue: 0.0))
                            Spacer()
                            TextField("0", value: $faltasPeriodo, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .frame(width: 100)
                        }
                        
                        Text("Tipo de sueldo")
                            .font(.headline)
                            .fontWeight(.regular)
                            .foregroundColor(Color(red: 0.0, green: 0.0, blue: 0.0))
                        Picker("Tipo de sueldo:", selection: $tipoSueldo) {
                            Text("Fijo").tag("Fijo")
                            Text("Variable").tag("Variable")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        // Mostrar campos según tipo de sueldo
                        if tipoSueldo == "Fijo" {
                            TextField("Ingrese el sueldo fijo:", value: $sueldoFijo, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                        } else {
                            ForEach(0..<5) { index in
                                TextField("Sueldo S\(index + 1):", value: $sueldosVariables[index], formatter: NumberFormatter())
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                            }
                        }
                        
                        HStack{
                            Text("Ultima gratificación")
                                .font(.headline)
                                .fontWeight(.regular)
                                .foregroundColor(Color(red: 0.0, green: 0.0, blue: 0.0))
                            Spacer()
                            TextField("Última gratificación:", value: $ultimaGratificacion, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                    }
                    
                    // Sección: Ingresos adicionales
                    SectionView(title: "Ingresos Adicionales") {
                        Toggle("¿Tiene comisiones?", isOn: $tieneComisiones)
                        if tieneComisiones {
                            ForEach(0..<6) { index in
                                TextField("Comisión C\(index + 1):", value: $comisiones[index], formatter: NumberFormatter())
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                            }
                        }
                        
                        Toggle("¿Tiene bonificaciones regulares?", isOn: $tieneBonificaciones)
                        if tieneBonificaciones {
                            ForEach(0..<6) { index in
                                TextField("Bonificación BR\(index + 1):", value: $bonificaciones[index], formatter: NumberFormatter())
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                            }
                        }
                        
                        Toggle("¿Tiene horas extras?", isOn: $tieneHorasExtras)
                        if tieneHorasExtras {
                            ForEach(0..<6) { index in
                                TextField("Horas extra HE\(index + 1):", value: $horasExtras[index], formatter: NumberFormatter())
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                            }
                        }
                    }
                }
                
                // Botón calcular
                Button(action: calcularCTS) {
                    Text("Calcular CTS")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                // Mostrar resultado
                if !resultadoCTS.isEmpty {
                    Text(resultadoCTS)
                        .font(.headline)
                        .padding()
                        .background(Color.green.opacity(0.3))
                        .cornerRadius(8)
                        .transition(.slide)
                }
            }
            .padding()
            .alert(isPresented: $mostrarAlerta) {
                Alert(title: Text("Atención"), message: Text(mensajeAlerta), dismissButton: .default(Text("OK")))
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private func validarPeriodo() -> Bool {
        // Define el primer día del periodo seleccionado
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        // Definir las fechas de inicio de cada periodo
        let inicioPeriodoNovAbr = formatter.date(from: "2024-11-01")!
        let inicioPeriodoMayOct = formatter.date(from: "2025-05-01")!
        
        // Verificar si la fecha de ingreso es anterior al periodo seleccionado
        if fechaIngreso < inicioPeriodoNovAbr && periodoSeleccionado == "NovAbr" {
            // Si la fecha de ingreso es antes de Noviembre, por defecto asignamos 6 meses
            return true
        } else if fechaIngreso < inicioPeriodoMayOct && periodoSeleccionado == "MayOct" {
            // Si la fecha de ingreso es antes de Mayo, por defecto asignamos 6 meses
            return true
        }
        
        // Si la fecha de ingreso es después de los periodos, validamos si el trabajador cumple con al menos un mes completo.
        let ultimoDia: Date = periodoSeleccionado == "NovAbr" ? formatter.date(from: "2025-04-30")! : formatter.date(from: "2025-10-31")!
        
        let componentes = Calendar.current.dateComponents([.month, .day], from: fechaIngreso, to: ultimoDia)
        
        guard let meses = componentes.month, let dias = componentes.day else { return false }
        
        // Verifica si el trabajador cumple con al menos un mes completo
        if meses < 1 && (meses == 0 && dias < 30) {
            mensajeAlerta = "Debe haber trabajado al menos un mes completo para recibir CTS."
            mostrarAlerta = true
            return false
        }
        
        return true
    }
    
    private func calcularCTS() {
        guard validarPeriodo() else { return } // Si no cumple, detén el cálculo

        // Cálculos básicos
        let remuneracionBasica = tipoSueldo == "Fijo" ? sueldoFijo ?? 0 : sueldosVariables.reduce(0, +) / 6
        let asignacion = asignacionFamiliar ? 102.5 : 0
        let gratificacion = ultimaGratificacion / 6
        let promedioHorasExtras = tieneHorasExtras ? horasExtras.reduce(0, +) / 6 : 0
        let promedioComisiones = tieneComisiones ? comisiones.reduce(0, +) / 6 : 0
        let promedioBonificaciones = tieneBonificaciones ? bonificaciones.reduce(0, +) / 6 : 0

        let totalComputable = remuneracionBasica + asignacion + gratificacion + promedioHorasExtras + promedioComisiones + promedioBonificaciones

        // Cálculo del periodo
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let ultimoDia: Date = periodoSeleccionado == "NovAbr" ? formatter.date(from: "2025-04-30")! : formatter.date(from: "2025-10-31")!
        let componentes = Calendar.current.dateComponents([.month, .day], from: fechaIngreso, to: ultimoDia)

        var meses = componentes.month ?? 0
        var dias = componentes.day ?? 0

        // Si la fecha de ingreso es antes del inicio del periodo, asignar 6 meses completos
        if (fechaIngreso < formatter.date(from: "2024-11-01")! && periodoSeleccionado == "NovAbr") ||
           (fechaIngreso < formatter.date(from: "2025-05-01")! && periodoSeleccionado == "MayOct") {
            meses = 6
            dias = 0
        }

        // Calcular CTS
        var importePorMes = totalComputable / 12 * Double(meses)
        var importePorDia = (totalComputable / 360) * Double(max(0, dias - faltasPeriodo))

        if tipoEmpresa == "Micro" || tipoEmpresa == "Pequeña" {
            importePorMes *= 0.5
            importePorDia *= 0.5
        }

        let cts = importePorMes + importePorDia

        resultadoCTS = """
        Resultados:

        Meses laborados: \(meses)
        Días laborados: \(dias)

        Remuneración Básica: S/ \(String(format: "%.2f", remuneracionBasica))
        Asignación Familiar: S/ \(String(format: "%.2f", asignacion))
        Gratificación: S/ \(String(format: "%.2f", gratificacion))
        Promedio de Horas Extras: S/ \(String(format: "%.2f", promedioHorasExtras))
        Promedio de Comisiones: S/ \(String(format: "%.2f", promedioComisiones))
        Promedio de Bonificaciones: S/ \(String(format: "%.2f", promedioBonificaciones))
        Total Computable: S/ \(String(format: "%.2f", totalComputable))

        Importe por Mes: S/ \(String(format: "%.2f", importePorMes))
        Importe por Día: S/ \(String(format: "%.2f", importePorDia))

        CTS Total: S/ \(String(format: "%.2f", cts))
        """
    }


    
    // Vista auxiliar para las secciones
    struct SectionView<Content: View>: View {
        var title: String
        var content: Content
        
        init(title: String, @ViewBuilder content: () -> Content) {
            self.title = title
            self.content = content()
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 15) {
                Text(title)
                    .font(.headline)
                content
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 5)
        }
    }
    
}

struct CalculoCTS_Previews: PreviewProvider {
    static var previews: some View {
        CalculoCTS()
    }
}
