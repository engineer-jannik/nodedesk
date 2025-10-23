import SwiftUI

struct LoginView: View {
    @Binding var showLogin: Bool
    @Binding var currentState: ConnectState
    @Binding var server: Server

    @FocusState private var focusedField: Field?
    @State var showError: Bool = false
    @State var isLoading: Bool = false

    enum Field { case email, password }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color("AccentStart"), Color("AccentEnd")]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()
                VStack(spacing: 12) {
                    TextField("Benutzername", text: $server.username)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .disabled(!server.username.isEmpty)
                        .onSubmit {
                            focusedField = .password
                        }

                    SecureField("Passwort", text: $server.password)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.go)
                        .onSubmit {
                            login()
                        }
                }
                .padding(.horizontal, 40)

                Button {
                    login()
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Einloggen")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    // .background(Color.black.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
                }
                .disabled(isLoading)
                .padding(.horizontal, 40)

                Spacer()

                HStack {
                    Text("Developed by Jannik with ❤️")
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.bottom, 24)
            }
            .padding()
        }
    }

    private func login() {
        isLoading = true
        ProxmoxProvider.shared.login(server: server) { result in
            isLoading = false
            
            if(result) {
                currentState = .fetchingData
                showLogin = false
            } else {
                currentState = .failed
                showLogin = false
            }
        }
    }
}
