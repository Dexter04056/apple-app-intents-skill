# Entities and search

Choose a query according to what the caller supplies and what the app can retrieve:

| Need | Candidate | Behavioral check |
|---|---|---|
| Resolve saved IDs | `EntityQuery.entities(for:)` | Return current authorized records; omit nonexistent records |
| User searches by text | `EntityStringQuery` | Match useful names; preserve ambiguity rather than picking arbitrarily |
| Suggested choices | `suggestedEntities()` | Small relevant authorized set; no unbounded remote scan |
| Structured filtering/sorting | `EntityPropertyQuery` | Respect predicates, comparators, sorting, and limits |
| Incoming typed search/value | `IntentValueQuery` | Interpret supported input and resolve appropriate existing values |
| Semantic discovery | `IndexedEntity` + Spotlight | Saved content actually enters and leaves the index |

See [EntityQuery](https://developer.apple.com/documentation/appintents/entityquery), [EntityStringQuery](https://developer.apple.com/documentation/appintents/entitystringquery), [EntityPropertyQuery](https://developer.apple.com/documentation/appintents/entitypropertyquery), and [IntentValueQuery](https://developer.apple.com/documentation/appintents/intentvaluequery). Do not describe a substring query as semantic search.

## Entity design

Represent the app's useful nouns with [AppEntity](https://developer.apple.com/documentation/appintents/appentity). Keep IDs stable; expose meaningful typed properties and relationships, not opaque JSON or only an ID/title pair when the workflow needs dates, locations, or owners. Use `AppEnum` for genuinely finite choices; give cases durable raw values and localized display names.

Distinguish persistent entities from temporary results. `TransientAppEntity` can represent ephemeral values but is not a replacement for stable identifiers in system annotations or saved references. A display name is not a primary key. Two records named “Planning” should remain distinguishable through subtitles such as folder, date, or owner.

Queries should batch database lookups, return only authorized records, and hydrate current properties. Define deterministic ordering where the UX depends on it. Handle cancellation and offline errors honestly; do not convert every failure into an empty list that pretends the account has no data.

## Index lifecycle

Apple's [Spotlight integration guide](https://developer.apple.com/documentation/appintents/making-app-entities-available-in-spotlight) describes direct entity indexing, property indexing keys, existing-item association, and named indexes. Build an explicit lifecycle:

| Event | Required application behavior |
|---|---|
| Record created | Save successfully, then submit its entity |
| Indexed property changes | Re-submit the same persistent ID |
| Record deleted | Remove its indexed entity |
| Logout/access revocation | Remove no-longer-accessible indexed content |
| Partial indexing failure | Retain repair work; retry without repeating the business mutation |
| Reindex requested | Rebuild authorized records, bounded for large stores |

For direct entity indexing, consult [IndexedEntityQuery](https://developer.apple.com/documentation/appintents/indexedentityquery) for reindex callbacks on supported SDKs. Existing Core Spotlight item integrations can use their existing delegate path. Check current deletion APIs and identifier mapping; raw app IDs are not automatically equivalent to every Core Spotlight identifier format.

Index only content the product intends to expose. Review sensitive text, attachments, archived items, and account transitions. Test deletion and sign-out using search results, not only database assertions. Indexing may be asynchronous; use bounded eventual assertions instead of a long arbitrary sleep.

## Large and remote catalogs

Index a useful local subset where appropriate and support queries for remote or frequently changing records. A schema's typed search input may carry more than a search string; inspect its variants instead of discarding structured criteria. If the app owns a search screen, inspect the current [System and in-app search domain](https://developer.apple.com/documentation/appintents/app-schema-domain-system-and-in-app-search). Opening that screen does not by itself expose all results as Siri entities.
