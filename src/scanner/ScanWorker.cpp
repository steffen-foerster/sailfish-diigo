#include "ScanWorker.h"

ScanWorker::ScanWorker(BarcodeScanner &pScanner, QObject *parent) :
    QObject(parent), scanner(pScanner)
{
}

void ScanWorker::processScanning() {
    scanner.searchAndLock();
}

//void resultReady(const QString &s);

