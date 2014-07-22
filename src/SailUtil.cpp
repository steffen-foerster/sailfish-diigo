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

#include "SailUtil.h"
#include "config.h"
#include <QFile>
#include <QDir>
#include <QTextStream>

SailUtil::SailUtil(QObject *parent) :
    QObject(parent)
{
}

QString SailUtil::getApiKey() const {
#ifndef CONFIG
#error "Please define API_KEY"
#else
    return API_KEY;
#endif
}

bool SailUtil::openBrowser(QString url) {
    return QDesktopServices::openUrl(QUrl(url));
}

QString SailUtil::getBrowserBookmarks() {
    QFile file(QDir::home().absolutePath() + "/.local/share/org.sailfishos/sailfish-browser/bookmarks.json");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return "[]";
    }

    QTextStream in(&file);
    return in.readAll();
}
