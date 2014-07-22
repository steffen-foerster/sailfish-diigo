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

#include <QDebug>
#include "BarcodeScanner.h"
#include <QProcess>

BarcodeScanner::BarcodeScanner(QObject * parent) : QObject(parent)
{
    qDebug() << "start init BarcodeScanner";

    camera = new QCamera(this);
    decoder = new BarcodeDecoder(this);
    imageCapture = new QCameraImageCapture(camera, this);

    camera->exposure()->setExposureCompensation(2.0);
    camera->exposure()->setExposureMode(QCameraExposure::ExposureAuto);
    camera->exposure()->setFlashMode(QCameraExposure::FlashOff);

    camera->focus()->zoomTo(1.0, 3.0);
    camera->focus()->setFocusMode(QCameraFocus::MacroFocus);
    camera->focus()->setFocusPointMode(QCameraFocus::FocusPointCenter);

    flagComponentComplete = false;
    flagScanRunning = false;

    createConnections();

    qDebug() << "end init BarcodeScanner";
}

BarcodeScanner::~BarcodeScanner() {
    qDebug() << "BarcodeScanner::~BarcodeScanner";

    if (camera->state() == QCamera::ActiveState) {
        qDebug() << "stopping camera ...";
        camera->stop();
    }
}

void BarcodeScanner::createConnections() {
    // init connections
    connect(camera, SIGNAL(lockStatusChanged(QCamera::LockStatus, QCamera::LockChangeReason)),
            this, SLOT(slotLockStatusChanged(QCamera::LockStatus)));
    connect(imageCapture, SIGNAL(imageSaved(int, QString)), this, SLOT(slotImageSaved()));

    // error handling
    connect(camera, SIGNAL(lockFailed()), this, SLOT(slotLockFailed()));
    connect(imageCapture, SIGNAL(error(int, QCameraImageCapture::Error, const QString&)), this, SLOT(slotCaptureFailed()));
    connect(camera, SIGNAL(error(QCamera::Error)), this, SLOT(slotCameraError(QCamera::Error)));

    // to stop camera after scan process if necessary
    connect(this, SIGNAL(decodingFinished(const QString)),
            this, SLOT(slotDecodingFinished()));

    // for debugging
    connect(camera, SIGNAL(statusChanged(QCamera::Status)),
            this, SLOT(slotStatusChanged(QCamera::Status)));
    connect(camera, SIGNAL(stateChanged(QCamera::State)),
            this, SLOT(slotStateChanged(QCamera::State)));
}

void BarcodeScanner::classBegin() {
    qDebug() << "BarcodeScanner::classBegin";
}

void BarcodeScanner::componentComplete() {
    qDebug() << "BarcodeScanner::componentComplete";

    flagComponentComplete = true;
}

void BarcodeScanner::setDecoderFormat(const int &format) {
    decoder->setDecoderFormat(format);
}

void BarcodeScanner::startCamera() {
    qDebug() << "camera has state: " << camera->state();

    if (isJollaCameraRunning()) {
        qDebug() << "jolla camera is running";
        emit error(BarcodeScanner::JollaCameraRunning);
        return;
    }

    if (camera->state() != QCamera::ActiveState) {
        if (camera->availability() != QMultimedia::Available) {
            qDebug() << "camera is not available";
            emit error(BarcodeScanner::CameraUnavailable);
            return;
        }

        qDebug() << "starting camera ...";
        camera->start();
    }
    else {
        qDebug() << "camera is already started";
    }
}

void BarcodeScanner::slotStateChanged(QCamera::State state) {
    qDebug() << "camera state changed: " << state;

    if (camera->state() == QCamera::ActiveState) {
        emit cameraStarted();
    }
}

void BarcodeScanner::startScanning() {
    if (flagScanRunning) {
        qDebug() << "abort: scan is running";
        return;
    }

    if (isJollaCameraRunning()) {
        qDebug() << "jolla camera is running";
        emit error(BarcodeScanner::JollaCameraRunning);
        return;
    }

    if (camera->availability() != QMultimedia::Available) {
        qDebug() << "camera is not available";
        emit error(BarcodeScanner::CameraUnavailable);
        return;
    }

    flagScanRunning = true;

    // 1. lock camera settings
    qDebug() << "searching and locking ...";
    camera->searchAndLock();
}

bool BarcodeScanner::isJollaCameraRunning() {
    QProcess *process = new QProcess();
    QString cmd = "/bin/sh";
    QStringList args;
    args << "-c" << "ps -A | grep jolla-camera";
    process->start(cmd, args);

    bool result = false;
    if (process->waitForFinished()) {
        QString output = "";
        output.append(process->readAllStandardOutput());
        qDebug() << "result of ps command: " << output;
        result = output.contains("jolla-camera", Qt::CaseInsensitive);
    }
    delete process;
    return result;
}

void BarcodeScanner::slotLockStatusChanged(QCamera::LockStatus status) {
    qDebug() << "slotLockStatusChanged() is called from " << QThread::currentThread() << " status: " << status;

    if (status == QCamera::Locked) {
        // 2. capture image
        qDebug() << "capturing image ...";
        imageCapture->capture(decoder->getCaptureLocation());
    }
}

void BarcodeScanner::slotImageSaved() {
    qDebug() << "slotImageSaved() is called from " << QThread::currentThread();

    camera->unlock();
    qDebug() << "camera unlocked";

    // 3. decode barcode
    QtConcurrent::run(this, &BarcodeScanner::processDecode);
}

/**
 * Runs in a pooled thread.
 */
void BarcodeScanner::processDecode() {
    qDebug() << "processDecode() is called from " << QThread::currentThread();

    QString code = decoder->decodeBarcodeFromCache();
    qDebug() << "decoding has been finished";

    emit decodingFinished(code);
}

void BarcodeScanner::slotDecodingFinished() {
    qDebug() << "slotDecodingFinished() is called from " << QThread::currentThread();
    flagScanRunning = false;
}

// ------------------------------------------------------------
// Error handling
// ------------------------------------------------------------

void BarcodeScanner::slotLockFailed() {
    qDebug() << "lock failed";
    flagScanRunning = false;

    emit error(BarcodeScanner::LockFailed);
}

void BarcodeScanner::slotCaptureFailed() {
    qDebug() << "capture failed";
    flagScanRunning = false;

    emit error(BarcodeScanner::CaptureFailed);
}

void BarcodeScanner::slotCameraError(QCamera::Error value) {
    qDebug() << "camera error occured: " + value;
    flagScanRunning = false;

    emit error(BarcodeScanner::CameraError);
}

// ------------------------------------------------------------
// debugging
// ------------------------------------------------------------

void BarcodeScanner::slotStatusChanged(QCamera::Status status) {
    qDebug() << "camera status changed: " << status;
}

