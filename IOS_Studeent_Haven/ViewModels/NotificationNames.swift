import Foundation

/// Extension for custom notification names
extension Notification.Name {
    /// Notification sent when a user successfully logs in
    static let userDidLogin = Notification.Name("userDidLogin")
    
    /// Notification sent when a user successfully registers
    static let userDidRegister = Notification.Name("UserDidRegister")
}
