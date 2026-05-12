//
//  StorageInfoProvider.swift
//  MapLoader
//
//  Created by Rost on 12.05.2026.
//

import Foundation

final class StorageInfoProvider {
    struct StorageInfo: Equatable {
        let availableSpace: Measurement<UnitInformationStorage>
        let totalSpace: Measurement<UnitInformationStorage>?
    }

    enum StorageInfoError: Error {
        case missingVolumeInformation
        case invalidAvailableCapacity
    }

    private let fileManager: FileManager
    private let observedDirectoryURL: URL

    init(
        fileManager: FileManager = .default,
        observedDirectoryURL: URL? = nil
    ) {
        self.fileManager = fileManager
        self.observedDirectoryURL = observedDirectoryURL
            ?? fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    }

    func currentStorageInfo() throws -> StorageInfo {
        let values = try observedDirectoryURL.resourceValues(forKeys: [
            .volumeAvailableCapacityForImportantUsageKey,
            .volumeTotalCapacityKey
        ])

        guard let availableBytes = values.volumeAvailableCapacityForImportantUsage else {
            throw StorageInfoError.missingVolumeInformation
        }

        guard availableBytes >= 0 else {
            throw StorageInfoError.invalidAvailableCapacity
        }

        return StorageInfo(
            availableSpace: Measurement(
                value: Double(availableBytes),
                unit: UnitInformationStorage.bytes
            ),
            totalSpace: values.volumeTotalCapacity.map {
                Measurement(
                    value: Double($0),
                    unit: UnitInformationStorage.bytes
                )
            }
        )
    }

    func storageInfoStream(interval: Duration = .seconds(3)) -> AsyncStream<Result<StorageInfo, Error>> {
        AsyncStream { continuation in
            let task = Task { [weak self] in
                while !Task.isCancelled {
                    guard let self else { return }

                    do {
                        continuation.yield(.success(try self.currentStorageInfo()))
                    } catch {
                        continuation.yield(.failure(error))
                    }

                    try? await Task.sleep(for: interval)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
