# Backtest Results

This folder is for uploading your backtest results to track the EA's performance across different settings and market conditions.

## File Naming Convention

Use the following format for your backtest files:

```
backtest_V[VERSION]_[DATE]_[SYMBOL]_[TIMEFRAME]_[SETTINGS]_[NOTES].html
```

**Examples:**
- `backtest_V5_2024-01-23_EURUSD_M15_TSM1.0_default-settings.html`
- `backtest_V5_2024-01-23_GBPUSD_H1_TSM0.8_tight-trailing.html`
- `backtest_V5_2024-02-01_USDJPY_M30_TSM1.5_trending-market.html`

## What to Include

For each backtest, please upload:

1. **HTML Report** - Full MetaTrader 5 backtest report
2. **Screenshots** - Key charts and statistics
3. **Summary Text File** (optional) - Your observations and conclusions

## Testing Guidelines

See [`docs/CHANGELOG_V5.md`](../docs/CHANGELOG_V5.md) for detailed testing recommendations.

### Quick Checklist

- [ ] Test period: At least 3-6 months of data
- [ ] Document all parameter changes
- [ ] Include comparison with previous version (if applicable)
- [ ] Note market conditions during test period
- [ ] Record key metrics (profit, drawdown, win rate, etc.)

## Results Review

When uploading results, consider opening a GitHub issue or PR to discuss:
- Performance observations
- Suggested parameter optimizations
- Questions about behavior
- Comparison with other settings/versions

---

*Note: Keep the original V4 backtest reports in the `report/` folder for reference.*
