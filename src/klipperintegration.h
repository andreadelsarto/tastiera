#ifndef KLIPPERINTEGRATION_H
#define KLIPPERINTEGRATION_H

#include <QObject>
#include <QStringList>
#include <QDBusInterface>

class KlipperIntegration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList history READ history NOTIFY historyChanged)

public:
    explicit KlipperIntegration(QObject *parent = nullptr);

    QStringList history() const { return m_history; }

    Q_INVOKABLE void refreshHistory();
    Q_INVOKABLE void setClipboardContents(const QString &text);

signals:
    void historyChanged();
    void itemSelected(const QString &text);

private:
    QDBusInterface *m_klipperInterface{nullptr};
    QStringList m_history;
};

#endif // KLIPPERINTEGRATION_H
