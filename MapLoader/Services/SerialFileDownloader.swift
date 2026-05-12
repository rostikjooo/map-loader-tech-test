//
//  SerialFileDownloader.swift
//  MapLoader
//
//  Created by Rost on 12.05.2026.
//

import Foundation

class SerialFileDownloader: NSObject {
    private var session: URLSession!
    private var activeTask: URLSessionDownloadTask?
    private let fileManager = FileManager.default
    private let syncQueue = DispatchQueue(label: "com.map-loader.serial-file-downloader")
    private var fileMoveErrors: [Int: Error] = [:]

    var onProgress: ((URL, Double) -> Void)?
    var didFinish: ((URL, Error?) -> Void)?

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
    
    func downloadedFileLocationFor(sourceURL url: URL) -> URL? {
        let localURL = destinationURL(for: url)
        guard fileManager.fileExists(atPath: localURL.path()) else { return nil }
        
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

    private func destinationURL(for sourceURL: URL) -> URL {
        let cachesDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let downloadsDirectory = cachesDirectory.appendingPathComponent("Downloads", isDirectory: true)

        if !fileManager.fileExists(atPath: downloadsDirectory.path) {
            try? fileManager.createDirectory(
                at: downloadsDirectory,
                withIntermediateDirectories: true
            )
        }

        let filename = sourceURL.lastPathComponent.isEmpty
            ? UUID().uuidString
            : sourceURL.lastPathComponent

        return downloadsDirectory.appendingPathComponent(filename)
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
            guard let sourceURL = task.originalRequest?.url else { return }
            
            let moveError = fileMoveErrors.removeValue(forKey: task.taskIdentifier)
            let finalError = error ?? moveError

            if let finalError {
                print("Download failed:", sourceURL, finalError)
            } else {
                removeFromQueue(sourceURL)
            }

            self.removeFromQueue(sourceURL)

            if self.activeTask?.taskIdentifier == task.taskIdentifier {
                self.activeTask = nil
            }
            
            didFinish?(sourceURL, error)
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

        DispatchQueue.main.async { [weak self] in
            self?.onProgress?(sourceURL, progress)
        }
    }
}
