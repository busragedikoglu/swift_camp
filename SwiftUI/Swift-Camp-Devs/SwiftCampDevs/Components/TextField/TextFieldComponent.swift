import SwiftUI

struct SCTextField: View {
    @Binding var text: String
    var type: TextFieldType
    var maxLength: Int? = nil
    var borderColor: Color = AppColors.darkGray
    var borderWidth: CGFloat = UISizerHelper.Border.thin
    var cornerRadius: CGFloat = UISizerHelper.Radius.low
    var backgroundColor: Color = AppColors.white
    var showPasswordToggle: Bool = true
    var isEnabled: Bool = true
    
    @State private var isPasswordVisible: Bool = false
    @State private var errorMessage: String? = nil
    @State private var criteria: [(description: String, isMet: Bool)] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .trailing) {
                if type == .password && !isPasswordVisible {
                    SecureField(type.placeholder, text: $text)
                        .disabled(!isEnabled)
                        .textFieldStyle(PlainTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(type.keyboardType)
                        .padding(UISizerHelper.Padding.low)
                        .background(isEnabled ? backgroundColor : AppColors.lightGray)
                        .cornerRadius(cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(isEnabled ? (errorMessage == nil ? borderColor : .red) : .red, lineWidth: borderWidth)
                        )
                } else {
                    TextField(type.placeholder, text: $text)
                        .disabled(!isEnabled)
                        .textFieldStyle(PlainTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(type.keyboardType)
                        .padding(UISizerHelper.Padding.low)
                        .background(isEnabled ? backgroundColor : AppColors.lightGray)
                        .cornerRadius(cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(isEnabled ? (errorMessage == nil ? borderColor : .red) : .red, lineWidth: borderWidth)
                        )
                }
                
                if type == .password && showPasswordToggle && isEnabled {
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                            .foregroundColor(.gray)
                            .padding(.trailing, UISizerHelper.Dimensions.normal)
                    }
                }
            }
            .frame(height: UISizerHelper.Screen.height * 0.05)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, UISizerHelper.Dimensions.low)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .onChange(of: text) { newValue in
            if type == .numeric || type == .phoneNumber {
                // Allow only numeric characters for numeric and phone number fields
                text = newValue.filter { $0.isNumber }
            }
            else if type == .password {
                // Allow only English letters (uppercase and lowercase), numbers, and special characters (excluding spaces) for password
                let allowedCharacterSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+={}[]|\\:;\"'<>,.?/`~-")
                
                // Filter out any characters that are not in the allowed set
                text = newValue.filter { $0.unicodeScalars.allSatisfy { allowedCharacterSet.contains($0) } }
            }
            
            // Optional: Apply length limit for the text field (if maxLength is set)
            if let maxLength = maxLength, newValue.count > maxLength {
                text = String(newValue.prefix(maxLength))
            }

            // Additional validation for other input types
            validateInput(newValue)
        }
    }
    
    /// Validates the input text and updates the error message.
    func validateInput(_ value: String) {
        errorMessage = type.validate(value)
    }
}

struct ContentView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var email: String = ""
    
    var body: some View {
        VStack(spacing: 8) {
            SCTextField(text: $username, type: .username, borderColor: .blue)
            SCTextField(text: $password, type: .password, borderColor: .green, showPasswordToggle: true)
            SCTextField(text: $email, type: .email, borderColor: .orange)
        }
        .padding()
    }
}

#Preview {
    VStack(spacing: 8) {
        SCTextField(text: .constant(""), type: .username)
        SCTextField(text: .constant(""), type: .password, borderColor: .red, showPasswordToggle: true, isEnabled: true)
        SCTextField(text: .constant(""), type: .email, borderColor: .green)
        SCTextField(text: .constant(""), type: .search, borderColor: .gray, isEnabled: false)
        SCTextField(text: .constant(""), type: .custom(placeholder: "Enter custom input", keyboardType: .asciiCapable), borderColor: .orange)
    }
    .padding()
}
