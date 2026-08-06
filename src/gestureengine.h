#ifndef GESTUREENGINE_H
#define GESTUREENGINE_H

#include <QObject>
#include <QPointF>
#include <QList>
#include <QStringList>
#include <QMap>

struct TrieNode {
    QMap<QChar, TrieNode*> children;
    bool isEndOfWord = false;
    QString word;
};

class GestureEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList currentSuggestions READ currentSuggestions NOTIFY suggestionsChanged)

public:
    explicit GestureEngine(QObject *parent = nullptr);
    ~GestureEngine();

    Q_INVOKABLE void startTouch(const QPointF &pt);
    Q_INVOKABLE void updateTouch(const QPointF &pt);
    Q_INVOKABLE void endTouch();
    Q_INVOKABLE void updateCurrentPrefix(const QString &prefix);

    QStringList currentSuggestions() const { return m_currentSuggestions; }

signals:
    void gestureCompleted(const QString &recognizedWord);
    void wordPredicted(const QString &word);
    void suggestionsChanged();

private:
    void loadDictionary();
    void insertWord(const QString &word);
    QStringList findPrefixMatches(const QString &prefix, int maxResults = 4);
    void collectWords(TrieNode *node, QStringList &results, int maxResults);

    QList<QPointF> m_touchPoints;
    TrieNode *m_trieRoot;
    QStringList m_currentSuggestions;
};

#endif // GESTUREENGINE_H
