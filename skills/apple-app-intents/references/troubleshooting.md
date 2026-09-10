# Troubleshooting by failing layer

| Symptom | Inspect first | Focused repair |
|---|---|---|
| Intent missing everywhere | App target membership, App Intents extraction logs, `isDiscoverable`, package metadata | Build/install the correct app target; restore metadata inclusion |
| Works in Shortcuts, absent from Siri AI | Exact schema's supported experiences, domain group completeness, runtime eligibility | Fix the missing schema contract or describe the actual supported surface |
| Schema macro unavailable | Selected SDK, not merely deployment target | Use a compatible SDK or separate older/newer implementations |
| Macro complains about fields | Current symbol/template and required result type | Map exact fields to real services; avoid invented CRUD names |
| Entity picker empty | Default query, account readiness, real persisted records | Fix query hydration and authorized suggestions |
| Wrong same-name item | Search results, display subtitle, arbitrary `.first` choice | Preserve identity and allow disambiguation |
| Saved shortcut breaks after update | Intent identity, parameters, raw enum values, persistent IDs | Preserve old contracts or provide an explicit migration |
| App opens to the home screen | Actual route observation and cold-start loading | Connect `OpenIntent` to a route consumed by the UI |
| Index has stale/deleted records | Update/delete hooks, account changes, repair queue | Reconcile the named index with authorized storage |
| “This” resolves incorrectly | Annotation ID, visible/selected item semantics | Attach the right entity, then verify annotations through system tests |
| Mutation succeeds but user sees failure | Save succeeded before index/donation/network follow-up failed | Separate committed result from secondary repair work |
| Intent works only after opening app | UI-only dependency registration, in-memory state | Initialize real services for intent execution |
| Duplicate records after retries | Ambiguous transaction result, absent service idempotency | Clarify committed state; reuse service-level deduplication where available |
| Unit test passes, system flow fails | Extraction, serialization, process boundaries, runtime access | Add out-of-process AppIntentsTesting and manual surface checks |

Reproduce with one precise action and known record before widening scope. Preserve logs with private content redacted. Read the relevant guide in this skill and the current Apple symbol reference; do not “fix” uncertainty by disabling authentication, returning fabricated entities, or swallowing all errors.
