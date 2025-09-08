//
//  TokenBucket.swift
//  TokenBucket
//
//  Code modified from Gemini 2.5 Pro response
//

import Foundation

/**
 * A thread-safe implementation of the Token Bucket algorithm for API rate limiting.
 *
 * This class allows you to control the rate of operations, such as API calls,
 * by ensuring they do not exceed a configured limit.
 */
public class TokenBucket {

    // MARK: - Properties

    /// The maximum number of tokens the bucket can hold. This is the "burst" capacity.
    private let capacity: Int

    /// The rate at which tokens are added to the bucket, specified in tokens per second.
    private let refillRate: Double

    /// The current number of tokens available in the bucket.
    private var tokens: Int

    /// The timestamp of the last time the bucket was refilled with tokens.
    private var lastRefillTimestamp: Date

    /// A dispatch queue to ensure thread-safe access to the `tokens` property.
    private let queue = DispatchQueue(label: "com.tokenbucket.threadsafe")

    // MARK: - Initialization

    /**
     * Initializes a new TokenBucket instance.
     *
     * - Parameters:
     * - capacity: The maximum number of tokens the bucket can hold. Must be greater than 0.
     * - refillRate: The number of tokens to add to the bucket per second. Must be greater than 0.
     */
    public init(capacity: Int, refillRate: Double) {
        precondition(capacity > 0, "Capacity must be a positive integer.")
        precondition(refillRate > 0, "Refill rate must be a positive number.")

        self.capacity = capacity
        self.refillRate = refillRate

        // Start with a full bucket.
        self.tokens = capacity
        self.lastRefillTimestamp = Date()
    }

    // MARK: - Core Logic

    /**
     * Refills the bucket with new tokens based on the time that has passed
     * since the last refill.
     *
     * This is a private method and should only be called from within the synchronized queue.
     */
    private func refill() {
        let now = Date()
        let timeElapsed = now.timeIntervalSince(lastRefillTimestamp)

        // Calculate how many new tokens to add.
        let tokensToAdd = timeElapsed * refillRate

        if tokensToAdd > 0 {
            // Add the new tokens, ensuring we don't exceed the bucket's capacity.
            self.tokens = min(self.capacity, Int(floor(Double(self.tokens) + tokensToAdd)))
            self.lastRefillTimestamp = now
        }
    }
    
    /**
     * Asynchronously consumes a specified number of tokens from the bucket. If not enough
     * tokens are available, this method will suspend and wait without blocking the thread
     * until the required tokens have been refilled.
     *
     * This method is thread-safe and non-blocking. It requires a modern Swift concurrency context (async/await).
     *
     * - Parameter tokensToConsume: The number of tokens to consume. Defaults to 1.
     */
    public func consumeOrWaitAsync() async {
        while true {
            var waitTime: TimeInterval = 0

            let consumedInThisIteration = queue.sync {
                refill()
                if self.tokens >= 1 {
                    self.tokens -= 1
                    return true
                } else {
                    let tokensNeeded = 1 - self.tokens
                    waitTime = Double(tokensNeeded) / self.refillRate
                    return false
                }
            }

            if consumedInThisIteration {
                // Successfully consumed, exit the loop.
                break
            }

            if waitTime > 0 {
                do {
                    // Use the non-blocking Task.sleep to wait asynchronously.
                    let nanoseconds = UInt64((waitTime + 0.000_001) * 1_000_000_000)
                    try await Task.sleep(nanoseconds: nanoseconds)
                } catch {
                    // This catch block is needed if the task is cancelled.
                    // If cancellation occurs, we exit the loop.
                    break
                }
            }
        }
    }
}
