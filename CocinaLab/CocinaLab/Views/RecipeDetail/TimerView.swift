import SwiftUI
import Combine

/// Self-contained countdown timer for a step or variant's cooking time.
struct TimerView: View {
    let totalSeconds: Int

    @State private var remainingSeconds: Int
    @State private var isRunning = false
    @State private var cancellable: AnyCancellable?

    init(totalSeconds: Int) {
        self.totalSeconds = totalSeconds
        _remainingSeconds = State(initialValue: totalSeconds)
    }

    private var timeText: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "timer")
                .foregroundStyle(Color.accentColor)

            Text(timeText)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(remainingSeconds == 0 ? .red : .primary)

            Button {
                isRunning ? pause() : start()
            } label: {
                Image(systemName: isRunning ? "pause.fill" : "play.fill")
            }
            .buttonStyle(.borderless)

            if remainingSeconds != totalSeconds {
                Button {
                    reset()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Capsule().fill(Color.accentColor.opacity(0.1)))
        .onDisappear { stop() }
    }

    private func start() {
        guard remainingSeconds > 0 else { return }
        isRunning = true
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                } else {
                    stop()
                }
            }
    }

    private func pause() {
        stop()
    }

    private func stop() {
        isRunning = false
        cancellable?.cancel()
        cancellable = nil
    }

    private func reset() {
        stop()
        remainingSeconds = totalSeconds
    }
}
