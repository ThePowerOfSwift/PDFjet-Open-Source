/**
 *  CompositeTextLine.swift
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

/*
 *  This class was designed and implemented by Jon T. Swanson, Ph.D.
 *
 *  Refactored and integrated into the project by Eugene Dragoev - 2nd June 2012.
 */
import Foundation


/**
 *  Used to create composite text line objects.
 *
 *
 */
public class CompositeTextLine : Drawable {

    private let X = 0
    private let Y = 1

    private var textLines = [TextLine]()

    private var position = [Float](repeating: 0, count: 2)
    private var current  = [Float](repeating: 0, count: 2)

    // Subscript and Superscript size factors
    private var subscript_size_factor: Float = 0.583
    private var superscript_size_factor: Float  = 0.583

    // Subscript and Superscript positions in relation to the base font
    private var superscript_position: Float = 0.350
    private var subscript_position: Float = 0.141

    private var fontSize: Float = 0


    public init(_ x: Float, _ y: Float) {
        self.position[X] = x
        self.position[Y] = y
        self.current[X]  = x
        self.current[Y]  = y
    }


    /**
     *  Sets the font size.
     *
     *  @param fontSize the font size.
     */
    @discardableResult
    public func setFontSize(_ fontSize: Float) -> CompositeTextLine {
        self.fontSize = fontSize
        return self
    }


    /**
     *  Gets the font size.
     *
     *  @return fontSize the font size.
     */
    public func getFontSize()-> Float {
        return self.fontSize
    }


    /**
     *  Sets the superscript factor for this composite text line.
     *
     *  @param superscript the superscript size factor.
     */
    @discardableResult
    public func setSuperscriptFactor(_ superscriptSizeFactor: Float) -> CompositeTextLine {
        self.superscript_size_factor = superscriptSizeFactor
        return self
    }


    /**
     *  Gets the superscript factor for this text line.
     *
     *  @return superscript the superscript size factor.
     */
    public func getSuperscriptFactor()-> Float {
        return self.superscript_size_factor
    }


    /**
     *  Sets the subscript factor for this composite text line.
     *
     *  @param subscript the subscript size factor.
     */
    @discardableResult
    public func setSubscriptFactor(_ subscriptSizeFactor: Float) -> CompositeTextLine {
        self.subscript_size_factor = subscriptSizeFactor
        return self
    }


    /**
     *  Gets the subscript factor for this text line.
     *
     *  @return subscript the subscript size factor.
     */
    public func getSubscriptFactor()-> Float {
        return self.subscript_size_factor
    }


    /**
     *  Sets the superscript position for this composite text line.
     *
     *  @param superscript_position the superscript position.
     */
    @discardableResult
    public func setSuperscriptPosition(_ superscript_position: Float) -> CompositeTextLine {
        self.superscript_position = superscript_position
        return self
    }


    /**
     *  Gets the superscript position for this text line.
     *
     *  @return superscript_position the superscript position.
     */
    public func getSuperscriptPosition()-> Float {
        return self.superscript_position
    }


    /**
     *  Sets the subscript position for this composite text line.
     *
     *  @param subscript_position the subscript position.
     */
    @discardableResult
    public func setSubscriptPosition(_ subscript_position: Float) -> CompositeTextLine {
        self.subscript_position = subscript_position
        return self
    }


    /**
     *  Gets the subscript position for this text line.
     *
     *  @return subscript_position the subscript position.
     */
    public func getSubscriptPosition()-> Float {
        return self.subscript_position
    }


    /**
     *  Add a new text line.
     *
     *  Find the current font, current size and effects (normal, super or subscript)
     *  Set the position of the component to the starting stored as current position
     *  Set the size and offset based on effects
     *  Set the new current position
     *
     *  @param component the component.
     */
    public func addComponent(_ component: TextLine) {
        if component.getTextEffect() == Effect.SUPERSCRIPT {
            if fontSize > 0 {
                component.getFont().setSize(fontSize * superscript_size_factor)
            }
            component.setLocation(
                    current[X],
                    current[Y] - fontSize * superscript_position)
        }
        else if component.getTextEffect() == Effect.SUBSCRIPT {
            if fontSize > 0 {
                component.getFont().setSize(fontSize * subscript_size_factor)
            }
            component.setLocation(
                    current[X],
                    current[Y] + fontSize * subscript_position)
        }
        else {
            if fontSize > 0 {
                component.getFont().setSize(fontSize)
            }
            component.setLocation(current[X], current[Y])
        }
        current[X] += component.getWidth()
        textLines.append(component)
    }


    /**
     *  Loop through all the text lines and reset their location based on
     *  the new location set here.
     *
     *  @param x the x coordinate.
     *  @param y the y coordinate.
     */
    @discardableResult
    public func setLocation(_ x: Float, _ y: Float) -> CompositeTextLine {
        self.position[X] = x
        self.position[Y] = y
        self.current[X]  = x
        self.current[Y]  = y

        if textLines.count == 0 {
            return self
        }

        for component in textLines {
            if component.getTextEffect() == Effect.SUPERSCRIPT {
                component.setLocation(
                        current[X],
                        current[Y] - fontSize * superscript_position)
            }
            else if component.getTextEffect() == Effect.SUBSCRIPT {
                component.setLocation(
                        current[X],
                        current[Y] + fontSize * subscript_position)
            }
            else {
                component.setLocation(current[X], current[Y])
            }
            current[X] += component.getWidth()
        }
        return self
    }


    /**
     *  Return the location of this composite text line.
     *
     *  @return the location of this composite text line.
     */
    public func getLocation()-> [Float] {
        return self.position
    }


    /**
     *  Return the nth entry in the TextLine array.
     *
     *  @param index the index of the nth element.
     *  @return the text line at the specified index.
     */
    public func getTextLine(_ index: Int)-> TextLine? {
        let count = self.textLines.count
        if count == 0 {
            return nil
        }
        if index < 0 || index > count - 1 {
            return nil
        }
        return textLines[index]
    }


    /**
     *  Returns the number of text lines.
     *
     *  @return the number of text lines.
     */
    public func getNumberOfTextLines()-> Int {
       return textLines.count
    }


    /**
     *  Returns the vertical coordinates of the top left and bottom right corners
     *  of the bounding box of this composite text line.
     *
     *  @return the an array containing the vertical coordinates.
     */
    public func getMinMax()-> [Float] {
        var min: Float = position[Y]
        var max: Float = position[Y]
        var cur: Float

        for component in textLines {
            if component.getTextEffect() == Effect.SUPERSCRIPT {
                cur = (position[Y] - component.getFont().ascent) - fontSize * superscript_position
                if cur < min {
                    min = cur
                }
            }
            else if component.getTextEffect() == Effect.SUBSCRIPT {
                cur = (position[Y] - component.getFont().descent) + fontSize * subscript_position
                if cur > max {
                    max = cur
                }
            }
            else {
                cur = position[Y] - component.getFont().ascent
                if cur < min {
                    min = cur
                }
                cur = position[Y] - component.getFont().descent
                if cur > max {
                    max = cur
                }
            }
        }

        return [min, max]
    }


    /**
     *  Returns the height of this CompositeTextLine.
     *
     *  @return the height.
     */
    public func getHeight()-> Float {
        var yy = getMinMax()
        return yy[1] - yy[0]
    }


    /**
     *  Returns the width of this CompositeTextLine.
     *
     *  @return the width.
     */
    public func getWidth()-> Float {
        return (current[X] - position[X])
    }


    /**
     *  Draws this line on the specified page.
     *
     *  @param page the page to draw this line on.
     *  @return x and y coordinates of the bottom right corner of this component.
     *  @throws Exception
     */
    @discardableResult
    public func drawOn(_ page: Page)-> [Float] {
        var x_max: Float = 0.0
        var y_max: Float = 0.0
        // Loop through all the text lines and draw them on the page
        for textLine in textLines {
            var xy: [Float] = textLine.drawOn(page)
            x_max = max(x_max, xy[0])
            y_max = max(y_max, xy[1])
        }
        return [x_max, y_max]
    }

}
