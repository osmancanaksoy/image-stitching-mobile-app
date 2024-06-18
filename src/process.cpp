#include "process.h"
#include <QDebug>
#include <QObject>
#include <QPixmap>
#include <QUrl>
#include <QString>
#include <opencv2/opencv.hpp>

Process::Process(QObject *parent)
    : QObject{parent}
{

}

void Process::get_image_path(const QString &image_path)
{
    QUrl url(image_path);
    qDebug() << "Image Path:" << url.toLocalFile();
}

void Process::get_images(const QVector<QString> &images)
{
    for(int i = 0; i < images.size() - 4;i++) {
        if(images[i] != "")
            urls.push_back(images[i]);
    }
    for(int i = 0; i < urls.size();i++) {
        qDebug() << urls[i];
    }
    stitch();
}

void Process::to_gray(const QString &image_path)
{
    QUrl url(image_path);
    qDebug() << url;
    cv::Mat mat = cv::imread(url.toLocalFile().toStdString());
    cv::cvtColor(mat, mat, cv::COLOR_BGR2GRAY);

    QUrl gray_url("file:///data/user/0/com.yourcompany.wizardEVAP.Stitcher/files/gray.png");

    cv::imwrite(gray_url.toLocalFile().toStdString(), mat);

    emit sendProcessedImage(gray_url);
}

void Process::to_binary(const QString &image_path)
{
    QUrl url(image_path);
    qDebug() << url;
    cv::Mat mat = cv::imread(url.toLocalFile().toStdString());
    cv::cvtColor(mat, mat, cv::COLOR_BGR2GRAY);

    cv::threshold(mat,mat, 128,255, cv::THRESH_BINARY);

    QUrl binary_url("file:///data/user/0/com.yourcompany.wizardEVAP.Stitcher/files/binary.png");

    cv::imwrite(binary_url.toLocalFile().toStdString(), mat);

    emit sendProcessedImage(binary_url);
}

void Process::stitch()
{
    std::vector<cv::Mat> images;
    for(int i = 0; i < urls.size(); i++) {
        cv::Mat temp = cv::imread(urls[i].toLocalFile().toStdString());
        images.push_back(temp);
    }

    cv::Mat pano;
    cv::Ptr<cv::Stitcher> stitcher = cv::Stitcher::create(cv::Stitcher::PANORAMA);
    //stitcher->setWaveCorrection(false);
    //stitcher->setPanoConfidenceThresh(0.8);
    cv::Stitcher::Status status = stitcher->stitch(images, pano);

    if (status == cv::Stitcher::OK) {
        qDebug() << "Panaroma OK";

        QUrl pano_url("file:///data/user/0/com.yourcompany.wizardEVAP.Stitcher/files/pano.png");
        cv::imwrite(pano_url.toLocalFile().toStdString(), pano);

        emit sendProcessedImage(pano_url);
    }
    else if (status == cv::Stitcher::ERR_NEED_MORE_IMGS) {
        qDebug() << "Need More Images...";
    }
    else if (status == cv::Stitcher::ERR_CAMERA_PARAMS_ADJUST_FAIL) {
        qDebug() << "Params Fail...";
    }
    else if (status == cv::Stitcher::ERR_HOMOGRAPHY_EST_FAIL) {
        qDebug() << "Homoghraphy Fail...";
    }
    else {
        qDebug() << "aaaaa";
    }
    urls.clear();

}
