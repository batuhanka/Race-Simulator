import SwiftUI

// MARK: - API Response Models

struct ChecksumResponse: Codable {
    let runs: [String: [String]]?
    let success: Bool
}

struct RaceDetailResponse: Codable {
    let success: Bool
    let data: RaceData?
    let checksum: String?
}

struct RaceData: Codable {
    let muhtemeller: Muhtemeller?
}

struct Muhtemeller: Codable {
    let key: String?
    let no: String?
    let saat: String?
    let durum: String?
    let bahisler: [Bahis]?

    enum CodingKeys: String, CodingKey {
        case key = "KEY", no = "NO", saat = "SAAT", durum = "DURUM", bahisler
    }
}

struct Bahis: Codable {
    let tur: String?
    let muhtemeller: [BahisOran]?
    enum CodingKeys: String, CodingKey { case tur = "B", muhtemeller }
}

struct BahisOran: Codable {
    let s1: String?, s2: String?, ganyan: String?, k: Bool?, a: Bool?
    let e: String?

    enum CodingKeys: String, CodingKey {
        case s1 = "S1", s2 = "S2", ganyan = "G", k = "K", a = "A", e = "E"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        s1 = try container.decodeIfPresent(String.self, forKey: .s1)
        s2 = try container.decodeIfPresent(String.self, forKey: .s2)
        ganyan = try container.decodeIfPresent(String.self, forKey: .ganyan)
        k = try container.decodeIfPresent(Bool.self, forKey: .k)
        a = try container.decodeIfPresent(Bool.self, forKey: .a)

        if let stringValue = try? container.decodeIfPresent(String.self, forKey: .e) {
            e = stringValue
        } else if let intValue = try? container.decodeIfPresent(Int.self, forKey: .e) {
            e = String(intValue)
        } else {
            e = nil
        }
    }
}

struct ProgramResponse: Decodable {
    let kosular: [Race]?
}

// MARK: - Table Models

struct DynamicTableRow: Identifiable {
    let id = UUID()
    let isFavori: Bool
    let isKosmaz: Bool
    let ekuriGrubu: String
    var cells: [TableCell]
}

struct TableCell {
    let label: String
    let odds: String
}

// MARK: - View Helpers

struct PulseModifier: ViewModifier {
    var active: Bool
    @State private var opacity: Double = 1.0
    func body(content: Content) -> some View {
        content.opacity(opacity).onAppear {
            if active {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) { opacity = 0.4 }
            }
        }
    }
}
