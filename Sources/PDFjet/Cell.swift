/**
 *  Cell.swift
 *
Copyright (c) 2018, Innovatics Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
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


/**
 *  Used to create table cell objects.
 *  See the Table class for more information.
 *
 */
public class Cell {

    var font: Font?
    var fallbackFont: Font?
    var text: String?
    var image: Image?
    var point: Point?
    var compositeTextLine: CompositeTextLine?
    var ignoreImageHeight = false 

    var width: Float = 70.0
    var top_padding: Float = 2.0
    var bottom_padding: Float = 2.0
    var left_padding: Float = 2.0
    var right_padding: Float = 2.0
    var lineWidth: Float = 0.2

    private var background: UInt32?
    private var pen: UInt32 = Color.black
    private var brush: UInt32 = Color.black

    // Cell properties
    // Colspan:
    // bits 0 to 15
    // Border:
    // bit 16 - top
    // bit 17 - bottom
    // bit 18 - left
    // bit 19 - right
    // Text Alignment:
    // bit 20
    // bit 21
    // Text Decoration:
    // bit 22 - underline
    // bit 23 - strikeout
    // Future use:
    // bits 24 to 31
    private var properties: UInt32 = 0x000F0001
    private var uri: String?

    private var valign = Align.TOP


    /**
     *  Creates a cell object and sets the font.
     *
     *  @param font the font.
     */
    public init(_ font: Font) {
        self.font = font
    }


    /**
     *  Creates a cell object and sets the font and the cell text.
     *
     *  @param font the font.
     *  @param text the text.
     */
    public init(_ font: Font?, _ text: String?) {
        self.font = font
        self.text = text
    }


    /**
     *  Creates a cell object and sets the font, fallback font and the cell text.
     *
     *  @param font the font.
     *  @param fallbackFont the fallback font.
     *  @param text the text.
     */
    public init(_ font: Font?, _ fallbackFont: Font?, _ text: String?) {
        self.font = font
        self.fallbackFont = fallbackFont
        self.text = text
    }


    /**
     *  Sets the font for this cell.
     *
     *  @param font the font.
     */
    public func setFont(_ font: Font?) {
        self.font = font
    }


    /**
     *  Sets the fallback font for this cell.
     *
     *  @param fallbackFont the fallback font.
     */
    public func setFallbackFont(_ fallbackFont: Font?) {
        self.fallbackFont = fallbackFont
    }


    /**
     *  Returns the font used by this cell.
     *
     *  @return the font.
     */
    public func getFont() -> Font? {
        return self.font
    }


    /**
     *  Returns the fallback font used by this cell.
     *
     *  @return the fallback font.
     */
    public func getFallbackFont() -> Font? {
        return self.fallbackFont
    }


    /**
     *  Sets the cell text.
     *
     *  @param text the cell text.
     */
    @discardableResult
    public func setText(_ text: String?) -> Cell {
        self.text = text
        return self
    }


    /**
     *  Returns the cell text.
     *
     *  @return the cell text.
     */
    public func getText() -> String? {
        return self.text
    }


    /**
     *  Sets the image inside this cell.
     *
     *  @param image the image.
     */
    @discardableResult
    public func setImage(_ image: Image?) -> Cell {
        self.image = image
        return self
    }


    /**
     *  Returns the cell image.
     *
     *  @return the image.
     */
    public func getImage() -> Image? {
        return self.image
    }


    /**
     *  Sets the point inside this cell.
     *  See the Point class and Example_09 for more information.
     *
     *  @param point the point.
     */
    @discardableResult
    public func setPoint(_ point: Point?) -> Cell {
        self.point = point
        return self
    }


    /**
     *  Returns the cell point.
     *
     *  @return the point.
     */
    public func getPoint() -> Point? {
        return self.point
    }


    /**
     * Sets the composite text object.
     *
     * @param compositeTextLine the composite text object.
     */
    public func setCompositeTextLine(_ compositeTextLine: CompositeTextLine?) {
        self.compositeTextLine = compositeTextLine
    }


    /**
     * Returns the composite text object.
     *
     * @return the composite text object.
     */
    public func getCompositeTextLine() -> CompositeTextLine? {
        return self.compositeTextLine
    }


    /**
     *  Sets the width of this cell.
     *
     *  @param width the specified width.
     */
    public func setWidth(_ width: Float) {
        self.width = width
    }


    /**
     *  Returns the cell width.
     *
     *  @return the cell width.
     */
    public func getWidth() -> Float {
        return self.width
    }


    /**
     *  Sets the top padding of this cell.
     *
     *  @param padding the top padding.
     */
    public func setTopPadding(_ padding: Float) {
        self.top_padding = padding
    }


    /**
     *  Sets the bottom padding of this cell.
     *
     *  @param padding the bottom padding.
     */
    public func setBottomPadding(_ padding: Float) {
        self.bottom_padding = padding
    }


    /**
     *  Sets the left padding of this cell.
     *
     *  @param padding the left padding.
     */
    public func setLeftPadding(_ padding: Float) {
        self.left_padding = padding
    }


    /**
     *  Sets the right padding of this cell.
     *
     *  @param padding the right padding.
     */
    public func setRightPadding(_ padding: Float) {
        self.right_padding = padding
    }


    /**
     *  Sets the top, bottom, left and right paddings of this cell.
     *
     *  @param padding the right padding.
     */
    public func setPadding(_ padding: Float) {
        self.top_padding = padding
        self.bottom_padding = padding
        self.left_padding = padding
        self.right_padding = padding
    }


    /**
     *  Returns the cell height.
     *
     *  @return the cell height.
     */
    public func getHeight() -> Float {
        if image != nil && !ignoreImageHeight {
            return image!.getHeight()! + top_padding + bottom_padding
        }
        return font!.body_height + top_padding + bottom_padding
    }


    /**
     * Sets the border line width.
     *
     * @param lineWidth the border line width.
     */
    public func setLineWidth(_ lineWidth: Float) {
        self.lineWidth = lineWidth
    }


    /**
     * Returns the border line width.
     *
     * @return the border line width.
     */
    public func getLineWidth() -> Float {
        return self.lineWidth
    }


    /**
     *  Sets the background to the specified color.
     *
     *  @param color the color specified as 0xRRGGBB integer.
     */
    public func setBgColor(_ color: UInt32?) {
        self.background = color
    }


    /**
     *  Returns the background color of this cell.
     *
     */
    public func getBgColor() -> UInt32? {
        return self.background
    }


    /**
     *  Sets the pen color.
     *
     *  @param color the color specified as 0xRRGGBB integer.
     */
    public func setPenColor(_ color: UInt32) {
        self.pen = color
    }


    /**
     *  Returns the pen color.
     *
     */
    public func getPenColor() -> UInt32 {
        return pen
    }


    /**
     *  Sets the brush color.
     *
     *  @param color the color specified as 0xRRGGBB integer.
     */
    public func setBrushColor(_ color: UInt32) {
        self.brush = color
    }


    /**
     *  Returns the brush color.
     *
     * @return the brush color.
     */
    public func getBrushColor() -> UInt32 {
        return brush
    }


    /**
     *  Sets the pen and brush colors to the specified color.
     *
     *  @param color the color specified as 0xRRGGBB integer.
     */
    public func setFgColor(_ color: UInt32) {
        self.pen = color
        self.brush = color
    }


    func setProperties(_ properties: UInt32) {
        self.properties = properties
    }


    func getProperties() -> UInt32 {
        return self.properties
    }


    /**
     *  Sets the column span private variable.
     *
     *  @param colspan the specified column span value.
     */
    public func setColSpan(_ colspan: UInt32) {
        self.properties &= 0x00FF0000
        self.properties |= (colspan & 0x0000FFFF)
    }


    /**
     *  Returns the column span private variable value.
     *
     *  @return the column span value.
     */
    public func getColSpan() -> UInt32 {
        return (self.properties & 0x0000FFFF)
    }


    /**
     *  Sets the cell border object.
     *
     *  @param border the border object.
     */
    public func setBorder(_ border: UInt32, _ visible: Bool) {
        if visible {
            self.properties |= border
        }
        else {
            self.properties &= (~border & 0x00FFFFFF)
        }
    }


    /**
     *  Returns the cell border object.
     *
     *  @return the cell border object.
     */
    public func getBorder(_ border: UInt32) -> Bool {
        return (self.properties & border) != 0
    }


    /**
     *  Sets all border object parameters to false.
     *  This cell will have no borders when drawn on the page.
     */
    public func setNoBorders() {
        self.properties &= 0x00F0FFFF
    }


    /**
     *  Sets the cell text alignment.
     *
     *  @param alignment the alignment code.
     *  Supported values: Align.LEFT, Align.RIGHT and Align.CENTER.
     */
    public func setTextAlignment(_ alignment: UInt32) {
        self.properties &= 0x00CFFFFF
        self.properties |= (alignment & 0x00300000)
    }


    /**
     *  Returns the text alignment.
     *
     *  @return the text horizontal alignment code.
     */
    public func getTextAlignment() -> UInt32{
        return (self.properties & 0x00300000)
    }


    /**
     *  Sets the cell text vertical alignment.
     *
     *  @param alignment the alignment code.
     *  Supported values: Align.TOP, Align.CENTER and Align.BOTTOM.
     */
    public func setVerTextAlignment(_ alignment: UInt32) {
        self.valign = alignment
    }


    /**
     *  Returns the cell text vertical alignment.
     *
     *  @return the vertical alignment code.
     */
    public func getVerTextAlignment() -> UInt32 {
        return self.valign
    }


    /**
     *  Sets the underline text parameter.
     *  If the value of the underline variable is 'true' - the text is underlined.
     *
     *  @param underline the underline text parameter.
     */
    public func setUnderline(_ underline: Bool) {
        if underline {
            self.properties |= 0x00400000
        }
        else {
            self.properties &= 0x00BFFFFF
        }
    }


    /**
     * Returns the underline text parameter.
     *
     * @return the underline text parameter.
     */
    public func getUnderline() -> Bool {
        return (properties & 0x00400000) != 0
    }


    /**
     * Sets the strikeout text parameter.
     *
     * @param strikeout the strikeout text parameter.
     */
    public func setStrikeout(_ strikeout: Bool) {
        if strikeout {
            self.properties |= 0x00800000
        }
        else {
            self.properties &= 0x007FFFFF
        }
    }


    /**
     * Returns the strikeout text parameter.
     *
     * @return the strikeout text parameter.
     */
    public func getStrikeout() -> Bool{
        return (properties & 0x00800000) != 0
    }


    public func setURIAction(_ uri: String) {
        self.uri = uri
    }


    /**
     *  Draws the point, text and borders of this cell.
     *
     */
    func paint(
            _ page: Page,
            _ x: Float,
            _ y: Float,
            _ w: Float,
            _ h: Float) {
        if background != nil {
            drawBackground(page, x, y, w, h)
        }
        if image != nil {
            image!.setLocation(x + left_padding, y + top_padding)
            image!.drawOn(page)
        }
        drawBorders(page, x, y, w, h)
        if text != nil {
            drawText(page, x, y, w, h)
        }
        if point != nil {
            if point!.align == Align.LEFT {
                point!.x = x + 2*point!.r
            }
            else if point!.align == Align.RIGHT {
                point!.x = (x + w) - self.right_padding/2
            }
            point!.y = y + h/2
            page.setBrushColor(point!.getColor())
            if point!.getURIAction() != nil {
                page.addAnnotation(Annotation(
                        point!.getURIAction(),
                        "", // nil, // TODO:
                        point!.x - point!.r,
                        page.height - (point!.y - point!.r),
                        point!.x + point!.r,
                        page.height - (point!.y + point!.r),
                        "", // nil, // TODO:
                        nil,
                        nil))
            }
            page.drawPoint(point!)
        }
    }


    private func drawBackground(
            _ page: Page,
            _ x: Float,
            _ y: Float,
            _ cell_w: Float,
            _ cell_h: Float) {
        page.setBrushColor(background!)
        page.fillRect(x, y + lineWidth / 2, cell_w, cell_h + lineWidth)
    }


    private func drawBorders(
            _ page: Page,
            _ x: Float,
            _ y: Float,
            _ cell_w: Float,
            _ cell_h: Float) {

        page.setPenColor(pen)
        page.setPenWidth(lineWidth)

        if getBorder(Border.TOP) &&
                getBorder(Border.BOTTOM) &&
                getBorder(Border.LEFT) &&
                getBorder(Border.RIGHT) {
            page.addBMC(StructElem.SPAN, Single.space, Single.space)
            page.drawRect(x, y, cell_w, cell_h)
            page.addEMC()
        }
        else {
            let qWidth: Float = lineWidth / 4
            if getBorder(Border.TOP) {
                page.addBMC(StructElem.SPAN, Single.space, Single.space)
                page.moveTo(x - qWidth, y)
                page.lineTo(x + cell_w, y)
                page.strokePath()
                page.addEMC()
            }
            if getBorder(Border.BOTTOM) {
                page.addBMC(StructElem.SPAN, Single.space, Single.space)
                page.moveTo(x - qWidth, y + cell_h)
                page.lineTo(x + cell_w, y + cell_h)
                page.strokePath()
                page.addEMC()
            }
            if getBorder(Border.LEFT) {
                page.addBMC(StructElem.SPAN, Single.space, Single.space)
                page.moveTo(x, y - qWidth)
                page.lineTo(x, y + cell_h + qWidth)
                page.strokePath()
                page.addEMC()
            }
            if getBorder(Border.RIGHT) {
                page.addBMC(StructElem.SPAN, Single.space, Single.space)
                page.moveTo(x + cell_w, y - qWidth)
                page.lineTo(x + cell_w, y + cell_h + qWidth)
                page.strokePath()
                page.addEMC()
            }
        }

    }


    private func drawText(
            _ page: Page,
            _ x: Float,
            _ y: Float,
            _ cell_w: Float,
            _ cell_h: Float) {

        var x_text: Float?
        var y_text: Float?
        if valign == Align.TOP {
            y_text = y + font!.ascent + self.top_padding
        }
        else if valign == Align.CENTER {
            y_text = y + cell_h/2 + font!.ascent/2
        }
        else if valign == Align.BOTTOM {
            y_text = (y + cell_h) - self.bottom_padding
        }
        else {
            //throw new Exception("Invalid vertical text alignment option.")
        }

        page.setPenColor(pen)
        page.setBrushColor(brush)

        if getTextAlignment() == Align.RIGHT {
            if compositeTextLine == nil {
                x_text = (x + cell_w) - (font!.stringWidth(text) + self.right_padding)
                page.addBMC(StructElem.SPAN, text!, text!)
                page.drawString(font!, fallbackFont, text!, x_text!, y_text!)
                page.addEMC()
                if getUnderline() {
                    underlineText(page, font!, text!, x_text!, y_text!)
                }
                if getStrikeout() {
                    strikeoutText(page, font!, text!, x_text!, y_text!)
                }
            }
            else {
                x_text = (x + cell_w) - (compositeTextLine!.getWidth() + self.right_padding)
                compositeTextLine!.setLocation(x_text!, y_text!)
                page.addBMC(StructElem.SPAN, text!, text!)
                compositeTextLine!.drawOn(page)
                page.addEMC()
            }
        }
        else if getTextAlignment() == Align.CENTER {
            if compositeTextLine == nil {
                x_text = x + self.left_padding +
                        (((cell_w - (left_padding + right_padding)) - font!.stringWidth(text)) / 2)
                page.addBMC(StructElem.SPAN, text!, text!)
                page.drawString(font!, fallbackFont, text!, x_text!, y_text!)
                page.addEMC()
                if getUnderline() {
                    underlineText(page, font!, text!, x_text!, y_text!)
                }
                if getStrikeout() {
                    strikeoutText(page, font!, text!, x_text!, y_text!)
                }
            }
            else {
                x_text = x + self.left_padding +
                        (((cell_w - (left_padding + right_padding)) - compositeTextLine!.getWidth()) / 2)
                compositeTextLine!.setLocation(x_text!, y_text!)
                page.addBMC(StructElem.SPAN, text!, text!)
                compositeTextLine!.drawOn(page)
                page.addEMC()
            }
        }
        else if getTextAlignment() == Align.LEFT {
            x_text = x + self.left_padding
            if compositeTextLine == nil {
                page.addBMC(StructElem.SPAN, text!, text!)
                page.drawString(font!, fallbackFont, text!, x_text!, y_text!)
                page.addEMC()
                if getUnderline() {
                    underlineText(page, font!, text!, x_text!, y_text!)
                }
                if getStrikeout() {
                    strikeoutText(page, font!, text!, x_text!, y_text!)
                }
            }
            else {
                compositeTextLine!.setLocation(x_text!, y_text!)
                page.addBMC(StructElem.SPAN, text!, text!)
                compositeTextLine!.drawOn(page)
                page.addEMC()
            }
        }
        else {
            print("Invalid Text Alignment!")
        }

        if uri != nil {
            let w = (compositeTextLine != nil) ?
                    compositeTextLine!.getWidth() : font!.stringWidth(text)
            // Please note: The font descent is a negative number.
            page.addAnnotation(Annotation(
                    uri!,
                    "", // nil, // TODO:
                    x_text!,
                    (page.height - y_text!) + font!.descent,
                    x_text! + w,
                    (page.height - y_text!) + font!.ascent,
                    "", // nil, // TODO:
                    nil,
                    nil))
        }
    }


    private func underlineText(
            _ page: Page, _ font: Font, _ text: String, _ x: Float, _ y: Float) {
        let descent = font.getDescent()
        page.addBMC(StructElem.SPAN, "underline", "underline")
        page.setPenWidth(font.underlineThickness)
        page.moveTo(x, y + descent)
        page.lineTo(x + font.stringWidth(text), y + descent)
        page.strokePath()
        page.addEMC()
    }


    private func strikeoutText(
            _ page: Page, _ font: Font, _ text: String, _ x: Float, _ y: Float) {
        page.addBMC(StructElem.SPAN, "strike out", "strike out")
        page.setPenWidth(font.underlineThickness)
        page.moveTo(x, y - font.getAscent()/3.0)
        page.lineTo(x + font.stringWidth(text), y - font.getAscent()/3.0)
        page.strokePath()
        page.addEMC()
    }


    /**
     *  Use this method to find out how many vertically stacked cell are needed after call to wrapAroundCellText.
     *
     *  @return the number of vertical cells needed to wrap around the cell text.
     */
    public func getNumVerCells() -> Int {
        var n = 1
        if getText() == nil {
            return n
        }

        let textLines = getText()!.components(separatedBy: "\n")
        if textLines.count == 0 {
            return n
        }

        n = 0
        for textLine in textLines {
            let tokens = textLine.components(separatedBy: .whitespacesAndNewlines)
            var sb = String()
            if tokens.count > 1 {
                for i in 0..<tokens.count {
                    let token = tokens[i]
                    if font!.stringWidth(sb + " " + token) >
                            (getWidth() - (self.left_padding + self.right_padding)) {
                        sb = String(token)
                        n += 1
                    }
                    else {
                        if i > 0 {
                            sb.append(" ")
                        }
                        sb.append(String(token))
                    }
                }
            }
            n += 1
        }

        return n
    }


    /**
     *  Use this method to find out how many vertically stacked cell are needed after call to wrapAroundCellText2.
     *
     *  @return the number of vertical cells needed to wrap around the cell text.
     */
    public func getNumVerCells2() -> Int {
        var n = 1
        if getText() == nil {
            return n
        }
        var sb = String()
        for character in self.text! {
            if font!.stringWidth(sb + String(character)) >
                    (getWidth() - (self.left_padding + self.right_padding)) {
                n += 1
                sb = ""
            }
            sb.append(String(character))
        }
        return n
    }


    public func setIgnoreImageHeight(_ ignoreImageHeight: Bool) {
        self.ignoreImageHeight = ignoreImageHeight
    }


    public func getIgnoreImageHeight() -> Bool {
        return self.ignoreImageHeight
    }

}   // End of Cell.swift
