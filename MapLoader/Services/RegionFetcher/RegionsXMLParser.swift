//
//  RegionsXMLParser.swift
//  MapLoader
//
//  Created by Rost on 12.05.2026.
//

import Foundation

final class RegionsXMLParser: NSObject {
    private var stack: [Region] = []
    private var rootRegions: [Region] = []
    private var parserError: Error?

    func parse(data: Data) throws -> RegionsList {
        stack.removeAll()
        rootRegions.removeAll()
        parserError = nil

        let parser = XMLParser(data: data)
        parser.delegate = self

        guard parser.parse() else {
            throw parser.parserError ?? parserError ?? RegionsXMLParserError.invalidXML
        }

        return RegionsList(regions: rootRegions)
    }
}

extension RegionsXMLParser: XMLParserDelegate {
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        guard elementName == "region" else { return }

        guard let name = attributeDict["name"] else {
            parserError = RegionsXMLParserError.missingRequiredName
            parser.abortParsing()
            return
        }

        let region = Region(
            type: attributeDict["type"].flatMap(RegionType.init(rawValue:)),
            name: name,
            translate: attributeDict["translate"],
            lang: attributeDict["lang"],
            boundary: attributeDict["boundary"].xmlBool,
            polyExtract: attributeDict["poly_extract"],
            map: attributeDict["map"].xmlBool,
            wiki: attributeDict["wiki"].xmlBool,
            roads: attributeDict["roads"].xmlBool,
            srtm: attributeDict["srtm"].xmlBool,
            hillshade: attributeDict["hillshade"].xmlBool,
            downloadPrefix: attributeDict["download_prefix"],
            downloadSuffix: attributeDict["download_suffix"],
            innerDownloadPrefix: attributeDict["inner_download_prefix"],
            innerDownloadSuffix: attributeDict["inner_download_suffix"],
            joinMapFiles: attributeDict["join_map_files"].xmlBool,
            joinRoadFiles: attributeDict["join_road_files"].xmlBool,
            leftHandNavigation: attributeDict["left_hand_navigation"].xmlBool,
            metric: attributeDict["metric"].xmlBool,
            children: []
        )

        stack.append(region)
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        guard elementName == "region" else { return }
        guard let finishedRegion = stack.popLast() else { return }

        if stack.isEmpty {
            rootRegions.append(finishedRegion)
        } else {
            stack[stack.count - 1].children.append(finishedRegion)
        }
    }
}

enum RegionsXMLParserError: Error {
    case invalidXML
    case missingRequiredName
}

private extension Optional where Wrapped == String {
    var xmlBool: Bool? {
        switch self?.lowercased() {
        case "yes", "true", "1":
            return true
        case "no", "false", "0":
            return false
        case nil:
            return nil
        default:
            return nil
        }
    }
}
