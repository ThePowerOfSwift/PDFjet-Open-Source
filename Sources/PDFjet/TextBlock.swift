/**
 *  TextBlock.swift
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
/// Class for creating blocks of text.
///
public class TextBlock {

    private var font: Font
    private var fallbackFont: Font?

    private var text: String?
    private var space: Float = 0.0
    private var textAlign = Align.LEFT

    private var x: Float?
    private var y: Float?
    private var w: Float = 300.0
    private var h: Float = 200.0

    private var background = Color.white
    private var brush = Color.black


    ///
    /// Creates a text block.
    ///
    /// @param font the text font.
    ///
    public init(_ font: Font) {
        self.font = font
        self.space = self.font.getDescent()
    }


    ///
    /// Sets the fallback font.
    ///
    /// @param fallbackFont the fallback font.
    /// @return the TextBlock object.
    ///
    @discardableResult
    public func setFallbackFont(_ fallbackFont: Font?) -> TextBlock {
        self.fallbackFont = fallbackFont
        return self
    }


    ///
    /// Sets the block text.
    ///
    /// @param text the block text.
    /// @return the TextBlock object.
    ///
    @discardableResult
    public func setText(_ text: String) -> TextBlock {
        self.text = text
        return self
    }


    ///
    /// Sets the location where this text block will be drawn on the page.
    ///
    /// @param x the x coordinate of the top left corner of the text block.
    /// @param y the y coordinate of the top left corner of the text block.
    /// @return the TextBlock object.
    ///
    @discardableResult
    public func setLocation(_ x: Float, _ y: Float) -> TextBlock {
        self.x = x
        self.y = y
        return self
    }


    ///
    /// Sets the width of this text block.
    ///
    /// @param width the specified width.
    /// @return the TextBlock object.
    ///
    @discardableResult
    public func setWidth(_ width: Float) -> TextBlock {
        self.w = width
        return self
    }


    ///
    /// Returns the text block width.
    ///
    /// @return the text block width.
    ///
    public func getWidth() -> Float {
        return self.w
    }


    ///
    /// Sets the height of this text block.
    ///
    /// @param height the specified height.
    /// @return the TextBlock object.
    ///
    @discardableResult
    public func setHeight(float height: Float) -> TextBlock {
        self.h = height
        return self
    }


    ///
    /// Returns the text block height.
    ///
    /// @return the text block height.
    ///
    public func getHeight() -> Float {
        return drawOn(nil).h
    }


    ///
    /// Sets the space between two lines of text.
    ///
    /// @param space the space between two lines.
    /// @return the TextBlock object.
    ///
    @discardableResult
    public func setSpaceBetweenLines(_ space: Float) -> TextBlock {
        self.space = space
        return self
    }


    ///
    /// Returns the space between two lines of text.
    ///
    /// @return float the space.
    ///
    public func getSpaceBetweenLines() -> Float {
        return self.space
    }


    ///
    /// Sets the text alignment.
    ///
    /// @param textAlign the alignment parameter.
    /// Supported values: Align.LEFT, Align.RIGHT and Align.CENTER.
    ///
    @discardableResult
    public func setTextAlignment(_ textAlign: UInt32) -> TextBlock {
        self.textAlign = textAlign
        return self
    }


    ///
    /// Returns the text alignment.
    ///
    /// @return the alignment code.
    ///
    public func getTextAlignment() -> UInt32 {
        return self.textAlign
    }


    ///
    /// Sets the background to the specified color.
    ///
    /// @param color the color specified as 0xRRGGBB integer.
    /// @return the TextBlock object.
    ///
    @discardableResult
    public func setBgColor(int color: UInt32) -> TextBlock {
        self.background = color
        return self
    }


    ///
    /// Returns the background color.
    ///
    /// @return int the color as 0xRRGGBB integer.
    ///
    public func getBgColor() -> UInt32 {
        return self.background
    }


    ///
    /// Sets the brush color.
    ///
    /// @param color the color specified as 0xRRGGBB integer.
    /// @return the TextBlock object.
    ///
    @discardableResult
    public func setBrushColor(_ color: UInt32) -> TextBlock {
        self.brush = color
        return self
    }


    ///
    /// Returns the brush color.
    ///
    /// @return int the brush color specified as 0xRRGGBB integer.
    ///
    public func getBrushColor() -> UInt32 {
        return self.brush
    }


    // Is the text Chinese, Japanese or Korean?
    private func isCJK(_ text: String) -> Bool {
        var cjk: Int = 0
        var other: Int = 0
        for scalar in text.unicodeScalars {
            if scalar >= "\u{4E00}" && scalar <= "\u{9FFF}" ||          // Unified CJK
                    scalar >= "\u{AC00}" && scalar <= "\u{D7AF}" ||     // Hangul (Korean)
                    scalar >= "\u{30A0}" && scalar <= "\u{30FF}" ||     // Katakana (Japanese)
                    scalar >= "\u{3040}" && scalar <= "\u{309F}" {      // Hiragana (Japanese)
                cjk += 1
            }
            else {
                other += 1
            }
        }
        return cjk > other
    }


    ///
    /// Draws this text block on the specified page.
    ///
    /// @param page the page to draw this text block on.
    /// @return the TextBlock object.
    ///
    @discardableResult
    public func drawOn(_ page: Page?) -> TextBlock {
        if page != nil {
            if getBgColor() != Color.white {
                page!.setBrushColor(self.background)
                page!.fillRect(x!, y!, w, h)
            }
            page!.setBrushColor(self.brush)
        }
        return drawText(page)
    }


    private func drawText(_ page: Page?) -> TextBlock {

        var list = [String]()
        var buf = String()
        var lines = text!.components(separatedBy: "\n")
        for line in lines {
            if isCJK(line) {
                buf = ""
                for ch in line {
                    if font.stringWidth(fallbackFont, buf + String(ch)) < self.w {
                        buf.append(ch)
                    }
                    else {
                        list.append(buf)
                        buf = ""
                        buf.append(ch)
                    }
                }
                if !buf.trim().isEmpty {
                    list.append(buf.trim())
                }
            }
            else {
                if font.stringWidth(fallbackFont, line) < self.w {
                    list.append(line)
                }
                else {
                    buf = ""
                    let tokens = line.components(separatedBy: .whitespaces)
                    for token in tokens {
                        if font.stringWidth(fallbackFont, buf + " " + token) < self.w {
                            buf.append(" " + token)
                        }
                        else {
                            list.append(buf.trim())
                            buf = ""
                            buf.append(token)
                        }
                    }
                    if !buf.trim().isEmpty {
                        list.append(buf.trim())
                    }
                }
            }
        }
        lines = list

        var x_text: Float = 0.0
        var y_text: Float = y! + font.getAscent()

        for i in 0..<lines.count {
            if textAlign == Align.LEFT {
                x_text = x!
            }
            else if textAlign == Align.RIGHT {
                x_text = (x! + self.w) - (font.stringWidth(fallbackFont, lines[i]))
            }
            else if textAlign == Align.CENTER {
                x_text = x! + (self.w - font.stringWidth(fallbackFont, lines[i]))/2
            }
            else {
                // TODO:
                print("Invalid text alignment option.")
            }

            if page != nil {
                page!.drawString(
                        font, fallbackFont, lines[i], x_text, y_text)
            }

            if i < (lines.count - 1) {
                y_text += font.getBodyHeight() + space
            }
            else {
                y_text += font.getDescent() + space
            }
        }

        self.h = y_text - y!

        return self
    }

}   // End of TextBlock.swift
