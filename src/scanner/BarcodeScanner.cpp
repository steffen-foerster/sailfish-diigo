#include <QThread>
#include "BarcodeScanner.h"
#include "ScanWorker.h"

BarcodeScanner::BarcodeScanner(QObject * parent) : QCamera(parent)
{
}

void BarcodeScanner::startScanning() {
    QThread *thread = new QThread();
    ScanWorker *worker = new ScanWorker((*this), this);

    connect(this, SIGNAL(workerStart()), worker, SLOT(processScanning()));
    worker->moveToThread(thread);
    thread->start();
}
