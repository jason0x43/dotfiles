---
name: swift-data-dev
description: Domain knowledge about SwiftData and CloudKit; use when planning or implementing features, updates, or bug fixes that involve SwiftData or CloudKit.
---

# Apple Development Notes

Domain knowledge about Apple APIs, resources, and development processes.

## CloudKit Production Access

- Only macOS apps distributed through the App Store / TestFlight are able to connect to production CloudKit containers. AdHoc builds can only connect to sandbox containers.

## SwiftData Relationship Predicates

- **CRITICAL:** Avoid `@Query` predicates that traverse relationships (e.g., `tire.car?.uuid == id`). These can crash when the model context has pending changes.
- **Solution:** Use inverse relationships from the schema instead (e.g., `car.tires` rather than querying with `tire.car?.uuid`).
- **Why:** SwiftData queries with relationship predicates can encounter internal inconsistencies when relationships are actively modified or have unsaved changes.


