/**
 *  TextFrame.swift
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


///
/// Please see Example_47
///
public class TextFrame {

    private var paragraphs: [Paragraph]?
    private var font: Font?
    private var fallbackFont: Font?
    private var x: Float = 0.0
    private var y: Float = 0.0
    private var w: Float = 0.0
    private var h: Float = 0.0
    private var x_text: Float = 0.0
    private var y_text: Float = 0.0
    private var leading: Float = 0.0
    private var paragraphLeading: Float = 0.0
    private var beginParagraphPoints: [[Float]]?
    private var endParagraphPoints: [[Float]]?
    private var spaceBetweenTextLines: Float = 0.0


    public init(_ paragraphs: [Paragraph]?) {
        if paragraphs != nil {
            self.paragraphs = paragraphs!
            self.font = paragraphs![0].list![0].getFont()
            self.fallbackFont = paragraphs![0].list![0].getFallbackFont()
            self.leading = font!.getBodyHeight()
            self.paragraphLeading = 2*leading
            self.beginParagraphPoints = [[Float]]()
            self.endParagraphPoints = [[Float]]()
            self.spaceBetweenTextLines = font!.stringWidth(fallbackFont, Single.space)
        }
    }


    @discardableResult
    public func setLocation(_ x: Float, _ y: Float) -> TextFrame {
        self.x = x
        self.y = y
        return self
    }


    @discardableResult
    public func setWidth(_ w: Float) -> TextFrame {
        self.w = w
        return self
    }


    @discardableResult
    public func setHeight(_ h: Float) -> TextFrame {
        self.h = h
        return self
    }


    @discardableResult
    public func setLeading(_ leading: Float) -> TextFrame {
        self.leading = leading
        return self
    }


    @discardableResult
    public func setParagraphLeading(_ paragraphLeading: Float) -> TextFrame {
        self.paragraphLeading = paragraphLeading
        return self
    }


    @discardableResult
    public func getBeginParagraphPoints() -> [[Float]]? {
        return self.beginParagraphPoints
    }


    public func getEndParagraphPoints() -> [[Float]]? {
        return self.endParagraphPoints
    }


    @discardableResult
    public func setSpaceBetweenTextLines(_ spaceBetweenTextLines: Float) -> TextFrame {
        self.spaceBetweenTextLines = spaceBetweenTextLines
        return self
    }


    public func getParagraphs() -> [Paragraph]? {
        return self.paragraphs
    }


    @discardableResult
    public func drawOn(_ page: Page) -> TextFrame {
        return drawOn(page, true)
    }


    @discardableResult
    public func drawOn(_ page: Page, _ draw: Bool) -> TextFrame {
        self.x_text = x
        self.y_text = y + font!.getAscent()

        var paragraph: Paragraph
        var i = 0
        while i < paragraphs!.count {
            paragraph = paragraphs![i]

            var buf = String()
            for textLine in paragraph.list! {
                buf.append(textLine.getText()!)
                buf.append(Single.space)
            }

            let numOfTextLines = paragraph.list!.count
            var j = 0
            while j < numOfTextLines {
                let textLine1 = paragraph.list![j]
                if j == 0 {
                    beginParagraphPoints!.append([x_text, y_text])
                }
                textLine1.setAltDescription((j == 0) ? buf : Single.space)
                textLine1.setActualText((j == 0) ? buf : Single.space)

                let textLine2 = drawTextLine(page, textLine1, draw)!
                if textLine2.getText() != "" {
                    var theRest = [Paragraph]()
                    let paragraph2 = Paragraph(textLine2)
                    j += 1
                    while j < numOfTextLines {
                        paragraph2.add(paragraph.list![j])
                        j += 1
                    }
                    theRest.append(paragraph2)
                    i += 1
                    while i < paragraphs!.count {
                        theRest.append(paragraphs![i])
                        i += 1
                    }
                    return TextFrame(theRest)
                }

                if j == (numOfTextLines - 1) {
                    endParagraphPoints!.append([textLine2.x, textLine2.y])
                }
                x_text = textLine2.x
                if textLine1.getTrailingSpace() {
                    x_text += spaceBetweenTextLines
                }
                y_text = textLine2.y

                j += 1
            }
            x_text = x
            y_text += paragraphLeading

            i += 1
        }

        let textFrame = TextFrame(nil)
        textFrame.setLocation(x_text, y_text + font!.getDescent())
        return textFrame
    }


    @discardableResult
    public func drawTextLine(
            _ page: Page,
            _ textLine: TextLine,
            _ draw: Bool) -> TextLine? {

        var textLine2: TextLine?
        let font = textLine.getFont()
        let fallbackFont = textLine.getFallbackFont()
        let color = textLine.getColor()

        var buf = String()
        var tokens = textLine.text!.components(separatedBy: .whitespaces)
        var firstTextSegment: Bool = true

        var i: Int = 0
        while i < tokens.count {
            let token = (i == 0) ? tokens[i] : (Single.space + tokens[i])
            if font.stringWidth(fallbackFont, token) < (self.w - (x_text - x)) {
                buf.append(token)
                x_text += font.stringWidth(fallbackFont, token)
            }
            else {
                if draw {
                    TextLine(font, buf)
                            .setFallbackFont(fallbackFont)
                            .setLocation(
                                    x_text - font.stringWidth(fallbackFont, buf),
                                    y_text + textLine.getVerticalOffset())
                            .setColor(color)
                            .setUnderline(textLine.getUnderline())
                            .setStrikeout(textLine.getStrikeout())
                            .setLanguage(textLine.getLanguage())
                            .setAltDescription(firstTextSegment ?
                                    textLine.getAltDescription() : Single.space)
                            .setActualText(firstTextSegment ?
                                    textLine.getActualText() : Single.space)
                            .drawOn(page)
                    firstTextSegment = false
                }
                x_text = x + font.stringWidth(fallbackFont, tokens[i])
                y_text += leading
                buf = ""
                buf.append(tokens[i])
                if y_text + font.getDescent() > (y + h) {
                    i += 1
                    while i < tokens.count {
                        buf.append(Single.space)
                        buf.append(tokens[i])
                        i += 1
                    }
                    textLine2 = TextLine(font, buf)
                    textLine2!.setLocation(x, y_text)
                    return textLine2
                }
            }

            i += 1
        }

        if draw {
            TextLine(font, buf)
                    .setFallbackFont(fallbackFont)
                    .setLocation(
                            x_text - font.stringWidth(fallbackFont, buf),
                            y_text + textLine.getVerticalOffset())
                    .setColor(color)
                    .setUnderline(textLine.getUnderline())
                    .setStrikeout(textLine.getStrikeout())
                    .setLanguage(textLine.getLanguage())
                    .setAltDescription(firstTextSegment ?
                            textLine.getAltDescription() : Single.space)
                    .setActualText(firstTextSegment ?
                            textLine.getActualText() : Single.space)
                    .drawOn(page)
            firstTextSegment = false
        }

        textLine2 = TextLine(font, "")
        textLine2!.setLocation(x_text, y_text)
        return textLine2
    }

}   // End of TextFrame.swift
