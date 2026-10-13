# Mini Crypto — Project Overview

## 1. Purpose

Mini Crypto is a Flutter cryptocurrency market research app. It presents market
prices and statistics from external data providers, lets users find and sort
coins, keeps a locally stored watchlist, and displays coin details and
historical price charts.

The mobile app uses REST requests; it does not use a streaming/WebSocket feed.

## 2. Repository layout

```text
crypto/
├── crypto_mobile_app/       Flutter mobile application
│   ├── lib/
│   │   ├── core/            API client and app-wide constants/colors
│   │   ├── models/          Typed API/domain data models
│   │   ├── repositories/    Data access and watchlist persistence
│   │   ├── screens/         Market, Statistics, Watchlist, Coin Details
│   │   ├── services/        REST API calls
│   │   ├── viewmodels/      Provider state and screen behavior
│   │   └── widgets/         Shared cards, charts, rows, and state widgets
│   ├── test/                Flutter widget and view-model tests
│   └── pubspec.yaml         Flutter/Dart dependencies
└── backend/                 Express REST proxy for upstream providers
    ├── server.js
    ├── routes.js
    ├── coingecko.service.js
    ├── error.middleware.js
    └── package.json
```

## 3. Technologies

### Mobile app

- **Flutter / Dart** for the cross-platform UI.
- **Provider** and `ChangeNotifier` for dependency injection and MVVM-style
  state management.
- **Dio** for HTTP requests.
- **fl_chart** for interactive historical price charts.
- **intl** for currency, number, and date formatting.
- **SharedPreferences** for saving watchlist coin IDs on the device.
- **Google Fonts (Manrope)** for app typography.
- **flutter_test** and Flutter lints for widget/view-model tests and static
  analysis.

### Backend

- **Node.js** and **Express** expose the app-facing REST API.
- **Axios** calls CoinGecko and Alternative.me.
- **dotenv** loads local backend environment variables.
- CoinGecko responses are cached in memory for 30 seconds. Upstream requests
  time out after 10 seconds.
- Provider/API credentials, if required, are configured on the backend. They
  must not be embedded in the Flutter app or committed to source control.

## 4. Architecture and request flow

```text
Flutter screen/widget
        │ user action / lifecycle refresh
        ▼
Provider ViewModel (ChangeNotifier)
        │
        ▼
Repository (maps API responses to domain models)
        │
        ▼
ApiService (Dio endpoint calls)
        │
        ▼
ApiClient (base URL, timeouts, headers)
        │ HTTPS/HTTP REST
        ▼
Express backend route
        │
        ├── CoinGecko service (in-memory cache + upstream requests)
        └── Alternative.me sentiment request
```

`main.dart` constructs the API service, repositories, and app-wide view models
with `MultiProvider`. Screens watch the relevant view model; view-model changes
notify the UI. API failures are represented by screen-level error messages and
retry controls rather than invented market values.

### App flows

1. **Startup:** Providers are created, the main navigation opens on Market, and
   the watchlist IDs are loaded from device storage.
2. **Market:** The screen requests up to 100 market rows and global statistics.
   Search, category filters, period selection, sort field, and sort direction
   operate on the loaded market list. Coin selection opens Coin Details.
3. **Statistics:** Global market statistics, sentiment, and top gainers are
   requested. Top-gainer rows open Coin Details.
4. **Watchlist:** Saved IDs are loaded locally, then their current market
   prices are requested. Users can remove a coin or open its details.
5. **Coin Details:** The app requests coin market data and a price-history
   series. The range controls select 24H, 7D, 30D, or 1Y. The chart can be
   panned horizontally inside its card.
6. **Refresh:** Users can refresh manually. The main navigation also refreshes
   the selected tab every 60 seconds while the app is resumed and the main
   route is active. Coin Details refreshes details and chart every 60 seconds
   while that route is active. In-flight guards avoid duplicate requests.

## 5. Screens and user-facing features

### Market

- Market overview using global market-cap, volume, BTC dominance, and
  24-hour change data.
- Coin list with name/ticker search.
- All, Bitcoin, Ethereum, and BNB filters.
- 24H, 7D, and 30D period selection for change display/sorting.
- Sorting by price, market capitalization, volume, or selected-period change;
  ascending and descending directions are available.
- Add/remove coins from the watchlist.
- Pull-to-refresh, loading, retryable error, and no-results states.
- Header is fixed while the list scrolls; the search header compacts when the
  keyboard or a short viewport requires space.

### Statistics

- Scrollable global market overview, trading volume, BTC dominance, active
  cryptocurrency/market counts, and market-cap movement.
- Alternative.me Fear & Greed sentiment.
- Top three gainers from the fetched market rows; selecting one opens details.
- Manual and timed refresh.

### Coin Details

- Coin identity, current price, 24-hour change, rank, and daily high/low range.
- Selectable 24H, 7D, 30D, and 1Y history.
- Horizontally pannable chart with price tooltips and range-specific date ticks.
- Market statistics include market cap, 24-hour volume/high/low, rank, and
  circulating, total, and maximum supply.
- Some coins do not have total or maximum supply reported by the provider; the
  UI displays `—` when a field is absent.
- Add/remove from watchlist.

### Watchlist and appearance

- Watchlist membership is stored on-device as coin IDs. Price and other market
  data are fetched from the API, not persisted as a local quote cache.
- App-wide dark/light theme toggle is available on Market.
- Current theme choice is in-memory and resets when the app process restarts.

## 6. API endpoints and data fetched

The Flutter app calls the configured base URL in
`crypto_mobile_app/lib/core/app_constants.dart`. The current source points to
the hosted API base:

```text
https://crypto-market-research-mobile-app.onrender.com/api
```

The local backend defaults to port `3000` and mounts routes under `/api`.

| App/backend route | Upstream provider | Data/use |
|---|---|---|
| `GET /api/health` | Local backend | Health check; returns a simple status. |
| `GET /api/coins/markets` | CoinGecko `/coins/markets` | Coin list, price, market cap, volume, rank, price changes (24H/7D/30D), optional sparkline, optional requested IDs. |
| `GET /api/global` | CoinGecko `/global` | Aggregate market cap/volume, BTC dominance, active coin/market counts, 24-hour market-cap change. |
| `GET /api/coins/:id` | CoinGecko `/coins/:id` | Coin identity and detailed market data including supplies and 24-hour high/low. |
| `GET /api/coins/:id/market-chart` | CoinGecko `/coins/:id/market_chart` | Timestamped price history for the selected number of days. |
| `GET /api/simple/price` | CoinGecko `/simple/price` | Available proxy route; not the primary screen data path. |
| `GET /api/sentiment` | Alternative.me Fear & Greed API | Current sentiment score and classification. |

Market list requests currently ask for USD, up to 100 rows, market-cap
descending order, 24H/7D/30D percentage changes, and optional sparkline data.
Chart requests pass the selected period as CoinGecko `days=1`, `7`, `30`, or
`365`.

The Express error middleware responds with `429` for an upstream rate limit and
`502` for other upstream failures. CoinGecko requests are cached for 30 seconds
in backend memory; the Alternative.me sentiment route is not cached by that
CoinGecko cache.

## 7. Model classes and fields

### `Coin` — `lib/models/coin.dart`

Represents a market-list item.

| Dart field | API source | Meaning |
|---|---|---|
| `id` | `id` | Provider coin identifier used for details/watchlist requests. |
| `name` | `name` | Display name. |
| `symbol` | `symbol` | Uppercase ticker symbol. |
| `imageUrl` | `image` | Coin image URL. |
| `priceUsd` | `current_price` | Current USD price; defaults to `0` if absent. |
| `marketCapUsd` | `market_cap` | USD market capitalization; defaults to `0`. |
| `volumeUsd` | `total_volume` | USD trading volume; defaults to `0`. |
| `change24h` | `price_change_percentage_24h` or `_in_currency` fallback | 24-hour percentage movement. |
| `change7d` | `price_change_percentage_7d_in_currency` | 7-day percentage movement. |
| `change30d` | `price_change_percentage_30d_in_currency` | 30-day percentage movement. |
| `rank` | `market_cap_rank` | Market-cap rank. |
| `sparkline` | `sparkline_in_7d.price` | Optional seven-day price samples. |

`changeForPeriod()` selects the corresponding percentage for the Market
period selector.

### `CoinDetails` — `lib/models/coin_details.dart`

Represents detailed coin-market data.

| Dart field | API source |
|---|---|
| `name`, `symbol` | `name`, `symbol` |
| `imageUrl` | `image.large`, with `image.small` fallback |
| `priceUsd` | `market_data.current_price.usd` |
| `change24h` | `market_data.price_change_percentage_24h` |
| `marketCapUsd` | `market_data.market_cap.usd` |
| `volume24hUsd` | `market_data.total_volume.usd` |
| `high24hUsd`, `low24hUsd` | `market_data.high_24h.usd`, `low_24h.usd` |
| `marketCapRank` | `market_cap_rank` |
| `circulatingSupply` | `market_data.circulating_supply` |
| `totalSupply` | `market_data.total_supply` |
| `maxSupply` | `market_data.max_supply` |

All numeric detail values are nullable because the upstream provider can omit
them.

### `GlobalMarketStats` — `lib/models/global_market_stats.dart`

| Dart field | API source |
|---|---|
| `marketCapUsd` | `data.total_market_cap.usd` |
| `volumeUsd` | `data.total_volume.usd` |
| `bitcoinDominance` | `data.market_cap_percentage.btc` |
| `activeCryptocurrencies` | `data.active_cryptocurrencies` |
| `marketCapChange24h` | `data.market_cap_change_percentage_24h_usd` |
| `activeMarkets` | `data.markets` |

The parser accepts the global response either wrapped in `data` or already
unwrapped.

### Other models

- **`MarketSentiment`** (`market_sentiment.dart`): `value` (integer sentiment
  score) and `classification` (provider label from `value_classification`).
- **`ChartPoint`** (`chart_point.dart`): `timestamp` parsed from the first
  element of each CoinGecko `[timestamp, price]` pair and `price` parsed from
  the second element.

UI/view-model enums include:

- **`MarketFilter`**: all, Bitcoin, Ethereum, BNB.
- **`MarketSort`**: price, market cap, volume, change percentage.
- **`MarketPeriod`**: 24H, 7D, 30D.
- **`ChartRange`**: 24H, 7D, 30D, 1Y, mapped to CoinGecko `days` values.

## 8. State management and persistence

- `MarketViewModel` owns fetched market rows, search/filter/sort/period state,
  loading/error state, and derives a filtered/sorted list.
- `StatisticsViewModel` loads global statistics, sentiment, and top gainers in
  parallel and tracks their errors independently.
- `CoinDetailsViewModel` owns details, selected chart range, chart points, and
  separate details/chart loading and error states.
- `WatchlistViewModel` coordinates saved IDs with live market rows and handles
  add/remove/refresh.
- `ThemeViewModel` controls the shared palette.
- `WatchlistRepository` stores only coin IDs using SharedPreferences.
- API data is not an account-backed or server-synced portfolio; the watchlist is
  local to the device.

## 9. Setup and running

### Flutter app

From `crypto_mobile_app/`:

```powershell
flutter pub get
flutter run
```

To run checks and make an Android debug build:

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

### Backend

From `backend/`:

```powershell
npm install
npm run dev
```

The backend listens on port `3000` unless `PORT` is set. Put any required
CoinGecko credential in the backend's ignored `.env` file using the variable
expected by `coingecko.service.js`; never include credential values in project
documentation, client code, or commits.

The mobile app currently targets the hosted API URL in `AppConstants`. To use a
local backend, set that base URL appropriately for the target device:

- Android emulator and physical Android devices do not use the same route to a
  computer's `localhost`.
- With a USB-connected physical Android device, `127.0.0.1` works only when
  loopback/ADB port forwarding has been configured (for example,
  `adb reverse tcp:3000 tcp:3000`).
- Ensure the backend is running and reachable before diagnosing upstream data
  failures.

## 10. Known behavior and limitations

- Data is REST-based and periodically refreshed, not continuously streamed.
- Market/Statistics/Watchlist refresh is tied to the selected tab; Coin Details
  refreshes only while it is the active route. The app pauses timer refresh
  while backgrounded.
- CoinGecko availability and rate limits depend on the configured provider
  access and backend credential. The 30-second backend cache is process-local;
  it is not shared between backend instances and is lost when the server
  restarts.
- Missing provider metrics (including supply values for some assets) are shown
  as unavailable rather than inferred.
- Watchlists are device-local and are not synchronized across devices.
- Theme selection currently resets to dark on app restart.

## 11. Tests currently in the project

Tests cover API-host configuration, Market search/filter/sort behavior, theme
switching, compact state layouts, Market toolbar behavior, Market overview
presentation, narrow-device coin-stat cards, Top Gainer navigation, and
range-specific chart timelines including horizontal chart swiping.
