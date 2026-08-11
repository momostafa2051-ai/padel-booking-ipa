import Foundation

// MARK: - Court Model
struct Court: Identifiable, Codable {
    let id: Int
    let name: String
    let location: String
    let pricePerHour: Double
    let imageUrl: String?
}

struct CourtsResponse: Codable {
    let success: Bool
    let data: [Court]
}

// MARK: - Slot Model
struct Slot: Identifiable, Codable {
    let id: Int
    let courtId: Int
    let date: String
    let startTime: String
    let endTime: String
    let isAvailable: Int
    
    var formattedTime: String {
        "\(startTime) - \(endTime)"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: date) else { return date }
        formatter.dateFormat = "EEEE, d MMM"
        formatter.locale = Locale(identifier: "ar_EG")
        return formatter.string(from: date)
    }
}

struct SlotsResponse: Codable {
    let success: Bool
    let data: [Slot]
}

// MARK: - Booking Model
struct Booking: Identifiable, Codable {
    let id: Int
    let courtId: Int
    let slotId: Int
    let userName: String
    let userPhone: String
    let date: String
    let startTime: String
    let endTime: String
    let status: String
    let createdAt: String?
}

struct BookingsResponse: Codable {
    let success: Bool
    let data: [Booking]
}

struct CreateBookingRequest: Codable {
    let courtId: Int
    let slotId: Int
    let userName: String
    let userPhone: String
}

struct MessageResponse: Codable {
    let success: Bool
    let message: String?
    let error: String?
}