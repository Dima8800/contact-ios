import SwiftUI

struct SettingsView: View {
    @State private var phoneNumber1: String = UserDefaults.standard.string(forKey: "phoneNumber1") ?? ""
    @State private var phoneNumber2: String = UserDefaults.standard.string(forKey: "phoneNumber2") ?? ""
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isPhoneNumber1Valid: Bool = true
    @State private var isPhoneNumber2Valid: Bool = true

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Введите номера телефонов")) {
                    TextField("Номер телефона для СМС", text: $phoneNumber1)
                        .keyboardType(.phonePad)
                        .onChange(of: phoneNumber1) { newValue in
                            isPhoneNumber1Valid = newValue.count == 11
                        }
                        .padding()
                        .background(isPhoneNumber1Valid ? Color.clear : Color.red.opacity(0.3))
                        .cornerRadius(5)
                        .frame(height: 30)

                    TextField("Номер телефона для звонков", text: $phoneNumber2)
                        .keyboardType(.phonePad)
                        .onChange(of: phoneNumber2) { newValue in
                            isPhoneNumber2Valid = newValue.count == 11
                        }
                        .padding()
                        .background(isPhoneNumber2Valid ? Color.clear : Color.red.opacity(0.3))
                        .cornerRadius(5)
                        .frame(height: 30)
                }
                
                Button("Сохранить") {
                    UserDefaults.standard.set(phoneNumber1, forKey: "phoneNumber1")
                    UserDefaults.standard.set(phoneNumber2, forKey: "phoneNumber2")
                    
                    print("Номера телефонов сохранены: \(phoneNumber1), \(phoneNumber2)")
                    
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(!isPhoneNumber1Valid || !isPhoneNumber2Valid || (phoneNumber1.isEmpty != phoneNumber2.isEmpty))
            }
            .navigationTitle("Настройки")
            .navigationBarItems(trailing: Button("Закрыть") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
