//
//  MultiAppActivationDemoApp.swift
//  MultiAppActivationDemo
//
//  Created by Art Lasovsky on 08/02/2024.
//

import SwiftUI

/// Empty App without any windows
@main
struct MultiAppActivationDemoApp: App {
    @NSApplicationDelegateAdaptor private var delegate: MultiAppDelegate
    
    var body: some Scene {
        Settings {
            Text("Settings")
        }
    }
}

// MARK: - App Delegate

class MultiAppDelegate: NSObject, NSApplicationDelegate {
    private var launcher = MultiAppWindow("Launcher", id: "Launcher", content: {
        VStack {
            Text("Launcher")
                .onTapGesture {
                    print(NSApp.windows)
                }
        }
        .frame(width: 200, height: 200)
    })
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.prohibited)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        showLauncher()
    }
}

extension MultiAppDelegate {
    func showLauncher() {
        launcher.makeKeyAndOrderFront(self)
    }
    func applicationDidBecomeActive(_ notification: Notification) {
        showLauncher()
    }
    func applicationShouldHandleReopen(_ app: NSApplication, hasVisibleWindows: Bool) -> Bool {
        showLauncher()
        return true
    }
}

// MARK: - Window

class MultiAppWindow: NSPanel {
    init(_ title: String?, id: String, @ViewBuilder content: () -> some View) {
        let styleMask: StyleMask = [.closable, .titled, .nonactivatingPanel]
        super.init(contentRect: .zero, styleMask: styleMask, backing: .buffered, defer: true)
        identifier = .init(id)
        if let title {
            self.title = title
        }
        level = .modalPanel // make it appear over other apps windows
        isReleasedWhenClosed = false
        contentView = NSHostingView(rootView: content())
        center()
    }
    
    override func becomeKey() {
        Task { @MainActor in
            NSApp.activate()
        }
        super.becomeKey()
    }
    
    override func resignKey() {
        close()
    }
    
    override func cancelOperation(_ sender: Any?) {
        close()
    }
    
    override func close() {
        super.close()
        NSApp.hide(self)
    }
}
