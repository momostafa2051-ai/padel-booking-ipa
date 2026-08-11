import SwiftUI

struct CourtsView: View {
    @State private var courts: [Court] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedCourt: Court?
    @State private var showingSlots = false
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("جاري التحميل...")
                        .padding()
                } else if let error = errorMessage {
                    VStack {
                        Text("حدث خطأ")
                            .font(.headline)
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(courts) { court in
                                CourtCard(court: court) {
                                    selectedCourt = court
                                    showingSlots = true
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("ملاعب البادل")
            .sheet(isPresented: $showingSlots) {
                if let court = selectedCourt {
                    SlotPickerView(court: court)
                }
            }
            .onAppear {
                loadCourts()
            }
        }
    }
    
    func loadCourts() {
        isLoading = true
        guard let url = URL(string: "http://YOUR_SERVER_IP:3000/api/courts") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                guard let data = data else { return }
                do {
                    let response = try JSONDecoder().decode(CourtsResponse.self, from: data)
                    courts = response.data
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }.resume()
    }
}

struct CourtCard: View {
    let court: Court
    let onBook: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImage(url: URL(string: court.imageUrl ?? "")) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay {
                            Image(systemName: "sportscourt")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(court.name)
                    .font(.headline)
                
                HStack {
                    Image(systemName: "location")
                    Text(court.location)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                
                HStack {
                    Text("\(Int(court.pricePerHour)) ج.م")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Text("/ الساعة")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button(action: onBook) {
                    Text("احجز الآن")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    CourtsView()
}