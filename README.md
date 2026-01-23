# ScalpGuru - Keltner Channel Trading EA

A MetaTrader 5 Expert Advisor that implements a mean reversion strategy using Keltner Channels with an improved trailing stop mechanism for maximizing profits.

## Latest Version: V6

**ScalpGuru V6** includes enhanced visuals and improved trade logic. See [CHANGELOG_V6.md](docs/CHANGELOG_V6.md) for full details.

### V6 Highlights
- **Professional Chart Display:** Full Keltner Channel bands with configurable history (100 bars default)
- **Info Panel:** Real-time status, ATR, RSI, P/L, and entry progress
- **Entry Filters:** RSI momentum filter, volume filter, session filter
- **Breakeven Buffer:** Lock in small profit when moving SL to breakeven
- **Customizable Colors:** Full color customization for all visual elements

## Strategy Overview

### Entry Logic
**Buy Signal:**
- Price dips below the lower Keltner band (close[2] < lower band)
- Price then reverses and closes above the lower band (close[0] > lower band)
- RSI not overbought (if momentum filter enabled)
- Opens a long position

**Sell Signal:**
- Price extends above the upper Keltner band (close[2] > upper band)
- Price then reverses and closes below the upper band (close[0] < upper band)
- RSI not oversold (if momentum filter enabled)
- Opens a short position

### Exit Logic
1. **Initial Stop Loss:** Placed at entry price ± (ATR × SL Multiplier)
2. **Trailing Stop Activation:** When trade reaches 1:1 risk-reward ratio:
   - Stop loss moves to breakeven + buffer (V6)
   - Trailing stop is activated at optimal distance based on ATR
   - Follows price upward (for buys) or downward (for sells)
3. **Profit Exit:** Trade closes when trailing stop is hit

## Repository Structure

```
scalpguru/
├── src/
│   ├── ScalpGuruV6.mq5          # Latest EA (recommended)
│   └── ScalpGuruV5.mq5          # Previous version
├── backtests/                    # Upload backtest results here
├── report/                       # Initial backtest reports
└── docs/                         # Documentation
    ├── CHANGELOG_V6.md           # V6 changes and features
    └── CHANGELOG_V5.md           # V5 changes
```

## Installation

1. Copy `src/ScalpGuruV6.mq5` to your MetaTrader 5 `MQL5/Experts/` directory
2. Compile the EA in MetaEditor
3. Attach to a chart and configure parameters

## Key Parameters

### Trading Configuration
- **AccountBalance:** Account balance for risk calculations (default: 6000)
- **RiskPerTradePercent:** Risk per trade as % of account (default: 1%)
- **MaxTradesPerDay:** Maximum trades per day (default: 2)

### Strategy Parameters
- **ATRPeriod:** ATR calculation period (default: 20)
- **KeltnerPeriod:** EMA period for Keltner middle line (default: 20)
- **KeltnerMultiplier:** ATR multiplier for bands (default: 2.5)
- **SL_ATRMultiplier:** Stop loss distance multiplier (default: 1.4)
- **TrailingStop_ATRMultiplier:** Trailing stop distance (default: 1.0)
- **BreakevenBuffer:** Pips added to breakeven SL (default: 0.5) - V6

### Entry Filters (V6)
- **EnableMomentumFilter:** RSI-based entry filter (default: true)
- **RSI_Oversold/RSI_Overbought:** RSI thresholds (default: 35/65)
- **EnableVolumeFilter:** Volume confirmation (default: false)
- **EnableSessionFilter:** Time-based trading (default: false)

## Backtest Results

### V5 Performance (XAUUSD M15, Jan-Dec 2025)
- **Net Profit:** $1,960.93 (~$163/month)
- **Profit Factor:** 1.62
- **Win Rate:** 59.52%
- **Total Trades:** 126
- **Max Drawdown:** 9.10%

Upload your backtest results to the `backtests/` folder.

## Version History

- **V6:** Enhanced visuals, RSI momentum filter, session filter, breakeven buffer
- **V5:** Improved trailing stop mechanism, simplified code
- **V4:** Keltner Channel strategy with partial close

## License

Copyright © go0ph

## Support

For issues or questions, please open a GitHub issue.