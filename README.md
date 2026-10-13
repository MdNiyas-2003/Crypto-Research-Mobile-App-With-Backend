# Mini Crypto

Mini Crypto is a Flutter cryptocurrency market research app backed by an
Express REST API. It includes a searchable/sortable market list, global market
statistics, coin details with historical price charts, and a device-local
watchlist.

## Project documentation

See [PROJECT_OVERVIEW.md](./PROJECT_OVERVIEW.md) for the complete project
overview, architecture and request flow, technologies, API endpoints, model
fields, setup instructions, and known limitations.

## Project folders

- `crypto_mobile_app/` — Flutter/Dart application.
- `backend/` — Node.js/Express API proxy for CoinGecko and Alternative.me.

## Quick start

Flutter app, from `crypto_mobile_app/`:

```powershell
flutter pub get
flutter run
```

Backend, from `backend/`:

```powershell
npm install
npm run dev
```

The mobile app's current API base URL is configured in
`crypto_mobile_app/lib/core/app_constants.dart`. Keep provider credentials in
the backend environment; do not put secrets in the Flutter app or documentation.
