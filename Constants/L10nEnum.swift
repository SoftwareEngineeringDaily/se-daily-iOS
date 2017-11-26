// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
enum L10n {
  /// Email Field Empty
  static let alertMessageEmailEmpty = L10n.tr("Localizable", "AlertMessageEmailEmpty")
  /// Invalid Email Format
  static let alertMessageEmailWrongFormat = L10n.tr("Localizable", "AlertMessageEmailWrongFormat")
  /// First Name Field Empty
  static let alertMessageFirstNameEmpty = L10n.tr("Localizable", "AlertMessageFirstNameEmpty")
  /// First Name must be longer than 1 characters
  static let alertMessageFirstNameNotLongEnough = L10n.tr("Localizable", "AlertMessageFirstNameNotLongEnough")
  /// Issue with User Token
  static let alertMessageIssueWithUserToken = L10n.tr("Localizable", "AlertMessageIssueWithUserToken")
  /// Last Name Field Empty
  static let alertMessageLastNameEmpty = L10n.tr("Localizable", "AlertMessageLastNameEmpty")
  /// Last Name must be longer than 1 characters
  static let alertMessageLastNameNotLongEnough = L10n.tr("Localizable", "AlertMessageLastNameNotLongEnough")
  /// Successfully Logged Out
  static let alertMessageLogoutSuccess = L10n.tr("Localizable", "AlertMessageLogoutSuccess")
  /// Confirm Password Field Empty
  static let alertMessagePasswordConfirmEmpty = L10n.tr("Localizable", "AlertMessagePasswordConfirmEmpty")
  /// Password Field Empty
  static let alertMessagePasswordEmpty = L10n.tr("Localizable", "AlertMessagePasswordEmpty")
  /// Password must be longer than 6 characters
  static let alertMessagePasswordNotLongEnough = L10n.tr("Localizable", "AlertMessagePasswordNotLongEnough")
  /// Password do not match
  static let alertMessagePasswordsDonotMatch = L10n.tr("Localizable", "AlertMessagePasswordsDonotMatch")
  /// Please Login
  static let alertMessagePleaseLogin = L10n.tr("Localizable", "AlertMessagePleaseLogin")
  /// You must login to use this feature.
  static let alertMessageYouMustLogin = L10n.tr("Localizable", "AlertMessageYouMustLogin")
  /// Cancel
  static let cancelButtonTitle = L10n.tr("Localizable", "CancelButtonTitle")
  /// Confirm Password
  static let confirmPasswordPlaceholder = L10n.tr("Localizable", "ConfirmPasswordPlaceholder")
  /// Email
  static let emailAddressPlaceholder = L10n.tr("Localizable", "EmailAddressPlaceholder")
  /// First Name
  static let firstNamePlaceholder = L10n.tr("Localizable", "FirstNamePlaceholder")
  /// Error
  static let genericError = L10n.tr("Localizable", "GenericError")
  /// OK
  static let genericOK = L10n.tr("Localizable", "GenericOK")
  /// Okay
  static let genericOkay = L10n.tr("Localizable", "GenericOkay")
  /// Success
  static let genericSuccess = L10n.tr("Localizable", "GenericSuccess")
  /// Last Name
  static let lastNamePlaceholder = L10n.tr("Localizable", "LastNamePlaceholder")
  /// Login
  static let loginButtonTitle = L10n.tr("Localizable", "LoginButtonTitle")
  /// Login
  static let loginTitle = L10n.tr("Localizable", "LoginTitle")
  /// Logout
  static let logoutTitle = L10n.tr("Localizable", "LogoutTitle")
  /// Password
  static let passwordPlaceholder = L10n.tr("Localizable", "PasswordPlaceholder")
  /// Play
  static let play = L10n.tr("Localizable", "Play")
  /// Sign Up
  static let signUpButtonTitle = L10n.tr("Localizable", "SignUpButtonTitle")
  /// Just For You
  static let tabBarJustForYou = L10n.tr("Localizable", "TabBarJustForYou")
  /// Latest
  static let tabBarTitleLatest = L10n.tr("Localizable", "TabBarTitleLatest")
  /// All
  static let tabTitleAll = L10n.tr("Localizable", "TabTitleAll")
  /// Blockchain
  static let tabTitleBlockchain = L10n.tr("Localizable", "TabTitleBlockchain")
  /// Business and Philosophy
  static let tabTitleBusinessAndPhilosophy = L10n.tr("Localizable", "TabTitleBusinessAndPhilosophy")
  /// Cloud Engineering
  static let tabTitleCloudEngineering = L10n.tr("Localizable", "TabTitleCloudEngineering")
  /// Data
  static let tabTitleData = L10n.tr("Localizable", "TabTitleData")
  /// Greatest Hits
  static let tabTitleGreatestHits = L10n.tr("Localizable", "TabTitleGreatestHits")
  /// Hackers
  static let tabTitleHackers = L10n.tr("Localizable", "TabTitleHackers")
  /// JavaScript
  static let tabTitleJavaScript = L10n.tr("Localizable", "TabTitleJavaScript")
  /// Machine Learning
  static let tabTitleMachineLearning = L10n.tr("Localizable", "TabTitleMachineLearning")
  /// Open Source
  static let tabTitleOpenSource = L10n.tr("Localizable", "TabTitleOpenSource")
  /// Security
  static let tabTitleSecurity = L10n.tr("Localizable", "TabTitleSecurity")
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension L10n {
  fileprivate static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
