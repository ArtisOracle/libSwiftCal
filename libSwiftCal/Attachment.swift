//
//  Attachment.swift
//  libSwiftCal
//
//  Created by Stefan Arambasich on 10/14/14.
//  
//  Copyright (c) 2014 Stefan Arambasich. All rights reserved.
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

/**
    A representation of a document object to associate with a calendar
    component.

    An Attachment may contain either a URI pointing to the desired resource
    or an inline binary encoded representation of the file.

    :URL: https://tools.ietf.org/html/rfc5545#section-3.8.1.1
*/
public class Attachment: Property {
    /// A URI pointing to the desired resource
    public var URI: String? {
        get {
            return self.propertyValue as? String
        } set {
            self.propertyValue = newValue
        }
    }
    
    /// Binary representation of an inline encoded document
    public var binary: NSData? {
        get {
            return self.propertyValue as? NSData
        }
    }
}
