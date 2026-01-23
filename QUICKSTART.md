# Quick Start Guide - ScalpGuru V5

## What Changed?

**Old Strategy (V4):** Partial close at 1:1 RR, full close at 2:1 RR
**New Strategy (V5):** Move SL to breakeven at 1:1 RR, activate trailing stop, let profits run!

## Key Improvement

When your trade hits 1:1 risk-reward:
1. ✅ Stop loss moves to breakeven (zero risk)
2. ✅ Trailing stop activates
3. ✅ Position stays open to capture bigger moves
4. ✅ Exits when trailing stop is hit

## New Parameter

**`TrailingStop_ATRMultiplier`** (default: 1.0)
- Controls how far the trailing stop stays from current price
- Measured in ATR units
- Lower = tighter stop (0.5-0.8)
- Higher = looser stop (1.2-2.0)

## Installation

1. Copy `src/ScalpGuruV5.mq5` to your MT5 `MQL5/Experts/` folder
2. Compile in MetaEditor (F7)
3. Attach to chart
4. Configure parameters

## Recommended First Test

Use these settings for your first backtest:
- Symbol: EURUSD or your preferred pair
- Timeframe: M15
- Date range: Last 3-6 months
- Parameters: All defaults
- Special attention to: `TrailingStop_ATRMultiplier = 1.0`

## What to Expect

✅ **Larger average wins** - Trailing stop catches extended moves
✅ **Better profit factor** - Bigger wins offset small losses  
✅ **Higher max win** - No more capped at 2:1 RR
⚠️ **Slightly lower win rate** - Some trades may reverse after 1:1

## Testing Process

1. Run backtest with default settings
2. Document results in `backtests/` folder
3. Try different `TrailingStop_ATRMultiplier` values (0.8, 1.0, 1.2, 1.5)
4. Compare which works best for your symbol/timeframe
5. Share results!

## File Organization

```
scalpguru/
├── src/ScalpGuruV5.mq5          ← The EA code
├── backtests/                    ← Upload your results here
├── report/                       ← Original V4 reports
├── docs/CHANGELOG_V5.md         ← Full changelog
└── README.md                     ← Main documentation
```

## Need Help?

- Read: `docs/CHANGELOG_V5.md` for detailed explanation
- Check: `backtests/README.md` for testing guidelines
- Open: GitHub issue with your questions or results

## Strategy Reminder

**Entry:**
- Buy: Price dips below lower Keltner band, then closes above it
- Sell: Price extends above upper Keltner band, then closes below it

**Exit:**
- Initial SL: Entry ± (ATR × 1.4)
- At 1:1 RR: SL → Breakeven, trailing activates
- Final exit: Trailing stop hit

Happy trading! 📈
