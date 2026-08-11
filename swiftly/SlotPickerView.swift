import SwiftUI

struct SlotPickerView: View {
    let court: Court
    @Environment(\.dismiss) private var dismiss
    
    @State private var slots: [Slot] = []
    @State private var selectedDate = Date()
    @State private var isLoading = true
    @State private var selectedSlot: Slot?
    @State private var showingBookingForm = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("جاري تحميل الأوقات...")
                        .padding()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    // Date Picker
                    DatePicker(
                        "اختر التاريخ",
                        selection: $selectedDate,
                        in: Date()...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    .onChange(of: selectedDate) { _, _ in
                        loadSlots()
                    }
                    
                    Divider()
                    
                    // Slots Grid
                    if slots.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("لا توجد أوقات متاحة")
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 50)
                    } else {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(slots) { slot in
                                SlotButton(slot: slot, isSelected: selectedSlot?.id == slot.id) {
                                    selectedSlot = slot
                                    showingBookingForm = true
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(court.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إغلاق") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingBookingForm) {
                if let slot = selectedSlot {
                    BookingFormView(court: court, slot: slot) {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadSlots()
            }
        }
    }
    
    func loadSlots() {
        isLoading = true
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: selectedDate)
        
        guard let url = URL(string: "http://YOUR_SERVER_IP:3000/api/slots?courtId=\(court.id)&date=\(dateStr)") else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(SlotsResponse.self, from: data)
                        slots = response.data
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }.resume()
    }
}

struct SlotButton: View {
    let slot: Slot
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(slot.startTime)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.green : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    SlotPickerView(court: Court(id: 1, name: "ملعب 1", location: "6th October", pricePerHour: 150, imageUrl: nil))
}