import SwiftUI

struct OpenCommandView: View {
  @ObserveInjection var inject
  @EnvironmentObject var applicationStore: ApplicationStore
  @Binding var command: DetailViewModel.CommandViewModel

  @State private var isHovered = false

  init(command: Binding<DetailViewModel.CommandViewModel>) {
    _command = command
  }

  var body: some View {
    CommandContainerView(isEnabled: $command.isEnabled, icon: {
      if let image = command.image {
        Image(nsImage: image)
          .resizable()
      }
    }, content: {

        HStack(spacing: 4) {
          Menu(content: { }, label: {
            HStack(spacing: 4) {
              Text("Open")
                .fixedSize(horizontal: false, vertical: true)
                .truncationMode(.middle)
                .allowsTightening(true)
            }
            .padding(4)
          })
          .buttonStyle(.plain)
          .background(
            RoundedRectangle(cornerRadius: 4)
              .stroke(Color(.disabledControlTextColor))
              .opacity(0.5)
          )


          GeometryReader { proxy in
            VStack(alignment: .center) {
              Spacer()
              VStack(alignment: .leading) {
                TextField("", text: $command.name)
                  .font(.system(.body, design: .rounded, weight: .semibold))
                  .truncationMode(.head)
                  .textFieldStyle(.plain)
                  .frame(maxWidth: proxy.size.width)
                  .fixedSize(horizontal: isHovered ? false : true, vertical: false)
                  .minimumScaleFactor(0.5)
                  .lineLimit(1)
                  .padding(4)
                  .background(
                    RoundedRectangle(cornerRadius: 4)
                      .stroke(isHovered ? Color(nsColor: .controlAccentColor) : .clear, lineWidth: 1)
                      .animation(.default, value: isHovered)
                  )
                  .onHover { hovering in
                    self.isHovered = hovering
                  }
              }
              Spacer()
            }
          }

          if case .open(let appName) = command.kind,
             let appName {
            Text(" in ")

            Menu(content: {
              ForEach(applicationStore.applicationsToOpen(command.name)) { app in
                Button(app.displayName, action: {})
              }
            }, label: {
              HStack(spacing: 4) {
                Text(appName)
                  .fixedSize(horizontal: false, vertical: true)
                  .truncationMode(.middle)
                  .lineLimit(1)
                  .allowsTightening(true)
                Image(systemName: "chevron.down")
                  .opacity(0.5)
              }
              .padding(4)
            })
            .buttonStyle(.plain)
            .background(
              RoundedRectangle(cornerRadius: 4)
                .stroke(Color(.disabledControlTextColor))
                .opacity(0.5)
            )

          }
//        }
      }
    }, subContent: {
      HStack {
        Button("Reveal", action: { })
      }
      .font(.caption)
    }, onAction: {

    })
    .enableInjection()
  }
}

struct OpenCommandView_Previews: PreviewProvider {
    static var previews: some View {
      OpenCommandView(command: .constant(DesignTime.detail.commands[1]))
    }
}