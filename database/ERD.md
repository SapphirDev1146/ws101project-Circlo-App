# Circlo ERD (Mermaid)

```mermaid
erDiagram
    USERS ||--o{ ITEMS : owns
    CATEGORIES ||--o{ ITEMS : classifies
    DISASTER_INCIDENTS o|--o{ ITEMS : relates_to
    USERS ||--o{ DISASTER_INCIDENTS : reports
    USERS o|--o{ DISASTER_INCIDENTS : verifies

    ITEMS ||--o{ ITEM_REQUESTS : receives
    USERS ||--o{ ITEM_REQUESTS : submits
    ITEM_REQUESTS ||--o| TRANSACTIONS : may_create
    ITEMS ||--o{ TRANSACTIONS : records
    USERS ||--o{ TRANSACTIONS : provides
    USERS ||--o{ TRANSACTIONS : receives

    DISASTER_INCIDENTS ||--o{ ASSISTANCE_REQUESTS : affects
    USERS ||--o{ ASSISTANCE_REQUESTS : submits
    USERS o|--o{ ASSISTANCE_REQUESTS : reviews
    ASSISTANCE_REQUESTS ||--o{ ASSISTANCE_NEEDS : contains
    CATEGORIES o|--o{ ASSISTANCE_NEEDS : classifies
    ASSISTANCE_REQUESTS ||--o{ DONATION_OFFERS : receives
    USERS ||--o{ DONATION_OFFERS : makes
    ITEMS o|--o{ DONATION_OFFERS : may_reference

    USERS o|--o{ ACTIVITY_LOGS : performs
```

## Relationship notes

- `users` is the central account table.
- `items` belongs to one owner and one category. An item may optionally be linked to a disaster incident.
- `item_requests` connects a member requesting an item to that item.
- `transactions` records the result of an accepted item request.
- `disaster_incidents` can have many `assistance_requests`.
- `assistance_requests` can contain many `assistance_needs` and receive many `donation_offers`.
- `activity_logs` records actions and can remain even if an account is later removed; the actor reference becomes NULL.
