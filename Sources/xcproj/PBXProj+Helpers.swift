import Foundation
import PathKit

// MARK: - PBXProj Extension (Getters)

extension PBXProj {
    
    /// Returns the file name from the build file reference.
    ///
    /// - Parameter reference: file reference.
    /// - Returns: build file name.
    func fileName(buildFileReference: String) -> String? {
        guard let fileRef = buildFiles.getReference(buildFileReference)?.fileRef else { return nil }
        if let variantGroup = variantGroups.getReference(fileRef) {
            return variantGroup.name
        } else if fileReferences.contains(reference: fileRef) {
            return self.fileName(fileReference: fileRef)
        }
        return nil
    }
    
    /// Returns the file name from the file reference.
    ///
    /// - Parameter fileReference: file reference.
    /// - Returns: file name.
    func fileName(fileReference: String) -> String? {
        if let fileReference = fileReferences.getReference(fileReference) {
            return fileReference.path.map({Path($0)})?.lastComponent ?? fileReference.name
        }
        return nil
    }
    
    /// Returns the build phase a file is in.
    ///
    /// - Parameter reference: reference of the file whose type will be returned.
    /// - Returns: String with the type of file.
    func buildPhaseType(buildFileReference: String) -> BuildPhase? {
        if sourcesBuildPhases.filter({$0.files.contains(buildFileReference)}).count != 0 {
            return .sources
        } else if frameworksBuildPhases.filter({$0.files.contains(buildFileReference)}).count != 0 {
            return .frameworks
        } else if resourcesBuildPhases.filter({$0.files.contains(buildFileReference)}).count != 0 {
            return .resources
        } else if copyFilesBuildPhases.filter({$0.files.contains(buildFileReference)}).count != 0 {
            return .copyFiles
        } else if headersBuildPhases.filter({$0.files.contains(buildFileReference)}).count != 0 {
            return .headers
        }
        return nil
    }
    
    /// Returns the build phase type from its reference.
    ///
    /// - Parameter reference: build phase reference.
    /// - Returns: string with the build phase type.
    func buildPhaseType(buildPhaseReference: String) -> BuildPhase? {
        if sourcesBuildPhases.contains(reference: buildPhaseReference) {
            return .sources
        } else if frameworksBuildPhases.contains(reference: buildPhaseReference) {
            return .frameworks
        } else if resourcesBuildPhases.contains(reference: buildPhaseReference) {
            return .resources
        } else if copyFilesBuildPhases.contains(reference: buildPhaseReference) {
            return .copyFiles
        } else if shellScriptBuildPhases.contains(reference: buildPhaseReference) {
            return .runScript
        } else if headersBuildPhases.contains(reference: buildPhaseReference) {
            return .headers
        }
        return nil
    }
    
    /// Get the build phase name given its reference (mostly used for comments).
    ///
    /// - Parameter buildPhaseReference: build phase reference.
    /// - Returns: the build phase name.
    func buildPhaseName(buildPhaseReference: String) -> String? {
        if sourcesBuildPhases.contains(reference: buildPhaseReference) {
            return "Sources"
        } else if frameworksBuildPhases.contains(reference: buildPhaseReference) {
            return "Frameworks"
        } else if resourcesBuildPhases.contains(reference: buildPhaseReference) {
            return "Resources"
        } else if let copyFilesBuildPhase = copyFilesBuildPhases.filter({$0.reference == buildPhaseReference}).first {
            return  copyFilesBuildPhase.name ?? "CopyFiles"
        } else if let shellScriptBuildPhase = shellScriptBuildPhases.filter({$0.reference == buildPhaseReference}).first {
            return shellScriptBuildPhase.name ?? "ShellScript"
        } else if headersBuildPhases.contains(reference: buildPhaseReference) {
            return "Headers"
        }
        return nil
    }
    
}

// MARK: - PBXProj extension (Writable)

extension PBXProj: Writable {
    
    public func write(path: Path, override: Bool) throws {
        let encoder = PBXProjEncoder()
        let output = encoder.encode(proj: self)
        if override && path.exists {
            try path.delete()
        }
        try path.write(output)
    }
    
}

// MARK: - PBXProj Extension (UUID Generation)

public extension PBXProj {
    
    /// Returns a valid UUID for new elements.
    ///
    /// - Parameter element: project element class.
    /// - Returns: UUID available to be used.
    public func generateUUID<T: PBXObject>(for element: T.Type) -> String {
        var uuid: String = ""
        var counter: UInt = 0
        let random: String = String.random()
        let className: String = String(describing: T.self).hash.description
        repeat {
            counter += 1
            uuid = String(format: "%08X%08X%08X", className, random, counter)
        } while(objects.contains(reference: uuid))
        return uuid
    }
    
}
