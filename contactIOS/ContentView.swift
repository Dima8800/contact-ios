import SwiftUI
import Contacts
import MessageUI
import UIKit
struct ContentView: View {
    @State private var contacts: [CNContact] = []
        @State private var isLoading: Bool = true
        @State private var permissionDenied: Bool = false
        @State private var showSettings: Bool = false
        @State private var showMessageComposer: Bool = false
        @State private var selectedPhoneNumber: String = ""
        @State private var messageBody: String = ""
        @State private var showInputSheet: Bool = false
        @State private var inputMessage: String = ""
   @State var selectCan: Bool = false;
        @State private var searchText: String = ""
    
        @AppStorage("phoneNumber1") private var phoneNumber1: String = ""
        @AppStorage("phoneNumber2") private var phoneNumber2: String = ""

        var filteredContacts: [CNContact] {
            if searchText.isEmpty {
                return contacts
            } else {
                return contacts.filter { contact in
                    let fullName = "\(contact.givenName) \(contact.familyName)"
                    return fullName.localizedCaseInsensitiveContains(searchText)
                }
            }
        }

        var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    if permissionDenied {
                        Text("Разрешите доступ к контактам в настройках телефона.")
                            .padding()
                    } else if isLoading {
                        ProgressView("Загрузка контактов...")
                            .padding()
                    } else {
                        SearchBar(text: $searchText)
                        List(filteredContacts, id: \.identifier) { contact in
                            VStack(alignment: .leading) {
                                HStack(spacing: 20) {
                                    Text(contact.givenName + " " + contact.familyName)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Spacer()
                                    Button(action: {
                                        if let phoneNumber = contact.phoneNumbers.first?.value.stringValue, !phoneNumber.isEmpty {
                                            let formattedPhoneNumber = phoneNumber
                                                .replacingOccurrences(of: " ", with: "")
                                                .replacingOccurrences(of: "(", with: "")
                                                .replacingOccurrences(of: ")", with: "")
                                                .replacingOccurrences(of: "+7", with: "8")
                                                .replacingOccurrences(of: "-", with:"")
                                            if !formattedPhoneNumber.isEmpty {
                                                selectedPhoneNumber = phoneNumber2
                                                
                                                print(selectedPhoneNumber)
                                                
                                                messageBody = "\(formattedPhoneNumber)#"
                                                selectCan = false
                                                print(messageBody)
                                                
                                                showMessageComposer.toggle()
                                            } else {
                                                print("Номер телефона пустой. Сообщение не отправлено.")
                                            }
                                        } else {
                                            print("Номер телефона пустой. Сообщение не отправлено.")
                                        }
                                    }) {
                                        Image(systemName: "phone.fill")
                                            .foregroundColor(.green)
                                            .frame(width: 30, height: 30)
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    Button(action: {
                                        if let phoneNumber = contact.phoneNumbers.first?.value.stringValue, !phoneNumber.isEmpty {
                                            let formattedPhoneNumber = phoneNumber
                                                .replacingOccurrences(of: " ", with: "")
                                                .replacingOccurrences(of: "(", with: "")
                                                .replacingOccurrences(of: ")", with: "")
                                                .replacingOccurrences(of: "+7", with: "8")
                                                .replacingOccurrences(of: "-", with:"")
                                            if !formattedPhoneNumber.isEmpty {
                                                selectedPhoneNumber = phoneNumber1
                                                messageBody = "\(formattedPhoneNumber)*"
                                            }
                                            selectCan = true
                                            showInputSheet.toggle()
                                        } else {
                                            print("Номер телефона пустой. Сообщение не отправлено.")
                                        }
                                    }) {
                                        Image(systemName: "message.fill")
                                            .foregroundColor(.blue)
                                            .frame(width: 30, height: 30)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                                    Text(phoneNumber)
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("Контакты")
                            .font(.headline)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showSettings.toggle()
                        }) {
                            Image(systemName: "gear")
                        }
                    }
                }
                .sheet(isPresented: $showInputSheet) {
                    InputMessageView(inputMessage: $inputMessage, isPresented: $showInputSheet, onSend: {
                        inputMessage = ""
                        
                        DispatchQueue.main.async {
                            messageBody += " \(inputMessage)"
                            print(messageBody)
                                    showMessageComposer.toggle()
                                }
                    })
                }

                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
                .sheet(isPresented: $showMessageComposer) {
                    MessageComposeView(isShowing: $showMessageComposer, phoneNumber: selectedPhoneNumber, messageBody: messageBody)
                }
                .onAppear(perform: loadContacts)
            }
        }
    
    struct InputMessageView: View {
        @Binding var inputMessage: String
        @Binding var isPresented: Bool // Добавляем Binding для управления состоянием окна
        var onSend: () -> Void

        var body: some View {
            NavigationView {
                VStack {
                    TextField("Введите сообщение", text: $inputMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button("Отправить") {
                        onSend()
                        isPresented = false // Закрываем окно после отправки
                    }
                    .padding()
                }
                .navigationTitle("Cообщение")
                .navigationBarItems(trailing: Button("Закрыть") {
                    inputMessage = "" // Сбросить ввод при закрытии
                    isPresented = false // Закрываем окно
                })
            }
            .padding()
        }
    }


        private func loadContacts() {
            let store = CNContactStore()
            store.requestAccess(for: .contacts) { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        self.isLoading = true
                        fetchContacts(store: store)
                    } else {
                        permissionDenied = true
                        isLoading = false
                        print("Permission denied: \(String(describing: error?.localizedDescription))")
                    }
                }
            }
        }

        private func fetchContacts(store: CNContactStore) {
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
            let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try store.enumerateContacts(with: request) { contact, stop in
                        DispatchQueue.main.async {
                            contacts.append(contact)
                        }
                    }
                } catch {
                    print("Failed to fetch contacts:", error)
                }
                
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
        }
    }

struct MessageComposeView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    var phoneNumber: String
    var messageBody: String

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = context.coordinator

        print("Номер телефона: \(phoneNumber), Текст сообщения: \(messageBody)")
        
        if phoneNumber.isEmpty {
            DispatchQueue.main.async {
                print(messageBody)
                self.isShowing = false
            }
            return controller
        }
        
        controller.recipients = [phoneNumber]
        controller.body = messageBody
        
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            parent.isShowing = false
            controller.dismiss(animated: true, completion: nil)
        }
        
        var parent: MessageComposeView

        init(_ parent: MessageComposeView) {
            self.parent = parent
        }
    }
}

    struct SearchBar: UIViewRepresentable {
        @Binding var text: String
        
        class Coordinator: NSObject, UISearchBarDelegate {
            @Binding var text: String
            
            init(text: Binding<String>) {
                _text = text
            }
            
            func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
                self.text = searchText
            }
        }
        
        func makeCoordinator() -> Coordinator {
            return Coordinator(text: $text)
        }
        
        func makeUIView(context: Context) -> UISearchBar {
            let searchBar = UISearchBar()
            searchBar.delegate = context.coordinator
            searchBar.placeholder = "Поиск контактов"
            return searchBar
        }
        
        func updateUIView(_ uiView: UISearchBar, context: Context) {
            uiView.text = text
        }
    }
