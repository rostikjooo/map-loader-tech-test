//
//  SerialFileDownloader.swift
//  MapLoader
//
//  Created by Rost on 12.05.2026.
//

import Foundation

class SerialFileDownloader: NSObject {
    static let downloadingAdvancedNotification = Notification.Name("myNotification")
    
    private var session: URLSession!
    private var activeTask: URLSessionDownloadTask?
    private let fileManager = FileManager.default
    private let syncQueue = DispatchQueue(label: "com.map-loader.serial-file-downloader")
    private var fileMoveErrors: [Int: Error] = [:]
    private var currentProgress: [URL: Double] = [:]
    @Storage(key: "serialDownloaderQueueKey", fallback: []) private var queue: [URL]

    override init() {
        super.init()
        session = makeSession()
        restoreActiveTask()
    }

    func download(_ url: URL) {
        syncQueue.async { [weak self] in
            guard let self else { return }

            guard !self.queue.contains(url) else { return }

            self.queue.append(url)
            self.startNextIfNeeded()
        }
    }
    
    func cancelDownload(_ url: URL) {
        syncQueue.async { [weak self] in
            guard let self else { return }

            self.queue.removeAll { $0 == url }
            self.currentProgress.removeValue(forKey: url)

            if self.activeTask?.originalRequest?.url == url {
                self.activeTask?.cancel()
            } else {
                self.startNextIfNeeded()
            }

            self.postDownloadStateChanged()
        }
    }
    
    func isQueued(_ url: URL) -> Bool {
        syncQueue.sync {
            queue.contains(url)
        }
    }
    
    func progressFor(_ url: URL) -> Double {
        syncQueue.sync {
            currentProgress[url] ?? 0
        }
    }
    
    func isDownloaded(sourceURL url: URL) -> Bool {
        downloadedFileLocationFor(sourceURL: url) != nil
    }
    
    func downloadedFileLocationFor(sourceURL url: URL) -> URL? {
        let localURL = destinationURL(for: url)
        guard fileManager.fileExists(atPath: localURL.path) else { return nil }
        
        return localURL
    }

    private func restoreActiveTask() {
        session.getAllTasks { [weak self] tasks in
            guard let self else { return }

            self.syncQueue.async {
                guard self.activeTask == nil else { return }

                let existingTask = tasks
                    .compactMap { $0 as? URLSessionDownloadTask }
                    .first { $0.state == .running || $0.state == .suspended }

                self.activeTask = existingTask

                if existingTask?.state == .suspended {
                    existingTask?.resume()
                }
                
                self.startNextIfNeeded()
            }
        }
    }
    
    private func startNextIfNeeded() {
        guard activeTask == nil else { return }
        guard let nextURL = queue.first else { return }
            
        let task = session.downloadTask(with: nextURL)
        task.taskDescription = nextURL.absoluteString
        activeTask = task
        task.resume()
    }

    private func makeSession() -> URLSession {
        let config = URLSessionConfiguration.background(
            withIdentifier: "com.map-loader.background-downloads"
        )

        config.sessionSendsLaunchEvents = true
        config.isDiscretionary = false

        return URLSession(
            configuration: config,
            delegate: self,
            delegateQueue: nil
        )
    }

    private func removeFromQueue(_ url: URL) {
        queue.removeAll { $0 == url }
    }

    private func postDownloadStateChanged() {
        DispatchQueue.global().async {
            NotificationCenter.default.post(name: Self.downloadingAdvancedNotification, object: nil)
        }
    }

    private func destinationURL(for sourceURL: URL) -> URL {
        let appSupportURL = (try? FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )) ?? fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let downloadsDirectory = appSupportURL.appendingPathComponent("Downloads", isDirectory: true)

        try? FileManager.default.createDirectory(
            at: downloadsDirectory,
            withIntermediateDirectories: true
        )

        let filename = fileName(from: sourceURL) ?? String(sourceURL.hashValue)

        return downloadsDirectory.appendingPathComponent(filename)
    }
    
    private func fileName(from remoteURL: URL) -> String? {
        guard let components = URLComponents(
            url: remoteURL,
            resolvingAgainstBaseURL: false
        ) else {
            return nil
        }

        if let fileName = components.queryItems?
            .first(where: { $0.name == "file" })?
            .value,
           !fileName.isEmpty {
            return fileName
        }

        return nil
    }
}

extension SerialFileDownloader: URLSessionDownloadDelegate {
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        guard let sourceURL = downloadTask.originalRequest?.url else { return }

        let destinationURL = destinationURL(for: sourceURL)

        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }

            try fileManager.moveItem(at: location, to: destinationURL)
        } catch {
            syncQueue.async { [weak self] in
                self?.fileMoveErrors[downloadTask.taskIdentifier] = error
            }
        }
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        syncQueue.async { [weak self] in
            guard let self else { return }
            let sourceURL = task.originalRequest?.url
            let moveError = fileMoveErrors.removeValue(forKey: task.taskIdentifier)
            let finalError = error ?? moveError

            if let finalError {
                print("Download failed:", sourceURL as Any, finalError)
            }

            if let sourceURL {
                removeFromQueue(sourceURL)
                currentProgress.removeValue(forKey: sourceURL)
            }

            if self.activeTask?.taskIdentifier == task.taskIdentifier {
                self.activeTask = nil
            }
            
            self.postDownloadStateChanged()
            self.startNextIfNeeded()
        }
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard totalBytesExpectedToWrite > 0 else { return }
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        syncQueue.async { [weak self] in
            self?.currentProgress[sourceURL] = progress
            self?.postDownloadStateChanged()
        }
    }
}
