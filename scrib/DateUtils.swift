import Foundation

extension Date {
    func timeAgoDisplay() -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.hour, .minute], from: self, to: now)
        
        if let hours = components.hour {
            if hours < 24 {
                if hours == 0 {
                    // Less than an hour ago
                    if let minutes = components.minute {
                        if minutes == 0 {
                            return "just now"
                        }
                        return "\(minutes) \(minutes == 1 ? "minute" : "minutes") ago"
                    }
                }
                return "\(hours) \(hours == 1 ? "hour" : "hours") ago"
            }
        }
        
        // More than 23 hours, show full date and time
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
