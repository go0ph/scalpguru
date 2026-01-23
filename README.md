# ScalpGuru V5 - Keltner Channel Trading EA

A MetaTrader 5 Expert Advisor that implements a mean reversion strategy using Keltner Channels with an improved trailing stop mechanism for maximizing profits.

## Strategy Overview

### Entry Logic
**Buy Signal:**
- Price dips below the lower Keltner band (close[2] < lower band)
- Price then reverses and closes above the lower band (close[0] > lower band)
- Opens a long position

**Sell Signal:**
- Price extends above the upper Keltner band (close[2] > upper band)
- Price then reverses and closes below the upper band (close[0] < upper band)
- Opens a short position

### Exit Logic (NEW in V5)
1. **Initial Stop Loss:** Placed at entry price ± (ATR × SL Multiplier)
2. **Trailing Stop Activation:** When trade reaches 1:1 risk-reward ratio:
   - Stop loss moves to breakeven
   - Trailing stop is activated at optimal distance based on ATR
   - Follows price upward (for buys) or downward (for sells)
3. **Profit Exit:** Trade closes when trailing stop is hit

### Key Improvements in V5
- **Simplified trade management:** Removed partial close complexity
- **Dynamic trailing stop:** Locks in profits while allowing trades to run
- **Cleaner code:** Removed unnecessary functions and complexity
- **Better risk management:** 1:1 lock-in with unlimited upside potential

## Repository Structure

```
scalpguru/
├── src/
│   └── ScalpGuruV5.mq5          # Main EA source code
├── backtests/                    # Upload backtest results here
├── report/                       # Initial backtest reports
└── docs/                         # Documentation
```

## Installation

1. Copy `src/ScalpGuruV5.mq5` to your MetaTrader 5 `MQL5/Experts/` directory
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

## Backtesting

Upload your backtest results to the `backtests/` folder with descriptive names:
- Format: `backtest_YYYY-MM-DD_symbol_timeframe.html`
- Include screenshots and HTML reports
- Document parameter changes in commit messages

## Version History

- **V5:** Improved trailing stop mechanism, simplified code
- **V4:** Keltner Channel strategy with partial close
- Previous versions: Development iterations

## License

Copyright © go0ph

## Support

For issues or questions, please open a GitHub issue.