#ifndef GESTUREENGINE_H
#define GESTUREENGINE_H

#include <QObject>
#include <QPointF>
#include <QVariantMap>
#include <QStringList>
#include <QList>
#include <memory>
#include <vector>
#include <string>

struct TrieNode {
    bool isWord{false};
    int frequency{0};
    std::unordered_map<char, std::unique_ptr<TrieNode>> children;
};

class GestureEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isSwiping READ isSwiping NOTIFY isSwipingChanged)

public:
    explicit GestureEngine(QObject *parent = nullptr);

    bool isSwiping() const { return m_isSwiping; }

    Q_INVOKABLE void registerKeyCenter(const QString &key, double x, double y);
    Q_INVOKABLE void clearKeyCenters();
    Q_INVOKABLE void addTouchPoint(double x, double y);
    Q_INVOKABLE void startTouch(double x, double y);
    Q_INVOKABLE void endTouch();
    Q_INVOKABLE QStringList processGesture();

signals:
    void isSwipingChanged();
    void suppressPopups();
    void strokeUpdated(const QList<QPointF> &points);
    void wordPredicted(const QString &word);

private:
    void loadItalianDictionary();
    void insertWord(const std::string &word, int freq);
    double euclideanDistance(const QPointF &p1, const QPointF &p2);

    std::unique_ptr<TrieNode> m_trieRoot;
    QMap<QString, QPointF> m_keyCenters;
    QList<QPointF> m_touchPoints;
    bool m_isSwiping{false};
    QPointF m_startPoint;
};

#endif // GESTUREENGINE_H
