#ifndef SCANWORKER_H
#define SCANWORKER_H

#include "BarcodeScanner.h"

class ScanWorker : public QObject
{
    Q_OBJECT

public:
    explicit ScanWorker(BarcodeScanner &pScanner, QObject *parent = 0);

//signals:
//    void resultReady(const QString &s);

public slots:
    void processScanning();

private:
    BarcodeScanner &scanner;
};

#endif // SCANWORKER_H
