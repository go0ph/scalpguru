# ScalpGuru V5 - Changelog and Testing Guide

## Major Changes from V4 to V5

### Strategy Improvements

#### 1. Trailing Stop Implementation
**Old Behavior (V4):**
- Partial close at 1:1 risk-reward ratio (closes 100% by default)
- Fixed exit at 2:1 risk-reward ratio
- Limited profit potential due to fixed targets

**New Behavior (V5):**
- At 1:1 risk-reward ratio:
  - Stop loss moves to breakeven (entry price)
  - Trailing stop activates
  - Position remains open to capture extended moves
- Trailing stop distance: `TrailingStop_ATRMultiplier × ATR` (default: 1.0 × ATR)
- Stop loss only moves in favorable direction (up for buys, down for sells)
- Exit occurs when price hits the trailing stop

**Benefits:**
- Locks in profits at 1:1 RR while allowing unlimited upside
- Adapts to market volatility through ATR-based distance
- Captures trends that go beyond fixed 2:1 targets
- Reduces premature exits during strong moves

### Code Simplifications

#### 2. Removed Unused Complexity
- **Removed Functions:**
  - `CalculateTradeProgress()` - Progress logging
  - `CountOpenPositions()` - Redundant position counting
  - `GetTrendVelocity()` - Unused prediction function
  - `GetATR()`, `GetMA()`, `GetClose()` - Unused wrappers
  - `iKeltnerUpper()`, `iKeltnerLower()` - Unused wrappers

- **Simplified Logic:**
  - Removed `predictedPrice` variable (was always equal to `currentPrice`)
  - Streamlined entry condition checks
  - Cleaner trade management flow

#### 3. Code Quality Improvements
- More readable and maintainable code
- Reduced lines of code by ~200 lines
- Clearer function purposes
- Better comments and structure

## New Parameter

### TrailingStop_ATRMultiplier
- **Type:** double
- **Default:** 1.0
- **Description:** Multiplier for ATR to calculate trailing stop distance
- **Range:** 0.5 - 3.0 recommended
  - Lower values (0.5-0.8): Tighter stops, lock profits sooner, may exit early
  - Medium values (0.8-1.2): Balanced approach, good for most markets
  - Higher values (1.2-3.0): Looser stops, hold longer, may give back more profit

## Backtesting Recommendations

### Test Scenarios

1. **Baseline Test**
   - Use default parameters from V4
   - Compare V5 results with V4 results
   - Same symbol, timeframe, and date range

2. **Trailing Stop Optimization**
   - Test `TrailingStop_ATRMultiplier` values: 0.5, 0.8, 1.0, 1.2, 1.5, 2.0
   - Document which value performs best for your symbol/timeframe
   - Consider different market conditions (trending vs ranging)

3. **Time Frame Comparison**
   - Test on M15, M30, H1, H4
   - Document optimal settings per timeframe

### Metrics to Track

1. **Profitability Metrics**
   - Net profit
   - Profit factor
   - Return on account (%)
   - Average win vs average loss

2. **Trade Statistics**
   - Total trades
   - Win rate (%)
   - Average trade duration
   - Largest winning/losing trade

3. **Risk Metrics**
   - Maximum drawdown
   - Recovery factor
   - Sharpe ratio (if available)
   - Consecutive losses

4. **V5-Specific Metrics**
   - Average profit beyond 1:1 RR
   - Percentage of trades that exceed 2:1 RR
   - Average trailing stop hits above breakeven

### Backtest File Organization

Save your backtest results in the `backtests/` folder with this naming convention:

```
backtest_V5_[DATE]_[SYMBOL]_[TIMEFRAME]_TSM[VALUE]_[NOTES].html
```

**Examples:**
- `backtest_V5_2024-01-15_EURUSD_M15_TSM1.0_default.html`
- `backtest_V5_2024-01-15_EURUSD_M15_TSM0.8_tight-stop.html`
- `backtest_V5_2024-01-15_EURUSD_M15_TSM1.5_loose-stop.html`

Include screenshots:
- Equity curve
- Trade history
- Key statistics

## Expected Improvements

Based on the strategy changes, you should expect:

1. **Higher Average Win**: Trailing stops allow winning trades to run longer
2. **Slightly Lower Win Rate**: Some trades may hit trailing stop after 1:1 instead of guaranteed 1:1 exit
3. **Better Risk/Reward Ratio**: Capturing moves beyond 2:1 RR
4. **Reduced Premature Exits**: Won't exit at 2:1 if trend continues
5. **Improved Profit Factor**: Larger wins should outweigh any additional small losses

## Comparison Template

Use this template when comparing V4 vs V5:

```
### Backtest Comparison: V4 vs V5

**Test Period:** [START DATE] to [END DATE]
**Symbol:** [e.g., EURUSD]
**Timeframe:** [e.g., M15]
**Initial Balance:** $6000

| Metric | V4 | V5 | Change |
|--------|----|----|--------|
| Net Profit | $XXX | $XXX | +X% |
| Total Trades | XXX | XXX | XX |
| Win Rate | XX% | XX% | +/-X% |
| Profit Factor | X.XX | X.XX | +/-X% |
| Max Drawdown | $XXX | $XXX | +/-X% |
| Average Win | $XX | $XX | +/-X% |
| Average Loss | $XX | $XX | +/-X% |
| Largest Win | $XXX | $XXX | +/-X% |

**V5 Settings:**
- TrailingStop_ATRMultiplier: [VALUE]

**Observations:**
- [Your notes here]

**Conclusion:**
- [Which version performed better and why]
```

## Next Steps

1. Install V5 EA in MetaTrader 5
2. Run initial backtest with default parameters
3. Compare with V4 results (if available)
4. Optimize `TrailingStop_ATRMultiplier` for your trading instrument
5. Forward test on demo account
6. Share results by uploading to `backtests/` folder
7. Open a PR with findings and any suggested parameter adjustments

## Questions or Issues?

- Open a GitHub issue with your backtest results
- Include all relevant details (symbol, timeframe, parameters, date range)
- Attach backtest reports and screenshots
