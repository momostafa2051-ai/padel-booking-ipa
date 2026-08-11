import SwiftUI

struct BookingFormView: View {
    let court: Court
    let slot: Slot
    let onComplete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var userName = ""
    @State private var userPhone = ""
    @State private var isLoading = false
    @State private var showingSuccess = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("بيانات الحجز") {
                    HStack {
                        Text("الملعب:")
                        Spacer()
                        Text(court.name)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("التاريخ:")
                        Spacer()
                        Text(slot.formattedDate)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("الوقت:")
                        Spacer()
                        Text(slot.formattedTime)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("السعر:")
                        Spacer()
                        Text("\(Int(court.pricePerHour)) ج.م")
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    }
                }
                
                Section("بياناتك") {
                    TextField("الاسم", text: $userName)
                        .textContentType(.name)
                        .direction,.layoutDirection(.rightToLeft)
                    
                    TextField("رقم التليفون", text: $userPhone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button(action: submitBooking) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("تأكيد الحجز")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                    }
                    .listRowBackground(Color.green)
                    .disabled(userName.isEmpty || userPhone.isEmpty || isLoading)
                }
            }
            .navigationTitle("حجز الملعب")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إلغاء") {
                        dismiss()
                    }
                }
            }
            .alert("تم الحجز بنجاح!", isPresented: $showingSuccess) {
                Button("تم") {
                    onComplete()
                }
            } message: {
                Text("تم حجز الملعب بنجاح. نشوفك قريب!")
            }
        }
    }
    
    func submitBooking() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "http://YOUR_SERVER_IP:3000/api/bookings") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "courtId": court.id,
            "slotId": slot.id,
            "userName": userName,
            "userPhone": userPhone
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                guard let data = data else { return }
                do {
                    let response = try JSONDecoder().decode(MessageResponse.self, from: data)
                    if response.success {
                        showingSuccess = true
                    } else {
                        errorMessage = response.error ?? "Unknown error"
                    }
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }.resume()
    }
}

#Preview {
    BookingFormView(
        court: Court(id: 1, name: "ملعب 1", location: "6th October", pricePerHour: 150, imageUrl: nil),
        slot: Slot(id: 1, courtId: 1, date: "2026-08-15", startTime: "09:00", endTime: "10:00", isAvailable: 1),
        onComplete: {}
    )
}