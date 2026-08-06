#include "klipperintegration.h"
#include <QDBusReply>
#include <QDBusMessage>
#include <QDBusConnection>
#include <QGuiApplication>
#include <QClipboard>
#include <QDebug>

KlipperIntegration::KlipperIntegration(QObject *parent)
    : QObject(parent)
{
    m_klipperInterface = new QDBusInterface(
        QStringLiteral("org.kde.klipper"),
        QStringLiteral("/klipper"),
        QStringLiteral("org.kde.klipper.klipper"),
        QDBusConnection::sessionBus(),
        this
    );

    refreshHistory();
}

void KlipperIntegration::refreshHistory()
{
    m_history.clear();

    if (m_klipperInterface && m_klipperInterface->isValid()) {
        QDBusReply<QStringList> reply = m_klipperInterface->call(QStringLiteral("getClipboardHistoryMenu"));
        if (reply.isValid()) {
            m_history = reply.value();
        } else {
            // Fallback to current clipboard text
            QClipboard *clipboard = QGuiApplication::clipboard();
            if (clipboard) {
                QString text = clipboard->text();
                if (!text.isEmpty()) {
                    m_history.append(text);
                }
            }
        }
    } else {
        // Fallback QClipboard
        QClipboard *clipboard = QGuiApplication::clipboard();
        if (clipboard) {
            QString text = clipboard->text();
            if (!text.isEmpty()) {
                m_history.append(text);
            }
        }
    }

    emit historyChanged();
}

void KlipperIntegration::setClipboardContents(const QString &text)
{
    if (m_klipperInterface && m_klipperInterface->isValid()) {
        m_klipperInterface->call(QStringLiteral("setClipboardContents"), text);
    } else {
        QClipboard *clipboard = QGuiApplication::clipboard();
        if (clipboard) {
            clipboard->setText(text);
        }
    }
    emit itemSelected(text);
}
