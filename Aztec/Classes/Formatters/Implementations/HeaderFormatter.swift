import Foundation
import UIKit


// MARK: - Header Formatter
//
open class HeaderFormatter: ParagraphAttributeFormatter {

    /// Heading Level of this formatter
    ///
    let headerLevel: Header.HeaderType

    /// Attributes to be added by default
    ///
    let placeholderAttributes: [NSAttributedStringKey: Any]?


    /// Designated Initializer
    ///
    init(headerLevel: Header.HeaderType = .h1, placeholderAttributes: [NSAttributedStringKey: Any]? = nil) {
        self.headerLevel = headerLevel
        self.placeholderAttributes = placeholderAttributes
    }


    // MARK: - Overwriten Methods

    func apply(to attributes: [NSAttributedStringKey: Any], andStore representation: HTMLRepresentation?) -> [NSAttributedStringKey: Any] {
        guard let font = attributes[.font] as? UIFont else {
            return attributes
        }

        let newParagraphStyle = ParagraphStyle()
        if let paragraphStyle = attributes[.paragraphStyle] as? NSParagraphStyle {
            newParagraphStyle.setParagraphStyle(paragraphStyle)
        }

        let defaultSize = defaultFontSize(from: attributes)
        let header = Header(level: headerLevel, with: representation, defaultFontSize: defaultSize)
        if newParagraphStyle.headers.isEmpty {
            newParagraphStyle.appendProperty(header)
        } else {
            newParagraphStyle.replaceProperty(ofType: Header.self, with: header)
        }

        let targetFontSize = headerFontSize(for: headerLevel, defaultSize: defaultSize)
        var resultingAttributes = attributes
        resultingAttributes[.paragraphStyle] = newParagraphStyle
        resultingAttributes[.font] = font.withSize(CGFloat(targetFontSize))

        return resultingAttributes
    }

    func remove(from attributes: [NSAttributedStringKey: Any]) -> [NSAttributedStringKey: Any] {
        guard let paragraphStyle = attributes[.paragraphStyle] as? ParagraphStyle,
            let header = paragraphStyle.headers.last,
            header.level != .none
        else {
            return attributes
        }

        let newParagraphStyle = ParagraphStyle()
        newParagraphStyle.setParagraphStyle(paragraphStyle)
        newParagraphStyle.removeProperty(ofType: Header.self)

        var resultingAttributes = attributes
        resultingAttributes[.paragraphStyle] = newParagraphStyle

        if let font = attributes[.font] as? UIFont {
            resultingAttributes[.font] = font.withSize(CGFloat(header.defaultFontSize))
        }

        return resultingAttributes
    }

    func present(in attributes: [NSAttributedStringKey: Any]) -> Bool {
        guard let paragraphStyle = attributes[.paragraphStyle] as? ParagraphStyle else {
            return false
        }

        return paragraphStyle.headerLevel != 0 && paragraphStyle.headerLevel == headerLevel.rawValue
    }
}


// MARK: - Private Helpers
//
private extension HeaderFormatter {

    func defaultFontSize(from attributes: [NSAttributedStringKey: Any]) -> Float? {
        if let paragraphStyle = attributes[.paragraphStyle] as? ParagraphStyle,
            let lastHeader = paragraphStyle.headers.last
        {
            return lastHeader.defaultFontSize
        }

        if let font = attributes[.font] as? UIFont {
            return Float(font.pointSize)
        }

        return nil
    }

    func headerFontSize(for type: Header.HeaderType, defaultSize: Float?) -> Float {
        guard type == .none, let defaultSize = defaultSize else {
            return type.fontSize
        }

        return defaultSize
    }
}
