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
    scanRunning = false;

    // init connections
    connect(camera, SIGNAL(lockStatusChanged(QCamera::LockStatus, QCamera::LockChangeReason)),
            this, SLOT(slotLockStatusChanged(QCamera::LockStatus)));

    connect(imageCapture, SIGNAL(imageSaved(int, QString)), this, SLOT(slotImageSaved()));

    connect(camera, SIGNAL(lockFailed()), this, SLOT(slotLockFailed()));
    connect(imageCapture, SIGNAL(error(int, QCameraImageCapture::Error, const QString&)), this, SLOT(slotCaptureFailed()));

    qDebug() << "end init BarcodeScanner";
}

BarcodeScanner::~BarcodeScanner() {
    qDebug() << "BarcodeScanner::~BarcodeScanner";
    camera->unload();
}

void BarcodeScanner::classBegin() {
    qDebug() << "BarcodeScanner::classBegin";
}

void BarcodeScanner::componentComplete() {
    qDebug() << "BarcodeScanner::componentComplete";

    flagComponentComplete = true;
    camera->start();
}

void BarcodeScanner::startScanning() {
    if (scanRunning) {
        qDebug() << "abort: scan is running";
        return;
    }

    if (camera->availability() != QMultimedia::Available) {
        qDebug() << "camera is not available";
        emit error(BarcodeScanner::CameraUnavailable);
        return;
    }

    scanRunning = true;

    // 1. lock camera settings
    QtConcurrent::run(this, &BarcodeScanner::processCameraLock);
}

void BarcodeScanner::processCameraLock() {
    qDebug() << "processCameraLock() is called from " << QThread::currentThread();

    camera->searchAndLock();
}

void BarcodeScanner::slotLockStatusChanged(QCamera::LockStatus status) {
    qDebug() << "slotLockStatusChanged() is called from " << QThread::currentThread() << " status: " << status;

    if (status == QCamera::Locked) {
        emit captureFinished(decoder->getCaptureLocation());

        // 2. capture image
        QtConcurrent::run(this, &BarcodeScanner::processCapturing);
    }
}

void BarcodeScanner::processCapturing() {
    qDebug() << "processCapturing() is called from " << QThread::currentThread();

    imageCapture->capture(decoder->getCaptureLocation());
}

void BarcodeScanner::slotImageSaved() {
    qDebug() << "slotImageSaved() is called from " << QThread::currentThread();

    // unlock camera after caturing
    camera->unlock();

    // 3. decode barcode
    QtConcurrent::run(this, &BarcodeScanner::processDecode);
}

void BarcodeScanner::processDecode() {
    qDebug() << "processDecode() is called from " << QThread::currentThread();

    QString code = decoder->decodeBarcodeFromCache();

    qDebug() << "decoding has been finished, " << QThread::currentThread();

    scanRunning = false;
    emit decodingFinished(code);
}

// ------------------------------------------------------------
// Error handling
// ------------------------------------------------------------

void BarcodeScanner::slotLockFailed() {
    qDebug() << "lock failed, " << QThread::currentThread();
    scanRunning = false;
    emit error(BarcodeScanner::LockFailed);
}

void BarcodeScanner::slotCaptureFailed() {
    qDebug() << "capture failed, " << QThread::currentThread();
    scanRunning = false;
    emit error(BarcodeScanner::CaptureFailed);
}

