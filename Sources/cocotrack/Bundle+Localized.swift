import Foundation

extension Bundle {
    /// Resolves the resource bundle for both `swift run` (SwiftPM `Bundle.module`)
    /// and distributed `.app` bundles (`Contents/Resources/`).
    static let localized: Bundle = {
        let bundleName = "cocotrack_cocotrack"
        let candidates = [
            // SwiftPM: alongside the executable (swift run)
            Bundle.main.bundleURL,
            // .app distribution: Contents/Resources/
            Bundle.main.resourceURL,
        ]
        for candidate in candidates {
            if let candidate,
               let bundle = Bundle(path: candidate.appendingPathComponent(bundleName + ".bundle").path) {
                return bundle
            }
        }
        return Bundle.main
    }()
}
