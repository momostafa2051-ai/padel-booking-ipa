import SwiftUI

struct MyBookingsView: View {
    @State private var bookings: [Booking] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var phone = ""
    @State private var showingPhoneAlert = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("جاري التحميل...")
                        .padding()
                } else if bookings.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("لا توجد حجوزات")
                            .font(.headline)
                        Text("أدخل رقم تليفونك لعرض حجوزاتك")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 50)
                } else {
                    List(bookings) { booking in
                        BookingRow(booking: booking) {
                            cancelBooking(booking)
                        }
                    }
                }
            }
            .navigationTitle("حجوزاتي")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingPhoneAlert = true
                    } label: {
                        Image(systemName: "phone")
                    }
                }
            }
            .alert("ادخل رقم التليفون", isPresented: $showingPhoneAlert) {
                TextField("رقم التليفون", text: $phone)
                    .keyboardType(.phonePad)
                Button("بحث") {
                    loadBookings()
                }
            }
            .onAppear {
                // Try to load from UserDefaults
                if let savedPhone = UserDefaults.standard.string(forKey: "userPhone") {
                    phone = savedPhone
                    loadBookings()
                }
            }
        }
    }
    
    func loadBookings() {
        guard !phone.isEmpty else { return }
        isLoading = true
        UserDefaults.standard.set(phone, forKey: "userPhone")
        
        guard let url = URL(string: "http://YOUR_SERVER_IP:3000/api/bookings?phone=\(phone)") else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(BookingsResponse.self, from: data)
                        bookings = response.data
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }.resume()
    }
    
    func cancelBooking(_ booking: Booking) {
        guard let url = URL(string: "http://YOUR_SERVER_IP:3000/api/bookings/\(booking.id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            DispatchQueue.main.async {
                if error == nil {
                    bookings.removeAll { $0.id == booking.id }
                }
            }
        }.resume()
    }
}

struct BookingRow: View {
    let booking: Booking
    let onCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("ملعب #\(booking.courtId)")
                    .font(.headline)
                Spacer()
                Text(booking.status)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(booking.status == "confirmed" ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .foregroundColor(booking.status == "confirmed" ? .green : .red)
                    .clipShape(Capsule())
            }
            
            HStack {
                Image(systemName: "calendar")
                Text(booking.date)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "clock")
                Text("\(booking.startTime) - \(booking.endTime)")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            if booking.status == "confirmed" {
                Button("إلغاء الحجز", role: .destructive) {
                    onCancel()
                }
                .font(.caption)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    MyBookingsView()
}