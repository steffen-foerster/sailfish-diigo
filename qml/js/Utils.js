/*
The MIT License (MIT)

Copyright (c) 2014 Steffen Förster

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

.pragma library

function crop(value, maxLength) {
    if (value !== undefined && value !== null && value.length > maxLength) {
        return value.substr(0, maxLength);
    }
    else {
        return value;
    }
}

function formatTimestamp(timestamp) {
    return timestamp.substr(0, 10);
}

function getUrlFromClipboard(hasText, text) {
    console.log("hasText: ", hasText, ", text: ", text);
    var retval = null
    if (hasText) {
        var urls = text.match(/^http[s]*:\/\/.{3,242}$/);
        if (urls && urls.length > 0) {
            retval = urls[0];
        }
    }
    return retval;
}

function commaToSpaceSeparated(tags) {
    var retval = tags;
    if (tags) {
        retval = tags.replace(/,/g, " ");
    }
    return retval;
}

function spaceToCommaSeparated(tags) {
    var retval = tags;
    if (tags) {
        retval = tags.replace(/ /g, ",");
    }
    return retval;
}

function getBlankIfNull(strValue) {
    return (strValue === null || strValue === undefined) ? "" : strValue;
}

function getZeroIfNull(numValue) {
    return (numValue === null || numValue === undefined) ? 0 : numValue;
}
