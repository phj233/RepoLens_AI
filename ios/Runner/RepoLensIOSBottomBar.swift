import Flutter
import SwiftUI
import UIKit

struct RepoLensNativeTabLabel: View {
  let item: RepoLensNativeNavItem
  let isSelected: Bool

  var body: some View {
    VStack(spacing: 3) {
      Image(systemName: item.systemImage)
        .font(.system(size: 17, weight: .semibold))
      Text(item.shortTitle)
        .font(.system(size: 11, weight: .medium))
        .lineLimit(1)
    }
    .frame(maxWidth: .infinity, minHeight: 42)
    .foregroundColor(isSelected ? Color.primary : Color.secondary)
    .opacity(isSelected ? 1 : 0.72)
    .contentShape(Rectangle())
  }
}

@available(iOS 26.0, *)
struct RepoLensIOSLiquidGlassBottomBar: View {
  let selectedIndex: Int
  let onSelect: (Int) -> Void

  @State private var interactionIndex: Int?
  @State private var isPressing = false
  @State private var dragTension: CGFloat = 0

  private var activeIndex: Int {
    interactionIndex ?? selectedIndex
  }

  private var clearInteractiveGlass: Glass {
    .clear.interactive().tint(.clear)
  }

  var body: some View {
    GlassEffectContainer(spacing: 0) {
      GeometryReader { proxy in
        let itemCount = RepoLensNativeNavItem.items.count
        let tabWidth = max(proxy.size.width / CGFloat(itemCount), 1)

        ZStack(alignment: .leading) {
          liquidIndicator(tabWidth: tabWidth)
            .offset(x: CGFloat(activeIndex) * tabWidth)
            .animation(.spring(response: 0.30, dampingFraction: 0.78), value: activeIndex)

          HStack(spacing: 0) {
            ForEach(RepoLensNativeNavItem.items) { item in
              RepoLensNativeTabLabel(
                item: item,
                isSelected: selectedIndex == item.index || interactionIndex == item.index
              )
              .frame(width: tabWidth)
            }
          }
        }
        .frame(width: proxy.size.width, height: 64)
        .contentShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .gesture(bottomBarGesture(tabWidth: tabWidth))
        .glassEffect(
          clearInteractiveGlass,
          in: RoundedRectangle(cornerRadius: 32, style: .continuous)
        )
      }
      .frame(height: 64)
      .padding(.horizontal, 8)
      .padding(.vertical, 8)
    }
    .padding(.horizontal, 12)
    .padding(.top, 6)
    .padding(.bottom, 8)
  }

  private func liquidIndicator(tabWidth: CGFloat) -> some View {
    Capsule()
      .fill(Color.clear)
      .glassEffect(clearInteractiveGlass, in: Capsule())
      .frame(width: max(tabWidth - 8, 44), height: 56)
      .padding(.horizontal, 4)
      .scaleEffect(
        x: 1 + (isPressing ? 0.16 : 0) + dragTension * 0.24,
        y: 1 + (isPressing ? 0.16 : 0) - dragTension * 0.08
      )
      .animation(.spring(response: 0.24, dampingFraction: 0.74), value: isPressing)
      .animation(.spring(response: 0.18, dampingFraction: 0.70), value: dragTension)
  }

  private func bottomBarGesture(tabWidth: CGFloat) -> some Gesture {
    DragGesture(minimumDistance: 0, coordinateSpace: .local)
      .onChanged { value in
        let index = indexFor(locationX: value.location.x, tabWidth: tabWidth)
        let speedTension =
          abs(value.predictedEndTranslation.width - value.translation.width)
          / max(tabWidth, 1) * 0.32
        let distanceTension = abs(value.translation.width) / max(tabWidth, 1) * 0.06
        withAnimation(.spring(response: 0.18, dampingFraction: 0.72)) {
          interactionIndex = index
          isPressing = true
          dragTension = min(speedTension + distanceTension, 0.58)
        }
      }
      .onEnded { value in
        let index = indexFor(locationX: value.location.x, tabWidth: tabWidth)
        onSelect(index)
        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
          interactionIndex = nil
          isPressing = false
          dragTension = 0
        }
      }
  }

  private func indexFor(locationX: CGFloat, tabWidth: CGFloat) -> Int {
    let itemCount = RepoLensNativeNavItem.items.count
    let rawIndex = Int((locationX / max(tabWidth, 1)).rounded(.down))
    return min(max(rawIndex, 0), itemCount - 1)
  }
}

@available(iOS 26.0, *)
struct RepoLensLiquidGlassTabButton: View {
  let item: RepoLensNativeNavItem
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      label
    }
    .buttonStyle(.glass)
    .frame(maxWidth: .infinity)
  }

  private var label: some View {
    RepoLensNativeTabLabel(item: item, isSelected: isSelected)
      .padding(.horizontal, 4)
      .padding(.vertical, 2)
  }
}
