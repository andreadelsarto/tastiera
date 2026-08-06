#include "gestureengine.h"
#include <cmath>
#include <QDebug>
#include <algorithm>

GestureEngine::GestureEngine(QObject *parent)
    : QObject(parent),
      m_trieRoot(std::make_unique<TrieNode>())
{
    loadItalianDictionary();
}

void GestureEngine::insertWord(const std::string &word, int freq)
{
    TrieNode *current = m_trieRoot.get();
    for (char c : word) {
        c = std::tolower(c);
        if (current->children.find(c) == current->children.end()) {
            current->children[c] = std::make_unique<TrieNode>();
        }
        current = current->children[c].get();
    }
    current->isWord = true;
    current->frequency = freq;
}

void GestureEngine::loadItalianDictionary()
{
    static const std::vector<std::pair<std::string, int>> dict = {
        {"ciao", 100}, {"come", 95}, {"stai", 90}, {"tutti", 88}, {"grazie", 92},
        {"buongiorno", 85}, {"ancora", 80}, {"perche", 89}, {"dopo", 82}, {"quando", 87},
        {"dove", 86}, {"anche", 91}, {"questo", 93}, {"quello", 84}, {"bene", 94},
        {"molto", 89}, {"tutto", 90}, {"sempre", 88}, {"senza", 78}, {"prima", 80},
        {"casa", 85}, {"tempo", 83}, {"lavoro", 81}, {"modo", 79}, {"vita", 78},
        {"parte", 77}, {"mondo", 76}, {"giorno", 84}, {"anno", 82}, {"stato", 80},
        {"cosa", 92}, {"fare", 90}, {"dire", 88}, {"vedere", 85}, {"andare", 87},
        {"sapere", 86}, {"potere", 84}, {"volere", 85}, {"dovere", 83}, {"prendere", 80}
    };

    for (const auto &item : dict) {
        insertWord(item.first, item.second);
    }
}

void GestureEngine::registerKeyCenter(const QString &key, double x, double y)
{
    m_keyCenters[key.toLower()] = QPointF(x, y);
}

void GestureEngine::clearKeyCenters()
{
    m_keyCenters.clear();
}

void GestureEngine::startTouch(double x, double y)
{
    m_startPoint = QPointF(x, y);
    m_touchPoints.clear();
    m_touchPoints.append(m_startPoint);
    m_isSwiping = false;
}

void GestureEngine::addTouchPoint(double x, double y)
{
    QPointF currentPoint(x, y);
    m_touchPoints.append(currentPoint);

    if (!m_isSwiping) {
        double dist = euclideanDistance(m_startPoint, currentPoint);
        if (dist > 5.0) { // TouchUpdate > 5px threshold
            m_isSwiping = true;
            emit isSwipingChanged();
            emit suppressPopups();
        }
    }

    if (m_isSwiping) {
        emit strokeUpdated(m_touchPoints);
    }
}

void GestureEngine::endTouch()
{
    if (m_isSwiping) {
        processGesture();
    }
    m_isSwiping = false;
    emit isSwipingChanged();
}

double GestureEngine::euclideanDistance(const QPointF &p1, const QPointF &p2)
{
    double dx = p1.x() - p2.x();
    double dy = p1.y() - p2.y();
    return std::sqrt(dx * dx + dy * dy);
}

QStringList GestureEngine::processGesture()
{
    QStringList results;
    if (m_touchPoints.isEmpty() || m_keyCenters.isEmpty()) {
        return results;
    }

    QPointF lastTouchPoint = m_touchPoints.last();

    // Map each touch point to closest key
    QString sampledPath;
    for (const QPointF &pt : m_touchPoints) {
        QString closestKey;
        double minDist = 1e9;
        for (auto it = m_keyCenters.constBegin(); it != m_keyCenters.constEnd(); ++it) {
            double d = euclideanDistance(pt, it.value());
            if (d < minDist) {
                minDist = d;
                closestKey = it.key();
            }
        }
        if (!closestKey.isEmpty() && (sampledPath.isEmpty() || sampledPath.right(1) != closestKey)) {
            sampledPath.append(closestKey);
        }
    }

    // Filter dictionary against physical distance requirement (last letter center <= 85px from release point)
    struct Candidate {
        QString word;
        double score;
    };
    std::vector<Candidate> candidates;

    std::function<void(TrieNode*, QString)> searchTrie = [&](TrieNode *node, QString currentWord) {
        if (!node) return;
        if (node->isWord) {
            QString lastChar = currentWord.right(1).toLower();
            if (m_keyCenters.contains(lastChar)) {
                QPointF lastKeyPos = m_keyCenters[lastChar];
                double dist = euclideanDistance(lastTouchPoint, lastKeyPos);
                // Strict requirement: Discard words whose last letter > 85px from touch release point
                if (dist <= 85.0) {
                    double score = node->frequency - dist * 0.2;
                    candidates.push_back({currentWord, score});
                }
            }
        }
        for (const auto &pair : node->children) {
            searchTrie(pair.second.get(), currentWord + QChar(pair.first));
        }
    };

    searchTrie(m_trieRoot.get(), "");

    std::sort(candidates.begin(), candidates.end(), [](const Candidate &a, const Candidate &b) {
        return a.score > b.score;
    });

    for (size_t i = 0; i < std::min<size_t>(5, candidates.size()); ++i) {
        results.append(candidates[i].word);
    }

    if (!results.isEmpty()) {
        emit wordPredicted(results.first());
    }

    return results;
}
