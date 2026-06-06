import Flutter
import SwiftUI
import UIKit

struct RepoLensIOSToast: View {
  let message: String
  let isError: Bool
  let onClose: () -> Void

  var body: some View {
    RepoLensNativeGlassPanel {
      HStack(spacing: 10) {
        Image(systemName: isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
          .foregroundColor(isError ? .red : .accentColor)
        Text(message)
          .font(.footnote)
          .lineLimit(3)
          .frame(maxWidth: .infinity, alignment: .leading)
        RepoLensIOSToastCloseButton(onClose: onClose)
      }
    }
    .frame(maxWidth: 360, alignment: .trailing)
    .contentShape(Rectangle())
  }
}

struct RepoLensIOSToastCloseButton: View {
  let onClose: () -> Void

  var body: some View {
    Button(action: onClose) {
      Image(systemName: "xmark")
        .font(.system(size: 13, weight: .semibold))
        .frame(width: 32, height: 32)
        .contentShape(Circle())
    }
    .buttonStyle(.plain)
    .background {
      if #available(iOS 26.0, *) {
        Circle()
          .fill(Color.clear)
          .glassEffect(.regular.interactive(), in: Circle())
      } else {
        Circle()
          .fill(.thinMaterial)
          .overlay(
            Circle().stroke(Color.primary.opacity(0.10), lineWidth: 1)
          )
      }
    }
    .accessibilityLabel(Text("Close"))
  }
}

struct RepoLensIOSImagePreviewOverlay: View {
  let path: String
  let strings: RepoLensNativeStrings
  let onClose: () -> Void

  var body: some View {
    ZStack {
      Color.black.opacity(0.36)
        .ignoresSafeArea()
      RepoLensNativeGlassPanel {
        VStack(alignment: .leading, spacing: 12) {
          HStack {
            Text(strings.imagePreview)
              .font(.headline)
            Spacer()
            Button(action: onClose) {
              Label(strings.close, systemImage: "xmark")
            }
            .buttonStyle(.plain)
          }
          if let image = UIImage(contentsOfFile: path) {
            Image(uiImage: image)
              .resizable()
              .scaledToFit()
              .frame(maxWidth: 860, maxHeight: 620)
              .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
          } else {
            Text(strings.openExportFileFailed)
              .foregroundColor(.secondary)
          }
        }
      }
      .padding(18)
    }
  }
}

struct RepoLensNativeGlassPanel<Content: View>: View {
  let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    if #available(iOS 26.0, *) {
      content
        .padding(16)
        .glassEffect(
          .regular.interactive(),
          in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
    } else if #available(iOS 15.0, *) {
      content
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    } else {
      content
        .padding(16)
        .background(
          RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
  }
}

struct RepoLensNativeActionButton: View {
  let title: String
  let systemImage: String
  var prominent = false
  let action: () -> Void

  var body: some View {
    if #available(iOS 26.0, *) {
      if prominent {
        Button(action: action) {
          Label(title, systemImage: systemImage)
        }
        .buttonStyle(.glassProminent)
      } else {
        Button(action: action) {
          Label(title, systemImage: systemImage)
        }
        .buttonStyle(.glass)
      }
    } else if #available(iOS 15.0, *) {
      if prominent {
        Button(action: action) {
          Label(title, systemImage: systemImage)
        }
        .buttonStyle(.borderedProminent)
      } else {
        Button(action: action) {
          Label(title, systemImage: systemImage)
        }
        .buttonStyle(.bordered)
      }
    } else {
      Button(action: action) {
        Label(title, systemImage: systemImage)
      }
    }
  }
}

struct RepoLensPageHeader: View {
  let title: String
  let subtitle: String
  var action: RepoLensNativeActionButton?

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 4) {
          Text(title)
            .font(.title2.weight(.semibold))
          Text(subtitle)
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        Spacer()
        if let action {
          action
        }
      }
    }
  }
}

struct RepoLensMetricPill: View {
  let title: String
  let value: String
  let systemImage: String

  var body: some View {
    RepoLensNativeGlassPanel {
      HStack(spacing: 12) {
        Image(systemName: systemImage)
          .font(.headline)
          .foregroundColor(.accentColor)
        VStack(alignment: .leading, spacing: 2) {
          Text(value)
            .font(.title3.weight(.semibold))
          Text(title)
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

struct RepoLensNativeChip: View {
  let text: String
  var systemImage: String?

  var body: some View {
    HStack(spacing: 5) {
      if let systemImage {
        Image(systemName: systemImage)
      }
      Text(text)
    }
    .font(.caption.weight(.medium))
    .padding(.horizontal, 9)
    .padding(.vertical, 6)
    .background(
      Capsule(style: .continuous)
        .fill(Color.accentColor.opacity(0.12))
    )
    .foregroundColor(.accentColor)
  }
}

struct RepoLensNativeColorOption: Identifiable {
  let label: String
  let value: String

  var id: String { "\(label)-\(value)" }

  static let themeDefaults = [
    RepoLensNativeColorOption(label: "RepoLens", value: "#2F7D5F"),
    RepoLensNativeColorOption(label: "Azure", value: "#0088FF"),
    RepoLensNativeColorOption(label: "Violet", value: "#7C3AED"),
    RepoLensNativeColorOption(label: "Amber", value: "#D97706"),
    RepoLensNativeColorOption(label: "Coral", value: "#C2410C"),
    RepoLensNativeColorOption(label: "Teal", value: "#0F766E"),
  ]
}

struct RepoLensNativeColorPalette: View {
  let title: String
  let hint: String
  let value: String
  let options: [RepoLensNativeColorOption]
  let onSelect: (String) -> Void

  @State private var customValue = ""

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(title)
        .font(.headline)
      Text(hint)
        .font(.caption)
        .foregroundColor(.secondary)
      LazyVGrid(
        columns: [GridItem(.adaptive(minimum: 44), spacing: 8)],
        alignment: .leading,
        spacing: 8
      ) {
        ForEach(options) { option in
          Button {
            customValue = option.value
            onSelect(option.value)
          } label: {
            swatch(option)
          }
          .buttonStyle(.plain)
          .help(option.label)
        }
      }
      HStack(spacing: 10) {
        selectedPreview
        TextField(
          "#RRGGBB",
          text: Binding(
            get: { customValue },
            set: { next in
              customValue = next
              if let normalized = normalizedHex(next) {
                onSelect(normalized)
              }
            }
          )
        )
        .textFieldStyle(.roundedBorder)
      }
    }
    .onAppear {
      customValue = value
    }
  }

  private func swatch(_ option: RepoLensNativeColorOption) -> some View {
    let color = Color(hex: option.value) ?? .clear
    let selected = normalizedHex(option.value) == normalizedHex(value)
    return ZStack {
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .fill(color)
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .stroke(selected ? Color.accentColor : Color.secondary.opacity(0.36), lineWidth: selected ? 2 : 1)
      if selected {
        Image(systemName: "checkmark")
          .font(.caption.weight(.bold))
          .foregroundColor(.white)
          .shadow(radius: 2)
      }
    }
    .frame(width: 44, height: 44)
  }

  private var selectedPreview: some View {
    let color = Color(hex: value) ?? .accentColor
    return RoundedRectangle(cornerRadius: 12, style: .continuous)
      .fill(color)
      .overlay(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .stroke(Color.secondary.opacity(0.36), lineWidth: 1)
      )
      .frame(width: 48, height: 48)
  }

  private func normalizedHex(_ raw: String) -> String? {
    let cleaned = raw.trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: "#", with: "")
    guard cleaned.count == 6 || cleaned.count == 8,
          UInt64(cleaned, radix: 16) != nil else {
      return nil
    }
    return "#\(cleaned.uppercased())"
  }
}

extension Color {
  init?(hex: String) {
    let cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: "#", with: "")
    guard cleaned.count == 6 || cleaned.count == 8,
          let value = UInt64(cleaned, radix: 16) else {
      return nil
    }

    if cleaned.count == 6 {
      self = Color(
        red: Double((value >> 16) & 0xFF) / 255,
        green: Double((value >> 8) & 0xFF) / 255,
        blue: Double(value & 0xFF) / 255
      )
    } else {
      self = Color(
        .sRGB,
        red: Double((value >> 16) & 0xFF) / 255,
        green: Double((value >> 8) & 0xFF) / 255,
        blue: Double(value & 0xFF) / 255,
        opacity: Double((value >> 24) & 0xFF) / 255
      )
    }
  }
}
