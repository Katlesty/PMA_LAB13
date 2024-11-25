import SwiftUI

struct CalculoPAG: View {
    // Constantes
    let pagoPorHora: Double = 50.0
    let maxHorasSemanales: Int = 23
    let asignacionFamiliar: Double = 102.50
    let valorUIT: Double = 5150.0
    
    // Variables del usuario
    @State private var tipoEmpresa: String = "Regimen general"
    @State private var horasSemanales: String = ""
    @State private var horasExtras: String = ""
    @State private var tieneAsignacionFamiliar: Bool = false
    @State private var sistemaPension: String = "ONP"
    @State private var afpTipo: String = "Habitat"
    
    // Resultado
    @State private var resultados: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Cálculo de Pago")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                Group {
                    // Selección de tipo de empresa
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tipo de Empresa")
                            .font(.headline)
                        Picker("Tipo de Empresa", selection: $tipoEmpresa) {
                            Text("Regimen general").tag("Regimen general")
                            Text("Regimen microempresa").tag("Regimen microempresa")
                            Text("Regimen pequeña empresa").tag("Regimen pequeña empresa")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Horas semanales
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Horas Semanales")
                            .font(.headline)
                        TextField("Ingresa las horas semanales", text: $horasSemanales)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                    
                    // Horas extras
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Horas Extras")
                            .font(.headline)
                        TextField("Ingresa las horas extras", text: $horasExtras)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                    
                    // Asignación familiar
                    Toggle("Asignación Familiar", isOn: $tieneAsignacionFamiliar)
                        .padding(.top, 10)
                    
                    // Sistema de pensión
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sistema de Pensión")
                            .font(.headline)
                        Picker("Sistema de Pensión", selection: $sistemaPension) {
                            Text("ONP").tag("ONP")
                            Text("AFP").tag("AFP")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    if sistemaPension == "AFP" {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tipo de AFP")
                                .font(.headline)
                            Picker("Tipo de AFP", selection: $afpTipo) {
                                Text("Habitat").tag("Habitat")
                                Text("Integra").tag("Integra")
                                Text("Prima").tag("Prima")
                                Text("Profuturo").tag("Profuturo")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                }
                
                // Botón para calcular
                Button(action: calcularPago) {
                    Text("Calcular")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                
                // Resultados
                VStack(alignment: .leading, spacing: 8) {
                    Text("Resultados")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                    
                    Text(resultados)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Calculo PAG")
    }
    
    func calcularPago() {
        guard let horasSemanalesInt = Int(horasSemanales), horasSemanalesInt <= maxHorasSemanales else {
            resultados = "Por favor, ingrese un valor válido para las horas semanales (máximo \(maxHorasSemanales))."
            return
        }
        
        guard let horasExtrasInt = Int(horasExtras), horasExtrasInt >= 0 else {
            resultados = "Por favor, ingrese un valor válido para las horas extras."
            return
        }
        
        // Cálculos iniciales
        let sueldoBruto = Double(horasSemanalesInt) * pagoPorHora * 4
        let horasExtrasTotales = calcularHorasExtras(horasExtras: horasExtrasInt)
        let renumeracionBrutaTotal = sueldoBruto + horasExtrasTotales + (tieneAsignacionFamiliar ? asignacionFamiliar : 0.0)
        
        // Tope de remuneración
        let topeRenumeracion = tipoEmpresa == "Regimen microempresa" ? (7 * valorUIT / 12) : (7 * valorUIT / 14)
        var renta5taCategoria: Double = 0.0
        if renumeracionBrutaTotal > topeRenumeracion {
            renta5taCategoria = calcularRenta5taCategoria(renumeracionBrutaTotal: renumeracionBrutaTotal)
        }
        
        // Descuentos de pensión
        let descuentoPension = sistemaPension == "ONP" ? (renumeracionBrutaTotal * 0.13) : calcularAFP(renumeracionBrutaTotal: renumeracionBrutaTotal)
        
        // Descuento total y remuneración neta
        let descuentoTotal = renta5taCategoria + descuentoPension
        let renumeracionNeta = renumeracionBrutaTotal - descuentoTotal
        
        // Bonificación extraordinaria
        let bonificacionExtraordinaria = renumeracionNeta * 0.09
        
        // Resultados
        resultados = """
        Sueldo Bruto: \(String(format: "%.2f", sueldoBruto)) soles
        Horas Extras: \(String(format: "%.2f", horasExtrasTotales)) soles
        Remuneración Bruta Total: \(String(format: "%.2f", renumeracionBrutaTotal)) soles
        Renta 5ta Categoría: \(String(format: "%.2f", renta5taCategoria)) soles
        Descuento Pensión: \(String(format: "%.2f", descuentoPension)) soles
        Descuento Total: \(String(format: "%.2f", descuentoTotal)) soles
        Remuneración Neta: \(String(format: "%.2f", renumeracionNeta)) soles
        Bonificación Extraordinaria: \(String(format: "%.2f", bonificacionExtraordinaria)) soles
        """
    }
    
    func calcularHorasExtras(horasExtras: Int) -> Double {
        if horasExtras <= 2 {
            return Double(horasExtras) * pagoPorHora * 1.25
        } else {
            let primerasDosHoras = 2 * pagoPorHora * 1.25
            let horasRestantes = Double(horasExtras - 2) * pagoPorHora * 1.35
            return primerasDosHoras + horasRestantes
        }
    }
    
    func calcularRenta5taCategoria(renumeracionBrutaTotal: Double) -> Double {
        let renumeracionAnual = renumeracionBrutaTotal * 12
        let gratificaciones: Double
        let bonificacionExtraordinaria = renumeracionBrutaTotal * 0.09
        
        switch tipoEmpresa {
        case "Regimen general":
            gratificaciones = renumeracionBrutaTotal * 2
        case "Regimen pequeña empresa":
            gratificaciones = renumeracionBrutaTotal * 2 * 0.5
        default:
            gratificaciones = 0
        }
        
        let totalIngresos = renumeracionAnual + gratificaciones + bonificacionExtraordinaria
        let excedente = totalIngresos - (7 * valorUIT)
        
        guard excedente > 0 else { return 0.0 }
        
        let tramo1 = min(excedente, 5 * valorUIT) * 0.08
        let tramo2 = max(0, min(excedente - 5 * valorUIT, 15 * valorUIT)) * 0.14
        let tramo3 = max(0, min(excedente - 20 * valorUIT, 15 * valorUIT)) * 0.17
        let tramo4 = max(0, min(excedente - 35 * valorUIT, 10 * valorUIT)) * 0.20
        let tramo5 = max(0, excedente - 45 * valorUIT) * 0.30
        
        let rentaAnual = tramo1 + tramo2 + tramo3 + tramo4 + tramo5
        return rentaAnual / 12
    }
    
    func calcularAFP(renumeracionBrutaTotal: Double) -> Double {
        let primaSeguro = renumeracionBrutaTotal * 0.017
        let aporteObligatorio = renumeracionBrutaTotal * 0.10
        let comisionVariable: Double
        
        switch afpTipo {
        case "Prima":
            comisionVariable = renumeracionBrutaTotal * 0.016
        case "Habitat":
            comisionVariable = renumeracionBrutaTotal * 0.0147
        case "Profuturo":
            comisionVariable = renumeracionBrutaTotal * 0.0169
        default: // Integra
            comisionVariable = renumeracionBrutaTotal * 0.0155
        }
        
        return primaSeguro + aporteObligatorio + comisionVariable
    }
}

struct CalculoPAG_Previews: PreviewProvider {
    static var previews: some View {
        CalculoPAG()
    }
}
