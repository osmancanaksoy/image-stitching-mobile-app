#ifndef PROCESS_H
#define PROCESS_H

#include <QObject>
#include <QUrl>
#include <QVector>

class Process : public QObject
{
    Q_OBJECT
public:
    explicit Process(QObject *parent = nullptr);
public slots:
    void get_image_path(const QString& image_path);
    void get_images(const QVector<QString>& images);
    void to_gray(const QString& image_path);
    void to_binary(const QString& image_path);
    void stitch();

signals:
    void sendProcessedImage(QUrl url);
private:
    QVector<QUrl> urls;
};

#endif // PROCESS_H
