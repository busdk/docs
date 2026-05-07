# bus-api-provider-notes

`bus-api-provider-notes` exposes Bus Notes through authenticated Bus API
endpoints. It owns API contracts, pagination, request validation, access
control, and endpoint metadata while delegating business operations to
`bus-integration-notes`.

Endpoint families will cover note create/update/delete, list/show/search,
import, publish, archive, and metadata queries.
