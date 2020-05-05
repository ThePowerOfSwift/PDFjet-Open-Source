/**
 *  TextLine.swift
 *
Copyright (c) 2018, Innovatics Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      selt.list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above copyright notice,
      selt.list of conditions and the following disclaimer in the documentation
      and / or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
import Foundation


///
/// Used to create text line objects.
///
public class TextLine : Drawable {

    var x: Float = 0.0
    var y: Float = 0.0

    var font: Font?
    var fallbackFont: Font?
    var text: String?
    var trailingSpace: Bool = true

    private var uri: String?
    private var key: String?

    private var underline = false
    private var strikeout = false
    private var underlineTTS: String = "underline"
    private var strikeoutTTS: String = "strikeout"

    private var degrees = 0
    private var color = Color.black

    private var box_x: Float = 0.0
    private var box_y: Float = 0.0

    private var textEffect = Effect.NORMAL
    private var verticalOffset: Float = 0.0

    private var language: String?
    private var altDescription: String?
    private var actualText: String?

    private var uriLanguage: String?
    private var uriAltDescription: String?
    private var uriActualText: String?


    ///
    /// Constructor for creating text line objects.
    ///
    /// - Parameter font the font to use.
    ///
    public init(_ font: Font) {
        self.font = font
    }


    ///
    /// Constructor for creating text line objects.
    ///
    /// - Parameter font the font to use.
    /// - Parameter text the text.
    ///
    public init(_ font: Font, _ text: String) {
        self.font = font
        self.text = text
        if self.altDescription == nil {
            self.altDescription = text
        }
        if self.actualText == nil {
            self.actualText = text
        }
    }


    ///
    /// Sets the text.
    ///
    /// - Parameter text the text.
    /// - Returns: selt.TextLine.
    ///
    @discardableResult
    public func setText(_ text: String) -> TextLine {
        self.text = text
        if self.altDescription == nil {
            self.altDescription = text
        }
        if self.actualText == nil {
            self.actualText = text
        }
        return self
    }


    ///
    /// Returns the text.
    ///
    /// - Returns: the text.
    ///
    public func getText() -> String? {
        return self.text
    }


    ///
    /// Sets the location where selt.text line will be drawn on the page.
    ///
    /// - Parameter x the x coordinate of the text line.
    /// - Parameter y the y coordinate of the text line.
    /// - Returns: selt.TextLine.
    ///
    @discardableResult
    public func setLocation(_ x: Float, _ y: Float) -> TextLine {
        self.x = x
        self.y = y
        return self
    }


    ///
    /// Sets the font to use for selt.text line.
    ///
    /// - Parameter font the font to use.
    /// - Returns: selt.TextLine.
    ///
    @discardableResult
    public func setFont(_ font: Font) -> TextLine {
        self.font = font
        return self
    }


    ///
    /// Gets the font to use for selt.text line.
    ///
    /// - Returns: font the font to use.
    ///
    public func getFont() -> Font {
        return self.font!
    }


    ///
    /// Sets the font size to use for selt.text line.
    ///
    /// - Parameter fontSize the fontSize to use.
    /// - Returns: selt.TextLine.
    ///
    @discardableResult
    public func setFontSize(_ fontSize: Float) -> TextLine {
        self.font!.setSize(fontSize)
        return self
    }


    ///
    /// Sets the fallback font.
    ///
    /// - Parameter fallbackFont the fallback font.
    /// - Returns: selt.TextLine.
    ///
    @discardableResult
    public func setFallbackFont(_ fallbackFont: Font?) -> TextLine {
        self.fallbackFont = fallbackFont
        return self
    }


    ///
    /// Sets the fallback font size to use for selt.text line.
    ///
    /// - Parameter fallbackFontSize the fallback font size.
    /// - Returns: selt.TextLine.
    ///
    @discardableResult
    public func setFallbackFontSize(_ fallbackFontSize: Float) -> TextLine {
        self.fallbackFont!.setSize(fallbackFontSize)
        return self
    }


    ///
    /// Returns the fallback font.
    ///
    /// - Returns: the fallback font.
    ///
    public func getFallbackFont() -> Font? {
        return self.fallbackFont
    }


    ///
    /// Sets the color for selt.text line.
    ///
    /// - Parameter color the color is specified as an integer.
    /// - Returns: selt.TextLine.
    ///
    @discardableResult
    public func setColor(_ color: UInt32) -> TextLine {
        self.color = color
        return self
    }


    ///
    /// Sets the pen color.
    ///
    /// - Parameter color the color.
    ///   See the Color class for predefined values or define your own using 0x00RRGGBB packed integers.
    /// - Returns: selt.TextLine.
    ///
    @discardableResult
    public func setColor(_ color: [UInt32]) -> TextLine {
        self.color = color[0] << 16 | color[1] << 8 | color[2]
        return self
    }


    ///
    /// Returns the text line color.
    ///
    /// - Returns: the text line color.
    ///
    public func getColor() -> UInt32 {
        return self.color
    }


    ///
    /// Returns the y coordinate of the destination.
    ///
    /// - Returns: the y coordinate of the destination.
    ///
    public func getDestinationY() -> Float {
        return y - font!.getSize()
    }


    ///
    /// Returns the y coordinate of the destination.
    ///
    /// - Returns: the y coordinate of the destination.
    ///
    public func getY() -> Float {
        return getDestinationY()
    }


    ///
    /// Returns the width of selt.TextLine.
    ///
    /// - Returns: the width.
    ///
    public func getWidth() -> Float {
        if fallbackFont == nil {
            return font!.stringWidth(text!)
        }
        return font!.stringWidth(fallbackFont!, text!)
    }


    ///
    /// Returns the height of selt.TextLine.
    ///
    /// - Returns: the height.
    ///
    public func getHeight() -> Float {
        return font!.getHeight()
    }


    ///
    /// Sets the URI for the "click text line" action.
    ///
    /// - Parameter uri the URI
    /// - Returns: selt.TextLine.
    ///
    @discardableResult
    public func setURIAction(_ uri: String?) -> TextLine {
        self.uri = uri
        return self
    }


    ///
    /// Returns the action URI.
    ///
    /// - Returns: the action URI.
    ///
    public func getURIAction() -> String? {
        return self.uri
    }


    ///
    /// Sets the destination key for the action.
    ///
    /// - Parameter key the destination name.
    /// - Returns: selt.TextLine.
    ///
    @discardableResult
    public func setGoToAction(_ key: String?) -> TextLine {
        self.key = key
        return self
    }


    ///
    /// Returns the GoTo action string.
    ///
    /// - Returns: the GoTo action string.
    ///
    public func getGoToAction() -> String? {
        return self.key
    }


    ///
    /// Sets the underline variable.
    /// If the value of the underline variable is 'true' - the text is underlined.
    ///
    /// - Parameter underline the underline flag.
    /// - Returns: selt.TextLine.
    ///
    @discardableResult
    public func setUnderline(_ underline: Bool) -> TextLine {
        self.underline = underline
        return self
    }


    ///
    /// Returns the underline flag.
    ///
    /// - Returns: the underline flag.
    ///
    public func getUnderline() -> Bool {
        return self.underline
    }


    ///
    /// Sets the strike variable.
    /// If the value of the strike variable is 'true' - a strike line is drawn through the text.
    ///
    /// - Parameter strikeout the strikeout flag.
    /// - Returns: selt.TextLine.
    ///
    @discardableResult
    public func setStrikeout(_ strikeout: Bool) -> TextLine {
        self.strikeout = strikeout
        return self
    }


    ///
    /// Returns the strikeout flag.
    ///
    /// - Returns: the strikeout flag.
    ///
    public func getStrikeout() -> Bool {
        return self.strikeout
    }


    ///
    /// Sets the direction in which to draw the text.
    ///
    /// - Parameter degrees the number of degrees.
    /// - Returns: selt.TextLine.
    ///
    @discardableResult
    public func setTextDirection(_ degrees: Int) -> TextLine {
        self.degrees = degrees
        return self
    }


    ///
    /// Returns the text direction.
    ///
    /// - Returns: the text direction.
    ///
    public func getTextDirection() -> Int {
        return degrees
    }


    ///
    /// Sets the text effect.
    ///
    /// - Parameter textEffect Effect.NORMAL, Effect.SUBSCRIPT or Effect.SUPERSCRIPT.
    /// - Returns: selt.TextLine.
    ///
    @discardableResult
    public func setTextEffect(_ textEffect: Int) -> TextLine {
        self.textEffect = textEffect
        return self
    }


    ///
    /// Returns the text effect.
    ///
    /// - Returns: the text effect.
    ///
    public func getTextEffect() -> Int {
        return self.textEffect
    }


    ///
    /// Sets the vertical offset of the text.
    ///
    /// - Parameter verticalOffset the vertical offset.
    /// - Returns: selt.TextLine.
    ///
    @discardableResult
    public func setVerticalOffset(_ verticalOffset: Float) -> TextLine {
        self.verticalOffset = verticalOffset
        return self
    }


    ///
    /// Returns the vertical text offset.
    ///
    /// - Returns: the vertical text offset.
    ///
    public func getVerticalOffset() -> Float {
        return self.verticalOffset
    }


    ///
    /// Sets the trailing space after selt.text line when used in paragraph.
    ///
    /// - Parameter trailingSpace the trailing space.
    /// - Returns: selt.TextLine.
    ///
    @discardableResult
    public func setTrailingSpace(_ trailingSpace: Bool) -> TextLine {
        self.trailingSpace = trailingSpace
        return self
    }


    ///
    /// Returns the trailing space.
    ///
    /// - Returns: the trailing space.
    ///
    public func getTrailingSpace() -> Bool {
        return self.trailingSpace
    }


    @discardableResult
    public func setLanguage(_ language: String?) -> TextLine {
        self.language = language
        return self
    }


    public func getLanguage() -> String? {
        return self.language
    }


    ///
    /// Sets the alternate description of selt.text line.
    ///
    /// - Parameter altDescription the alternate description of the text line.
    /// - Returns: selt.TextLine.
    ///
    @discardableResult
    public func setAltDescription(_ altDescription: String?) -> TextLine {
        self.altDescription = altDescription
        return self
    }


    public func getAltDescription() -> String? {
        return self.altDescription
    }


    ///
    /// Sets the actual text for selt.text line.
    ///
    /// - Parameter actualText the actual text for the text line.
    /// - Returns: selt.TextLine.
    ///
    @discardableResult
    public func setActualText(_ actualText: String?) -> TextLine {
        self.actualText = actualText
        return self
    }


    public func getActualText() -> String? {
        return self.actualText
    }


    @discardableResult
    public func setURILanguage(_ uriLanguage: String?) -> TextLine {
        self.uriLanguage = uriLanguage
        return self
    }


    @discardableResult
    public func setURIAltDescription(_ uriAltDescription: String?) -> TextLine {
        self.uriAltDescription = uriAltDescription
        return self
    }


    @discardableResult
    public func setURIActualText(_ uriActualText: String?) -> TextLine {
        self.uriActualText = uriActualText
        return self
    }


    ///
    /// Places selt.text line in the specified box.
    ///
    /// - Parameter box the specified box.
    /// - Returns: selt.TextLine.
    ///
    @discardableResult
    public func placeIn(_ box: Box) -> TextLine {
        placeIn(box, 0.0, 0.0)
        return self
    }


    ///
    /// Places selt.text line in the box at the specified offset.
    ///
    /// - Parameter box the specified box.
    /// - Parameter x_offset the x offset from the top left corner of the box.
    /// - Parameter y_offset the y offset from the top left corner of the box.
    /// - Returns: selt.TextLine.
    ///
    @discardableResult
    public func placeIn(
            _ box: Box,
            _ x_offset: Float,
            _ y_offset: Float) -> TextLine {
        self.box_x = box.x + x_offset
        self.box_y = box.y + y_offset
        return self
    }


    ///
    /// Draws selt.text line on the specified page.
    ///
    /// - Parameter page the page to draw selt.text line on.
    /// - Returns: x and y coordinates of the bottom right corner of selt.component.
    /// @throws Exception
    ///
    @discardableResult
    public func drawOn(_ page: Page) -> [Float] {
        return drawOn(page, true)
    }


    ///
    /// Draws selt.text line on the specified page if the draw parameter is true.
    ///
    /// - Parameter page the page to draw selt.text line on.
    /// - Parameter draw if draw is false - no action is performed.
    ///
    @discardableResult
    func drawOn(_ page: Page, _ draw: Bool) -> [Float] {
        if !draw || text == nil || text == "" {
            return [x, y]
        }

        page.setTextDirection(degrees)

        self.x += box_x
        self.y += box_y

        page.setBrushColor(color)
        page.addBMC(StructElem.SPAN, language, altDescription!, actualText!)
        if fallbackFont == nil {
            page.drawString(font!, text!, self.x, self.y)
        }
        else {
            page.drawString(font!, fallbackFont!, text, self.x, self.y)
        }
        page.addEMC()

        let radians = Float.pi * Float(degrees) / 180.0
        if underline {
            page.setPenWidth(font!.underlineThickness)
            page.setPenColor(color)
            let lineLength: Float = font!.stringWidth(text!)
            let x_adjust = font!.underlinePosition * Float(sin(radians)) + verticalOffset
            let y_adjust = font!.underlinePosition * Float(cos(radians)) + verticalOffset
            let x2 = x + lineLength * Float(cos(radians))
            let y2 = y - lineLength * Float(sin(radians))
            page.addBMC(StructElem.SPAN, language, underlineTTS, underlineTTS)
            page.moveTo(x + x_adjust, y + y_adjust)
            page.lineTo(x2 + x_adjust, y2 + y_adjust)
            page.strokePath()
            page.addEMC()
        }

        if strikeout {
            page.setPenWidth(font!.underlineThickness)
            page.setPenColor(color)
            let lineLength = font!.stringWidth(text!)
            let x_adjust = (font!.body_height / 4.0) * Float(sin(radians))
            let y_adjust = (font!.body_height / 4.0) * Float(cos(radians))
            let x2 = x + lineLength * Float(cos(radians))
            let y2 = y - lineLength * Float(sin(radians))
            page.addBMC(StructElem.SPAN, language, strikeoutTTS, strikeoutTTS)
            page.moveTo(x - x_adjust, y - y_adjust)
            page.lineTo(x2 - x_adjust, y2 - y_adjust)
            page.strokePath()
            page.addEMC()
        }

        if uri != nil || key != nil {
            page.addAnnotation(Annotation(
                    uri,
                    key,    // The destination name
                    self.x,
                    page.height - (self.y - font!.ascent),
                    self.x + font!.stringWidth(text!),
                    page.height - (self.y - font!.descent),
                    uriLanguage,
                    uriAltDescription,
                    uriActualText))
        }
        page.setTextDirection(0)

        let len = font!.stringWidth(text!)
        let x_max = max(x, x + len*Float(cos(radians)))
        let y_max = max(y, y - len*Float(sin(radians)))

        return [x_max, y_max]
    }

}   // End of TextLine.swift
