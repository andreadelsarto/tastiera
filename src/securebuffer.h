#ifndef SECUREBUFFER_H
#define SECUREBUFFER_H

#include <sys/mman.h>
#include <string.h>
#include <vector>
#include <cstddef>
#include <algorithm>

class SecureKeyBuffer {
public:
    explicit SecureKeyBuffer(size_t size = 128)
        : m_size(size), m_length(0), m_buffer(size, 0)
    {
        if (m_size > 0) {
            // Lock memory page in physical RAM to prevent Linux kernel from swapping to disk
            if (mlock(m_buffer.data(), m_size) != 0) {
                // Fallback handling if RLIMIT_MEMLOCK limits are restrictive
            }
        }
    }

    ~SecureKeyBuffer() {
        clear();
    }

    // Disable copy constructors to prevent dangling insecure RAM copies
    SecureKeyBuffer(const SecureKeyBuffer &) = delete;
    SecureKeyBuffer &operator=(const SecureKeyBuffer &) = delete;

    SecureKeyBuffer(SecureKeyBuffer &&other) noexcept
        : m_size(other.m_size), m_length(other.m_length), m_buffer(std::move(other.m_buffer))
    {
        other.m_size = 0;
        other.m_length = 0;
    }

    SecureKeyBuffer &operator=(SecureKeyBuffer &&other) noexcept {
        if (this != &other) {
            clear();
            m_size = other.m_size;
            m_length = other.m_length;
            m_buffer = std::move(other.m_buffer);
            other.m_size = 0;
            other.m_length = 0;
        }
        return *this;
    }

    void clear() {
        if (!m_buffer.empty()) {
            // explicit_bzero prevents compiler optimizations from removing memory zeroing
            explicit_bzero(m_buffer.data(), m_buffer.size());
            munlock(m_buffer.data(), m_buffer.size());
            m_length = 0;
        }
    }

    void appendChar(char c) {
        if (m_length < m_size) {
            m_buffer[m_length++] = c;
        }
    }

    void removeLastChar() {
        if (m_length > 0) {
            m_length--;
            m_buffer[m_length] = 0;
        }
    }

    char *data() { return m_buffer.data(); }
    const char *data() const { return m_buffer.data(); }
    size_t size() const { return m_size; }
    size_t length() const { return m_length; }

private:
    size_t m_size;
    size_t m_length;
    std::vector<char> m_buffer;
};

#endif // SECUREBUFFER_H
