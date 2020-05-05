/**
 *  PNGImage.swift
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

enum PNGImageError: Error {
    case incorrectSignature
    case unsupportedBitDepth(bitDepth: Int)
    case incorrectPaletteLength(paletteLength: Int)
    case interlacedImagesNotSupported
    case chunkHasBadCRC
}

/**
 * Used to embed PNG images in the PDF document.
 * <p>
 * <strong>Please note:</strong>
 * <p>
 *     Interlaced images are not supported.
 * <p>
 *     To convert interlaced image to non-interlaced image use OptiPNG:
 * <p>
 *     optipng -i0 -o7 myimage.png
 */
public class PNGImage {

    var w: Int?                     // Image width in pixels
    var h: Int?                     // Image height in pixels

    var data = [UInt8]()            // The compressed data in the IDAT chunks
    var inflated = [UInt8]()        // The decompressed image data
    var deflated = [UInt8]()        // The deflated reconstructed image data
    var palette: [UInt8]?           // The palette data
    var iCCP: [UInt8]?              // Embedded ICC profile
    var tRNS: [UInt8]?              // The palette transparency data
    var deflatedAlpha = [UInt8]()   // The deflated alpha channel data

    private var bitDepth = 8
    private var colorType = 0


    /**
     * Used to embed PNG images in the PDF document.
     *
     */
    public init(_ stream: InputStream) throws {
        var buffer = readPNG(stream)
        let chunks = try processPNG(&buffer)
        for chunk in chunks {
            let chunkType = String(bytes: chunk.type!, encoding: .utf8)!
/*
            print(chunkType)
*/
            if chunkType == "IHDR" {
                self.w = Int(getUInt32(chunk.getData()!, 0))    // Width
                self.h = Int(getUInt32(chunk.getData()!, 4))    // Height
                self.bitDepth = Int(chunk.getData()![8])        // Bit Depth
                self.colorType = Int(chunk.getData()![9])       // Color Type
/*
                print("bitDepth == " + String(describing: self.bitDepth))
                print("colorType == " + String(describing: self.colorType))
                print("Compression: " + String(describing: chunk.getData()![10]))
                print("Filter: " + String(describing: chunk.getData()![11]))
                print("Interlace: " + String(describing: chunk.getData()![12]))
*/
                if chunk.getData()![12] == 1 {
                    print("Interlaced PNG images are not supported.")
                    // print("Convert the image using OptiPNG:\noptipng -i0 -o7 myimage.png\n")
                }
            }
            else if chunkType == "IDAT" {
                data.append(contentsOf: chunk.getData()!)
            }
            else if chunkType == "PLTE" {
                palette = chunk.getData()!
                if palette!.count % 3 != 0 {
                    // TODO:
                    // print("Incorrect palette length: " + String(describing: palette!.count))
                }
            }
            else if chunkType == "iCCP" {
                iCCP = chunk.getData()!
            }
            else if chunkType == "gAMA" {
                // TODO:
            }
            else if chunkType == "tRNS" {
                if colorType == 3 {
                    tRNS = chunk.getData()
                }
            }
            else if chunkType == "cHRM" {
                // TODO:
            }
            else if chunkType == "sBIT" {
                // TODO:
            }
            else if chunkType == "bKGD" {
                // TODO:
            }
        }

        _ = try Puff(output: &inflated, input: &data, inflate: false)
        _ = try Puff(output: &inflated, input: &data, inflate: true)

        var image: [UInt8]?             // The reconstructed image data
        if colorType == 0 {
            // Grayscale Image
            if bitDepth == 16 {
                image = getImageColorType0BitDepth16()
            }
            else if bitDepth == 8 {
                image = getImageColorType0BitDepth8()
            }
            else if bitDepth == 4 {
                image = getImageColorType0BitDepth4()
            }
            else if bitDepth == 2 {
                image = getImageColorType0BitDepth2()
            }
            else if bitDepth == 1 {
                image = getImageColorType0BitDepth1()
            }
            else {
                // TODO:
                // print("Image with unsupported bit depth == " + String(describing: bitDepth))
            }
        }
        else if colorType == 6 {
            if bitDepth == 8 {
                image = getImageColorType6BitDepth8()
            }
            else {
                // TODO:
                // print("Image with unsupported bit depth == " + bitDepth)
            }
        }
        else {
            // Color Image
            if palette == nil {
                // Trucolor Image
                if bitDepth == 16 {
                    image = getImageColorType2BitDepth16()
                }
                else {
                    image = getImageColorType2BitDepth8()
                }
            }
            else {
                // Indexed Image
                if bitDepth == 8 {
                    image = try getImageColorType3BitDepth8()
                }
                else if bitDepth == 4 {
                    image = getImageColorType3BitDepth4()
                }
                else if bitDepth == 2 {
                    image = getImageColorType3BitDepth2()
                }
                else if bitDepth == 1 {
                    image = getImageColorType3BitDepth1()
                }
                else {
                    // TODO:
                    // print("Image with unsupported bit depth == " + String(describing: bitDepth))
                }
            }
        }

        _ = LZWEncode(&deflated, &image!)
/*
print("image.count -> " + String(describing: image!.count))
let time0 = Int64(Date().timeIntervalSince1970 * 1000)
        _ = LZWEncode(&deflated, &image!)
        // _ = FlateEncode(&deflated, &image!, RLE: true)
let time1 = Int64(Date().timeIntervalSince1970 * 1000)
print(time1 - time0)
print("deflated.count -> " + String(describing: deflated.count))
*/
    }


    public func getWidth() -> Int? {
        return self.w
    }


    public func getHeight() -> Int? {
        return self.h
    }


    public func getColorType() -> Int {
        return self.colorType
    }


    public func getBitDepth() -> Int {
        return self.bitDepth
    }


    public func getData() -> [UInt8] {
        return self.deflated
    }


    public func getAlpha() -> [UInt8] {
        return self.deflatedAlpha
    }


    private func readPNG(_ stream: InputStream) -> [UInt8] {
        var contents = [UInt8]()
        stream.open()
        var buffer = [UInt8](repeating: 0, count: 4096)
        while stream.hasBytesAvailable {
            let count = stream.read(&buffer, maxLength: buffer.count)
            if count > 0 {
                contents.append(contentsOf: buffer[0..<count])
            }
        }
        stream.close()
        if contents[0] == 0x89 &&
                contents[1] == 0x50 &&
                contents[2] == 0x4E &&
                contents[3] == 0x47 &&
                contents[4] == 0x0D &&
                contents[5] == 0x0A &&
                contents[6] == 0x1A &&
                contents[7] == 0x0A {
            // The PNG signature is correct.
        }
        else {
            print("Wrong PNG signature.")
        }
        return contents
    }


    private func processPNG(
            _ buffer: inout [UInt8]) throws -> [Chunk] {
        var chunks = [Chunk]()
        var offset = 8      // Skip the header!
        while true {
            let chunk = getChunk(&buffer, &offset)
            chunks.append(chunk)
            let chunkType = String(bytes: chunk.type!, encoding: .utf8)!
            if chunkType == "IEND" {
                break
            }
        }
        return chunks
    }


    private func getChunk(
            _ buffer: inout [UInt8],
            _ offset: inout Int) -> Chunk {
        let chunk = Chunk()

        // The length of the data chunk.
        chunk.setLength(getUInt32(getBytes(&buffer, &offset, 4), 0))

        // The chunk type.
        chunk.setType(getBytes(&buffer, &offset, 4))

        // The chunk data.
        chunk.setData(getBytes(&buffer, &offset, Int(chunk.getLength()!)))

        // CRC of the type and data chunks.
        chunk.setCrc(getUInt32(getBytes(&buffer, &offset, 4), 0))

        if !chunk.hasGoodCRC() {
            print("Chunk has bad CRC.")
        }
        return chunk
    }


    private func getBytes(
            _ buffer: inout [UInt8],
            _ offset: inout Int,
            _ length: Int) -> [UInt8] {
        var bytes = [UInt8]()
        var i = 0
        while i < length {
            bytes.append(buffer[offset + i])
            i += 1
        }
        offset += length
        return bytes
    }


    private func getUInt32(
            _ buf: [UInt8],
            _ off: Int) -> UInt32 {
        var value = UInt32(buf[off]) << 24
        value |= UInt32(buf[off + 1]) << 16
        value |= UInt32(buf[off + 2]) << 8
        value |= UInt32(buf[off + 3])
        return value
    }


    // Truecolor Image with Bit Depth == 16
    private func getImageColorType2BitDepth16() -> [UInt8] {
        var filters = [UInt8]()
        var image = [UInt8](repeating: 0, count: (inflated.count - self.h!))
        let scanLineLength = 6 * self.w! + 1
        var j = 0
        for i in 0..<inflated.count {
            if i % scanLineLength == 0 {
                filters.append(inflated[i])
            }
            else {
                image[j] = inflated[i]
                j += 1
            }
        }
        applyFilters(&filters, &image, self.w!, self.h!, 6)
        return image
    }


    // Truecolor Image with Bit Depth == 8
    private func getImageColorType2BitDepth8() -> [UInt8] {
        var filters = [UInt8]()
        var image = [UInt8](repeating: 0, count: (inflated.count - self.h!))
        let bytesPerLine = 3 * self.w! + 1
        var j = 0
        for i in 0..<inflated.count {
            if i % bytesPerLine == 0 {
                filters.append(inflated[i])
            }
            else {
                image[j] = inflated[i]
                j += 1
            }
        }
        applyFilters(&filters, &image, self.w!, self.h!, 3)
        return image
    }


    // Truecolor Image with Alpha Transparency
    private func getImageColorType6BitDepth8() -> [UInt8] {
        var filters = [UInt8]()
        var image = [UInt8](repeating: 0, count: 4 * self.w! * self.h!)
        let bytesPerLine = 4 * self.w! + 1
        var j = 0
        for i in 0..<inflated.count {
            if i % bytesPerLine == 0 {
                filters.append(inflated[i])
            }
            else {
                image[j] = inflated[i]
                j += 1
            }
        }
        applyFilters(&filters, &image, self.w!, self.h!, 4)

        var idata = [UInt8](repeating: 0, count: (3 * self.w! * self.h!))   // Image data
        var alpha = [UInt8](repeating: 0, count: (self.w! * self.h!))       // Alpha values

        var k = 0
        var n = 0
        var i = 0
        while i < image.count {
            idata[k]     = image[i]
            idata[k + 1] = image[i + 1]
            idata[k + 2] = image[i + 2]
            alpha[n]     = image[i + 3]

            k += 3
            n += 1
            i += 4
        }
        _ = LZWEncode(&deflatedAlpha, &alpha)
        // _ = FlateEncode(&deflatedAlpha, &alpha, RLE: true)

        return idata
    }


    // Indexed-color Image with Bit Depth == 8
    // Each value is a palette index; a PLTE chunk shall appear.
    private func getImageColorType3BitDepth8() throws -> [UInt8] {
/*
TODO:
Dealing with ICC profiles is a whole new project.

        var profile: [UInt8]?
        if iCCP != nil {
            var name = [UInt8]()
            var i = 0
            while iCCP![i] != 0 {
                name.append(iCCP![i])
                i += 1
            }
            print(String(bytes: name, encoding: .utf8)!)
            i += 1
            i += 1
            var deflated = [UInt8]()
            while i < iCCP!.count - 4 {
                deflated.append(iCCP![i])
                i += 1
            }
            profile = [UInt8]()
            _ = try Puff(output: &profile!, input: &deflated, inflate: false)
            _ = try Puff(output: &profile!, input: &deflated, inflate: true)
        }
*/

        var alpha: [UInt8]?
        if tRNS != nil {
            alpha = [UInt8](repeating: 0xFF, count: self.w!*self.h!)
        }
        var filters = [UInt8]()
        var image = [UInt8](repeating: 0x00, count: 3*self.w!*self.h!)
        var n = 0
        var i = 0
        for j in 0..<inflated.count {
            if j % (self.w! + 1) == 0 {
                filters.append(inflated[j])
            }
            else {
                let k = Int(inflated[j])
                if tRNS != nil && k < tRNS!.count {
                    alpha![n] = tRNS![k]
                }
                n += 1
                image[i] = palette![3*k]
                i += 1
                image[i] = palette![3*k + 1]
                i += 1
                image[i] = palette![3*k + 2]
                i += 1
            }
        }
        applyFilters(&filters, &image, self.w!, self.h!, 3)
        if tRNS != nil {
            _ = LZWEncode(&deflatedAlpha, &alpha!)
            // _ = FlateEncode(&deflatedAlpha, &alpha!, RLE: true)
        }
        return image
    }


    // Indexed Image with Bit Depth == 4
    private func getImageColorType3BitDepth4() -> [UInt8] {

        var image = [UInt8](repeating: 0, count: 6*(inflated.count - self.h!))
        var scanLineLength = self.w! / 2 + 1
        if self.w! % 2 > 0 {
            scanLineLength += 1
        }

        var j = 0
        for i in 0..<inflated.count {
            if i % scanLineLength == 0 {
                // Skip the filter byte.
                continue
            }

            let l = inflated[i]

            var k = Int(3 * ((l >> 4) & 0x0000000f))
            image[j] = palette![k]
            j += 1
            image[j] = palette![k + 1]
            j += 1
            image[j] = palette![k + 2]
            j += 1

            if j % (3 * self.w!) == 0 {
                continue
            }

            k = Int(3 * (l & 0x0000000f))
            image[j] = palette![k]
            j += 1
            image[j] = palette![k + 1]
            j += 1
            image[j] = palette![k + 2]
            j += 1
        }
        return image
    }


    // Indexed Image with Bit Depth == 2
    private func getImageColorType3BitDepth2() -> [UInt8] {

        var image = [UInt8](repeating: 0, count: (12 * (inflated.count - self.h!)))
        var scanLineLength = self.w! / 4 + 1
        if self.w! % 4 > 0 {
            scanLineLength += 1
        }

        var j = 0
        for i in 0..<inflated.count {

            if i % scanLineLength == 0 {
                // Skip the filter byte.
                continue
            }

            let l = Int(inflated[i])

            var k = 3 * ((l >> 6) & 0x00000003)
            image[j] = palette![k]
            j += 1
            image[j] = palette![k + 1]
            j += 1
            image[j] = palette![k + 2]
            j += 1

            if j % (3 * self.w!) == 0 {
                continue
            }

            k = 3 * ((l >> 4) & 0x00000003)
            image[j] = palette![k]
            j += 1
            image[j] = palette![k + 1]
            j += 1
            image[j] = palette![k + 2]
            j += 1

            if j % (3 * self.w!) == 0 {
                continue
            }

            k = 3 * ((l >> 2) & 0x00000003)
            image[j] = palette![k]
            j += 1
            image[j] = palette![k + 1]
            j += 1
            image[j] = palette![k + 2]
            j += 1

            if j % (3 * self.w!) == 0 {
                continue
            }

            k = 3 * (l & 0x00000003)
            image[j] = palette![k]
            j += 1
            image[j] = palette![k + 1]
            j += 1
            image[j] = palette![k + 2]
            j += 1
        }

        return image
    }


    // Indexed Image with Bit Depth == 1
    private func getImageColorType3BitDepth1() -> [UInt8] {

        var image = [UInt8](repeating: 0, count: (24 * (inflated.count - self.h!)))
        var scanLineLength = self.w! / 8 + 1
        if self.w! % 8 > 0 {
            scanLineLength += 1
        }

        var j = 0
        for i in 0..<inflated.count {

            if i % scanLineLength == 0 {
                // Skip the filter byte.
                continue
            }

            let l = Int(inflated[i])

            var k = 3 * ((l >> 7) & 0x00000001)
            image[j] = palette![k]
            j += 1
            image[j] = palette![k + 1]
            j += 1
            image[j] = palette![k + 2]
            j += 1

            if j % (3 * self.w!) == 0 {
                continue
            }

            k = 3 * ((l >> 6) & 0x00000001)
            image[j] = palette![k]
            j += 1
            image[j] = palette![k + 1]
            j += 1
            image[j] = palette![k + 2]
            j += 1

            if j % (3 * self.w!) == 0 {
                continue
            }

            k = 3 * ((l >> 5) & 0x00000001)
            image[j] = palette![k]
            j += 1
            image[j] = palette![k + 1]
            j += 1
            image[j] = palette![k + 2]
            j += 1

            if j % (3 * self.w!) == 0 {
                continue
            }

            k = 3 * ((l >> 4) & 0x00000001)
            image[j] = palette![k]
            j += 1
            image[j] = palette![k + 1]
            j += 1
            image[j] = palette![k + 2]
            j += 1

            if j % (3 * self.w!) == 0 {
                continue
            }

            k = 3 * ((l >> 3) & 0x00000001)
            image[j] = palette![k]
            j += 1
            image[j] = palette![k + 1]
            j += 1
            image[j] = palette![k + 2]
            j += 1

            if j % (3 * self.w!) == 0 {
                continue
            }

            k = 3 * ((l >> 2) & 0x00000001)
            image[j] = palette![k]
            j += 1
            image[j] = palette![k + 1]
            j += 1
            image[j] = palette![k + 2]
            j += 1

            if j % (3 * self.w!) == 0 {
                continue
            }

            k = 3 * ((l >> 1) & 0x00000001)
            image[j] = palette![k]
            j += 1
            image[j] = palette![k + 1]
            j += 1
            image[j] = palette![k + 2]
            j += 1

            if j % (3 * self.w!) == 0 {
                continue
            }

            k = 3 * (l & 0x00000001)
            image[j] = palette![k]
            j += 1
            image[j] = palette![k + 1]
            j += 1
            image[j] = palette![k + 2]
            j += 1

        }

        return image
    }


    // Grayscale Image with Bit Depth == 16
    private func getImageColorType0BitDepth16() -> [UInt8] {
        var filters = [UInt8]()
        var image = [UInt8](repeating: 0, count: (inflated.count - self.h!))
        let scanLineLength = 2 * self.w!
        var j = 0
        for i in 0..<inflated.count {
            if i % (scanLineLength + 1) == 0 {
                filters.append(inflated[i])
            }
            else {
                image[j] = inflated[i]
                j += 1
            }
        }
        applyFilters(&filters, &image, self.w!, self.h!, 2)
        return image
    }


    // Grayscale Image with Bit Depth == 8
    private func getImageColorType0BitDepth8() -> [UInt8] {
        var filters = [UInt8]()
        var image = [UInt8](repeating: 0, count: (inflated.count - self.h!))
        let scanLineLength = self.w! + 1
        var j = 0
        for i in 0..<inflated.count {
            if i % scanLineLength == 0 {
                filters.append(inflated[i])
            }
            else {
                image[j] = inflated[i]
                j += 1
            }
        }
        applyFilters(&filters, &image, self.w!, self.h!, 1)
        return image
    }


    // Grayscale Image with Bit Depth == 4
    private func getImageColorType0BitDepth4() -> [UInt8] {
        var j = 0
        var image = [UInt8](repeating: 0, count: (inflated.count - self.h!))
        var scanLineLength = self.w! / 2 + 1
        if self.w! % 2 > 0 {
            scanLineLength += 1
        }
        for i in 0..<inflated.count {
            if i % scanLineLength != 0 {
                image[j] = inflated[i]
                j += 1
            }
        }
        return image
    }


    // Grayscale Image with Bit Depth == 2
    private func getImageColorType0BitDepth2() -> [UInt8] {
        var j = 0
        var image = [UInt8](repeating: 0, count: (inflated.count - self.h!))
        var scanLineLength = self.w! / 4 + 1
        if self.w! % 4 > 0 {
            scanLineLength += 1
        }
        for i in 0..<inflated.count {
            if i % scanLineLength != 0 {
                image[j] = inflated[i]
                j += 1
            }
        }
        return image
    }


    // Grayscale Image with Bit Depth == 1
    private func getImageColorType0BitDepth1() -> [UInt8] {
        var j = 0
        var image = [UInt8](repeating: 0, count: (inflated.count - self.h!))
        var scanLineLength: Int = self.w! / 8 + 1
        if self.w! % 8 > 0 {
            scanLineLength += 1
        }
        for i in 0..<inflated.count {
            if i % scanLineLength != 0 {
                image[j] = inflated[i]
                j += 1
            }
        }
        return image
    }


    private func applyFilters(
            _ filters: inout [UInt8],
            _ image: inout [UInt8],
            _ width: Int,
            _ height: Int,
            _ bytesPerPixel: Int) {

        let bytesPerLine = width * bytesPerPixel
        var filter: UInt8 = 0x00
        for row in 0..<height {
            for col in 0..<bytesPerLine {
                if col == 0 {
                    filter = filters[row]
                }
                if filter == 0x00 {             // None
                    continue
                }

                var a = 0                       // The pixel on the left
                if col >= bytesPerPixel {
                    a = Int(image[(bytesPerLine * row + col) - bytesPerPixel] & 0xff)
                }
                var b = 0                       // The pixel above
                if row > 0 {
                    b = Int(image[bytesPerLine * (row - 1) + col] & 0xff)
                }
                var c = 0                       // The pixel diagonally left above
                if col >= bytesPerPixel && row > 0 {
                    c = Int(image[(bytesPerLine * (row - 1) + col) - bytesPerPixel] & 0xff)
                }

                let index = bytesPerLine * row + col
                if filter == 0x01 {             // Sub
                    image[index] = image[index] &+ UInt8(a)
                }
                else if filter == 0x02 {        // Up
                    image[index] = image[index] &+ UInt8(b)
                }
                else if filter == 0x03 {        // Average
                    image[index] = image[index] &+ UInt8(floor(Double(a + b) / 2))
                }
                else if filter == 0x04 {        // Paeth
                    let p = a + b - c
                    let pa = abs(p - a)
                    let pb = abs(p - b)
                    let pc = abs(p - c)
                    if pa <= pb && pa <= pc {
                        image[index] = image[index] &+ UInt8(a)
                    }
                    else if pb <= pc {
                        image[index] = image[index] &+ UInt8(b)
                    }
                    else {
                        image[index] = image[index] &+ UInt8(c)
                    }
                }
            }
        }
    }


/*
    public static func main(String[] args) throws Exception {
        var fis = FileInputStream(args[0])
        var png = PNGImage(fis)
        var image = png.getData()
        var alpha = png.getAlpha()
        var w = png.getWidth()
        var h = png.getHeight()
        var c = png.getColorType()
        fis.close()

        var fileName = args[0].substring(0, args[0].lastIndexOf("."))
        var fos = FileOutputStream(fileName + ".jet")
        var bos = BufferedOutputStream(fos)
        writeInt(w, bos)    // Width
        writeInt(h, bos)    // Height
        bos.write(c)        // Color Space
        if alpha != nil {
            bos.write(1)
            writeInt(alpha.length, bos)
            bos.write(alpha)
        }
        else {
            bos.write(0)
        }
        writeInt(image.length, bos)
        bos.write(image)
        bos.flush()
        bos.close()
    }


    private static func writeInt(int i, OutputStream os) throws IOException {
        os.write((i >> 24) & 0xff)
        os.write((i >> 16) & 0xff)
        os.write((i >>  8) & 0xff)
        os.write((i >>  0) & 0xff)
    }
*/

}   // End of PNGImage.swift
