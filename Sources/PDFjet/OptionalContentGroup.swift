/**
 *  OptionalContentGroup.swift
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
/// Container for drawable objects that can be drawn on a page as part of Optional Content Group.
/// Please see the PDF specification and Example_30 for more details.
///
///  @author Mark Paxton
///
public class OptionalContentGroup {

    var name: String?
    var ocgNumber = 0
    var objNumber = 0
    var visible: Bool?
    var printable: Bool?
    var exportable: Bool?

    private var components = [Drawable]()


    public init(_ name: String) {
        self.name = name
    }

    public func add(_ d: Drawable) {
        components.append(d)
    }

    public func setVisible(_ visible: Bool) {
        self.visible = visible
    }

    public func setPrintable(_ printable: Bool) {
        self.printable = printable
    }

    public func setExportable(_ exportable: Bool) {
        self.exportable = exportable
    }

    public func drawOn(_ p: Page) {
        if !components.isEmpty {
            p.pdf!.groups.append(self)
            ocgNumber = p.pdf!.groups.count

            p.pdf!.newobj()
            p.pdf!.append("<<\n")
            p.pdf!.append("/Type /OCG\n")
            p.pdf!.append("/Name (" + name! + ")\n")
            p.pdf!.append("/Usage <<\n")
            if visible != nil {
                p.pdf!.append("/View << /ViewState /ON >>\n")
            }
            else {
                p.pdf!.append("/View << /ViewState /OFF >>\n")
            }
            if printable != nil {
                p.pdf!.append("/Print << /PrintState /ON >>\n")
            }
            else {
                p.pdf!.append("/Print << /PrintState /OFF >>\n")
            }
            if exportable != nil {
                p.pdf!.append("/Export << /ExportState /ON >>\n")
            }
            else {
                p.pdf!.append("/Export << /ExportState /OFF >>\n")
            }
            p.pdf!.append(">>\n")
            p.pdf!.append(">>\n")
            p.pdf!.endobj()

            objNumber = p.pdf!.objNumber

            p.append("/OC /OC")
            p.append(ocgNumber)
            p.append(" BDC\n")
            for component in components {
                component.drawOn(p)
            }
            p.append("\nEMC\n")
        }
    }

}   // End of OptionalContentGroup.swift
