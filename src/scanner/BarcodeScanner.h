#ifndef BARCODESCANNER_H
#define BARCODESCANNER_H

#include <QCamera>

class BarcodeScanner : public QCamera
{
    Q_OBJECT

public:
    BarcodeScanner(QObject * parent = 0);
    void startScanning();

signals:
    void workerStart();

public slots:

};

#endif // BARCODESCANNER_H
