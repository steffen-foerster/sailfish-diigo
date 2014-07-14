/*
The MIT License (MIT)

Copyright (c) 2014 Steffen Förster

Some ideas are borrowed from qdeclarativecamera.cpp and qdeclarativecamera.h
(https://git.gitorious.org/qt/qtmultimedia.git)

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

#ifndef BARCODESCANNER_H
#define BARCODESCANNER_H

#include <QCamera>
#include <QCameraImageCapture>
#include <QCameraExposure>
#include <QCameraFocus>
#include <QThread>
#include <QtConcurrent>
#include <QtQml/qqmlparserstatus.h>
#include "BarcodeDecoder.h"

class BarcodeScanner : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)

public:
    BarcodeScanner(QObject *parent = 0);
    virtual ~BarcodeScanner();

    // see qdeclarativecamera_p.h
    Q_PROPERTY(QObject *mediaObject READ mediaObject NOTIFY mediaObjectChanged SCRIPTABLE false DESIGNABLE false)

    Q_INVOKABLE void startScanning();

    Q_ENUMS(ErrorCode)

    void processCameraLock();
    void processCapturing();
    void processDecode();

    // see qdeclarativecamera_p.h
    QObject *mediaObject() { return camera; }

    enum ErrorCode {
        LockFailed,
        CameraUnavailable,
        CaptureFailed,
        ImageSaveFailed
    };

signals:
    void captureFinished(const QString &location);
    void decodingFinished(const QString &code);
    void error(ErrorCode errorCode);
    void mediaObjectChanged();

public slots:
    void slotLockStatusChanged(QCamera::LockStatus status);
    void slotImageSaved();
    void slotLockFailed();
    void slotCaptureFailed();

protected:
    // see qdeclarativecamera_p.h
    void classBegin();
    void componentComplete();

private:
    BarcodeDecoder* decoder;
    QCameraImageCapture* imageCapture;
    QCamera* camera;
    bool flagComponentComplete;
    bool scanRunning;
};

#endif // BARCODESCANNER_H