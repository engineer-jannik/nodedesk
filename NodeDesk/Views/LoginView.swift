import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    @FocusState private var focusedField: Field?

    enum Field { case email, password }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color("AccentStart"), Color("AccentEnd")]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                VStack(spacing: 6) {
                    Image(systemName: "briefcase.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .blue)
                        .shadow(radius: 8)

                    Text("OwnLance")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Deine Freelance-Zentrale")
                        .foregroundColor(.white.opacity(0.9))
                }
                .multilineTextAlignment(.center)

                VStack(spacing: 12) {
                    TextField("E-Mail", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .password
                        }

                    SecureField("Passwort", text: $password)
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

                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 6)
                }

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
        guard !email.isEmpty, !password.isEmpty else {
            withAnimation {
                errorMessage = "Bitte alle Felder ausfüllen."
                showError = true
            }
            return
        }

        showError = false
        isLoading = true

        // Fake login delay -> replace with your auth call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isLoading = false
            if email.lowercased() == "admin" && password == "123" {
                withAnimation { isLoggedIn = true }
            } else {
                withAnimation {
                    errorMessage = "E-Mail oder Passwort falsch."
                    showError = true
                }
            }
        }
    }
}
