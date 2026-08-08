#ifndef PROCEDURALAUDIOENGINE_H
#define PROCEDURALAUDIOENGINE_H

#include <QObject>
#include <QAudioSink>
#include <QAudioFormat>
#include <QIODevice>
#include <QByteArray>
#include <QMap>
#include <cmath>

enum class KeyAudioType {
    Standard = 0,
    Space = 1,
    Backspace = 2,
    Enter = 3,
    BackspaceSoft = 4
};

class ProceduralAudioEngine : public QObject {
    Q_OBJECT
    Q_ENUMS(KeyAudioType)

private:
    QAudioFormat m_format;
    QAudioSink* m_audioSink = nullptr;
    QIODevice* m_audioDevice = nullptr;
    QMap<KeyAudioType, QByteArray> m_soundBuffers;
    bool m_audioEnabled = true;

    // Generatore matematico di impulsi acustici con inviluppo esponenziale in RAM
    QByteArray generateClickSample(double freqStart, double freqEnd, double durationMs, double decayRate, bool isDoubleHarmonic = false) {
        const int sampleRate = 44100;
        int numSamples = static_cast<int>(sampleRate * (durationMs / 1000.0));

        QByteArray buffer;
        buffer.resize(numSamples * sizeof(int16_t));
        int16_t* samples = reinterpret_cast<int16_t*>(buffer.data());

        for (int i = 0; i < numSamples; ++i) {
            double t = static_cast<double>(i) / sampleRate;
            double progress = static_cast<double>(i) / numSamples;

            // Sweep dinamico della frequenza
            double currentFreq = freqStart + (freqEnd - freqStart) * progress;

            // Inviluppo ADSR con decadimento esponenziale
            double envelope = std::exp(-decayRate * progress * 10.0);

            // Attacco morbido (1-2 ms ramp) per evitare distorsioni o pop iniziali
            double attackTime = 0.002;
            if (t < attackTime) {
                envelope *= (t / attackTime);
            }

            // Sintesi onda sinusoidale (singola o doppia armonica per Enter)
            double wave = 0.0;
            if (isDoubleHarmonic) {
                wave = 0.6 * std::sin(2.0 * M_PI * freqStart * t) + 0.4 * std::sin(2.0 * M_PI * freqEnd * t);
            } else {
                wave = std::sin(2.0 * M_PI * currentFreq * t);
            }

            // Scaling a 16-bit signed PCM (max amplitude 28000 for standard, 12000 for soft)
            double maxAmp = (decayRate > 1.5) ? 12000.0 : 28000.0;
            samples[i] = static_cast<int16_t>(wave * envelope * maxAmp);
        }
        return buffer;
    }

public:
    explicit ProceduralAudioEngine(QObject* parent = nullptr) : QObject(parent) {
        m_format.setSampleRate(44100);
        m_format.setChannelCount(1);
        m_format.setSampleFormat(QAudioFormat::Int16);

        m_audioSink = new QAudioSink(m_format, this);

        // Pre-calcolo dei buffer in RAM (0.4 ms overhead iniziale, zero I/O durante la digitazione)
        m_soundBuffers[KeyAudioType::Standard]      = generateClickSample(900.0, 900.0, 18.0, 1.2);
        m_soundBuffers[KeyAudioType::Space]         = generateClickSample(380.0, 320.0, 32.0, 0.8);
        m_soundBuffers[KeyAudioType::Backspace]     = generateClickSample(680.0, 380.0, 22.0, 1.0);
        m_soundBuffers[KeyAudioType::Enter]         = generateClickSample(1100.0, 1400.0, 26.0, 0.9, true);
        m_soundBuffers[KeyAudioType::BackspaceSoft] = generateClickSample(520.0, 340.0, 14.0, 1.8);

        // Inizializza l'output stream audio
        m_audioDevice = m_audioSink->start();
    }

    ~ProceduralAudioEngine() override {
        if (m_audioSink) {
            m_audioSink->stop();
        }
    }

    Q_INVOKABLE void setAudioEnabled(bool enabled) {
        m_audioEnabled = enabled;
    }

    Q_INVOKABLE bool isAudioEnabled() const {
        return m_audioEnabled;
    }

    Q_INVOKABLE void playKeyPressSound(int keyType) {
        if (!m_audioEnabled) return;

        KeyAudioType type = static_cast<KeyAudioType>(keyType);
        if (!m_soundBuffers.contains(type)) return;

        if (!m_audioDevice || m_audioSink->state() == QAudio::StoppedState) {
            m_audioDevice = m_audioSink->start();
        }

        if (m_audioDevice) {
            m_audioDevice->write(m_soundBuffers[type]);
        }
    }

    Q_INVOKABLE void playKeySoundForLabel(const QString &label, bool isBackspace = false, bool isSpecial = false) {
        if (!m_audioEnabled) return;

        if (isBackspace || label == "⌫" || label == "Canc" || label == "Del") {
            playKeyPressSound(static_cast<int>(KeyAudioType::Backspace));
        } else if (label == "space" || label == " " || label == "Spazio") {
            playKeyPressSound(static_cast<int>(KeyAudioType::Space));
        } else if (label == "↵" || label == "Enter" || label == "Invio" || label == "Return") {
            playKeyPressSound(static_cast<int>(KeyAudioType::Enter));
        } else {
            playKeyPressSound(static_cast<int>(KeyAudioType::Standard));
        }
    }
};

#endif // PROCEDURALAUDIOENGINE_H
