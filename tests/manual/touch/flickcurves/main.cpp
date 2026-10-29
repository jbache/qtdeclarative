#include <QGuiApplication>
#include <QQuickView>
#include <QUrl>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName(QStringLiteral("Flick Curves"));
    QGuiApplication::setOrganizationName(QStringLiteral("QtProject"));

    QQuickView view;
    view.setTitle(QGuiApplication::applicationName());
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.setSource(QUrl(QStringLiteral("qrc:/flickcurves.qml")));
    if (view.status() == QQuickView::Error)
        return 1;

    view.show();
    return app.exec();
}
