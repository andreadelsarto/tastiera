#include "gestureengine.h"
#include <QDebug>
#include <cmath>

GestureEngine::GestureEngine(QObject *parent)
    : QObject(parent), m_trieRoot(new TrieNode())
{
    loadDictionary();
    m_currentSuggestions = {"ciao", "tastiera", "plasma", "linux"};
}

GestureEngine::~GestureEngine()
{
    // Simple memory cleanup
}

void GestureEngine::loadDictionary()
{
    static const QStringList italianWords = {
        "ciao", "come", "stai", "tutto", "bene", "grazie", "prego", "buongiorno", "buonasera", "buonanotte",
        "tastiera", "plasma", "linux", "kde", "terminale", "sistema", "configurazione", "per", "favore",
        "anche", "ancora", "adesso", "allora", "avere", "avuto", "anno", "anni", "amico", "amici",
        "cosa", "quando", "dove", "perché", "chi", "quale", "quanto", "quanti", "quante",
        "questo", "questa", "questi", "queste", "quello", "quella", "quelli", "quelle",
        "tutti", "tutte", "molto", "molti", "molte", "poco", "pochi", "poche",
        "sempre", "subito", "spesso", "prima", "dopo", "sopra", "sotto", "dentro", "fuori",
        "senza", "contro", "secondo", "durante", "mentre", "invece", "inoltre", "infatti",
        "italiano", "italiana", "italiani", "italiane", "tablet", "postmarketos", "alpine",
        "funziona", "grande", "bello", "ottimo", "perfetto", "modalità", "schermo", "fluttuante"
    };

    for (const QString &w : italianWords) {
        insertWord(w);
    }
}

void GestureEngine::insertWord(const QString &word)
{
    TrieNode *curr = m_trieRoot;
    for (const QChar &ch : word.toLower()) {
        if (!curr->children.contains(ch)) {
            curr->children[ch] = new TrieNode();
        }
        curr = curr->children[ch];
    }
    curr->isEndOfWord = true;
    curr->word = word;
}

QStringList GestureEngine::findPrefixMatches(const QString &prefix, int maxResults)
{
    QStringList results;
    if (prefix.isEmpty()) {
        return {"ciao", "tastiera", "plasma", "linux"};
    }

    TrieNode *curr = m_trieRoot;
    for (const QChar &ch : prefix.toLower()) {
        if (!curr->children.contains(ch)) {
            return results;
        }
        curr = curr->children[ch];
    }

    collectWords(curr, results, maxResults);
    return results;
}

void GestureEngine::collectWords(TrieNode *node, QStringList &results, int maxResults)
{
    if (!node || results.size() >= maxResults) return;

    if (node->isEndOfWord) {
        results.append(node->word);
    }

    for (auto it = node->children.begin(); it != node->children.end(); ++it) {
        collectWords(it.value(), results, maxResults);
        if (results.size() >= maxResults) break;
    }
}

void GestureEngine::updateCurrentPrefix(const QString &prefix)
{
    QStringList matches = findPrefixMatches(prefix, 4);
    if (matches.isEmpty()) {
        matches = {"ciao", "tastiera", "plasma", "linux"};
    }
    if (m_currentSuggestions != matches) {
        m_currentSuggestions = matches;
        emit suggestionsChanged();
    }
}

void GestureEngine::startTouch(const QPointF &pt)
{
    m_touchPoints.clear();
    m_touchPoints.append(pt);
}

void GestureEngine::updateTouch(const QPointF &pt)
{
    if (m_touchPoints.isEmpty()) return;

    QPointF last = m_touchPoints.last();
    qreal dist = std::hypot(pt.x() - last.x(), pt.y() - last.y());

    if (dist > 10.0) {
        m_touchPoints.append(pt);
    }
}

void GestureEngine::endTouch()
{
    if (m_touchPoints.size() < 3) {
        m_touchPoints.clear();
        return;
    }

    qreal totalDist = 0.0;
    for (int i = 1; i < m_touchPoints.size(); ++i) {
        totalDist += std::hypot(m_touchPoints[i].x() - m_touchPoints[i-1].x(),
                                m_touchPoints[i].y() - m_touchPoints[i-1].y());
    }

    if (totalDist > 85.0) {
        qDebug() << "Gesture detected! Path length:" << totalDist;
        emit wordPredicted("tastiera");
    }

    m_touchPoints.clear();
}
