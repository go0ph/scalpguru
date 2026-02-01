#property strict
#property description "ScalpGuru V10 - Buy-Only Higher High TP Edition"
#property description "Enhanced profit-taking strategy: TP at last major HH, partial at halfway to TP"
#property version   "10.00"
#property copyright "Created by go0ph"

#include <Trade\Trade.mqh>
CTrade trade;

//+------------------------------------------------------------------+
//| Input Parameters                                                  |
//+------------------------------------------------------------------+
//--- Trading Configuration
input group "=== Trading Configuration ==="
input int MagicNumber = 15140;              
input double AccountBalance = 6000.0;       
input double RiskPerTradePercent = 1.0;     
input bool EnableRiskPerTrade = true;       
input double ManualLotSize = 0.01;          
input double MaxLossPercent = 1;            
input int MaxTradesPerDay = 4;              
input bool EnableMaxTradesPerDay = true;    

//--- Funded Account Protection
input group "=== Funded Account Protection ==="
input bool EnableFundedMode = true;          
input double DailyLossLimitPercent = 2.5;    
input double MaxDrawdownPercent = 5.5;       
input double ProfitTargetPercent = 10.0;     

//--- Strategy Parameters
input group "=== Strategy Parameters ==="
input int ATRPeriod = 133;                    // ATR period (optimized for backtest)
input int KeltnerPeriod = 64;                // Keltner EMA period (optimized)
input double KeltnerMultiplier = 3.75;       // Keltner band width (wider = more extreme entries)
input double SL_ATRMultiplier = 7.54;        // ⚠️ VERY WIDE SL - High capital requirement!
input double BreakevenBuffer = 2.46;         // Breakeven buffer in pips         

//--- Profit Taking Parameters
input group "=== Profit Taking ==="
input bool EnablePartialProfit = true;       
input double PartialProfitPercent = 50.0;    

//--- HH Swing High detection parameters
input group "=== HH Swing High TP Setting ==="
input int SwingLookback = 319;       // How far back (bars) to search for HH
input int SwingWindow = 58;           // Width (bars on each side) for swing high

//--- Entry Filters
input group "=== Entry Filters ==="
input bool EnableMomentumFilter = true;     
input int RSIPeriod = 128;                   // RSI calculation period
input int RSI_Oversold = 53;                // RSI oversold threshold for buys
input int RSI_Overbought = 645;              // ⚠️ EFFECTIVELY DISABLED (>100) - RSI filter bypassed
input bool EnableVolumeFilter = false;      
input double VolumeMultiplier = 1.2;        
input bool EnableCandleConfirmation = true; 

//--- V10: Data-Driven Enhancements
input group "=== V10 Data-Driven Features ==="
input bool EnableVolatilityAdjustedRisk = true;   
input double VolLowRiskMultiplier = 6.36;          // ⚠️ EXTREME - Optimized for backtest! Use 1.2 for live
input double VolHighRiskMultiplier = 7.28;         // ⚠️ EXTREME - Optimized for backtest! Use 0.8 for live
input bool EnableVolatilityAdjustedStops = true;  
input double HighVolStopMultiplier = 2.7;          // SL multiplier in high volatility         

//--- Session Filter
input group "=== Session Filter ==="
input bool EnableSessionFilter = false;     
input int SessionStartHour = 8;             
input int SessionEndHour = 20;             

//--- Day Filtering
input group "=== Day Filtering ==="
input bool EnableDaySkip = true;           
input bool SkipMonday = false;              
input bool SkipTuesday = false;             
input bool SkipWednesday = false;           
input bool SkipThursday = false;            
input bool SkipFriday = true;               

//--- Month Filtering
input group "=== Month Filtering ==="
input bool EnableMonthSkip = false;         
input bool SkipJanuary = false;             
input bool SkipFebruary = false;            
input bool SkipMarch = false;               
input bool SkipApril = false;               
input bool SkipMay = false;                 
input bool SkipJune = false;                
input bool SkipJuly = false;                
input bool SkipAugust = false;              
input bool SkipSeptember = false;           
input bool SkipOctober = false;             
input bool SkipNovember = false;            
input bool SkipDecember = false;            

//--- Visual Settings
input group "=== Visual Settings ==="
input bool ShowKeltnerOnChart = true;       
input bool ShowInfoPanel = true;            
input bool ShowTradeArrows = true;          

input color KeltnerUpperColor = clrCrimson;       
input color KeltnerMiddleColor = clrDodgerBlue;   
input color KeltnerLowerColor = clrLimeGreen;     
input color KeltnerFillColor = clrLavender;       
input color PanelBackgroundColor = clrBlack;      
input color PanelTextColor = clrWhite;            
input color PanelProfitColor = clrLime;           
input color PanelLossColor = clrRed;              
input color BuyArrowColor = clrLime;              
input int KeltnerBarsToShow = 100;                

//--- Global Variables
double atrValue, keltnerUpper, keltnerLower, keltnerMid;
bool inTrade = false;
ENUM_TIMEFRAMES timeframe;
int atrHandle, maHandle, rsiHandle;
double atrBuffer[], maBuffer[], closeBuffer[], rsiBuffer[], highBuffer[], lowBuffer[], openBuffer[];
int tradesToday = 0;
datetime lastTradeDay = 0;
double entryPrice = 0;
double initialSL = 0;
datetime lastBarTime = 0;  
bool partialProfitTaken = false;  
double originalLotSize = 0;       
double currentTakeProfit = 0;     // Store per-position TP

// Funded Account Protection Variables
double dailyStartBalance = 0;     
double overallStartBalance = 0;   
double dailyPnL = 0;              
bool dailyLimitHit = false;       
bool drawdownLimitHit = false;    
bool profitTargetReached = false; 

// Constants
#define PIPS_TO_POINTS 10
#define CANDLE_WICK_RATIO 0.6    
#define CANDLE_BODY_RATIO 0.4    

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   timeframe = Period();
   trade.SetExpertMagicNumber(MagicNumber);
   
   // ⚠️ V10 PARAMETER WARNINGS
   if(SL_ATRMultiplier > 3.0)
   {
      Print("[WARNING] V10: Stop loss multiplier ", SL_ATRMultiplier, "x is very wide!");
      Print("[WARNING] This requires significant capital per trade. Test on demo first!");
   }
   if(VolLowRiskMultiplier > 2.0 || VolHighRiskMultiplier > 2.0)
   {
      Print("[WARNING] V10: Risk multipliers are extremely aggressive!");
      Print("[WARNING] Low vol: ", VolLowRiskMultiplier, "x, High vol: ", VolHighRiskMultiplier, "x");
      Print("[WARNING] These are optimized for backtest. Consider using V9 values (0.8-1.2x) for live trading!");
   }
   if(RSI_Overbought > 100)
   {
      Print("[INFO] V10: RSI overbought filter effectively disabled (", RSI_Overbought, " > 100)");
   }
   
   atrHandle = iATR(_Symbol, timeframe, ATRPeriod);
   if(atrHandle == INVALID_HANDLE) return INIT_FAILED;
   
   maHandle = iMA(_Symbol, timeframe, KeltnerPeriod, 0, MODE_EMA, PRICE_CLOSE);
   if(maHandle == INVALID_HANDLE)
   {
      IndicatorRelease(atrHandle);
      return INIT_FAILED;
   }
   
   // RSI
   if(EnableMomentumFilter)
   {
      rsiHandle = iRSI(_Symbol, timeframe, RSIPeriod, PRICE_CLOSE);
      if(rsiHandle == INVALID_HANDLE)
      {
         IndicatorRelease(atrHandle); IndicatorRelease(maHandle);
         return INIT_FAILED;
      }
      ArraySetAsSeries(rsiBuffer, true);
   }
   
   ArraySetAsSeries(atrBuffer, true);
   ArraySetAsSeries(maBuffer, true);
   ArraySetAsSeries(closeBuffer, true);
   ArraySetAsSeries(highBuffer, true);  
   ArraySetAsSeries(lowBuffer, true);   
   ArraySetAsSeries(openBuffer, true);  

   if(ATRPeriod <= 0 || KeltnerPeriod <= 0) return INIT_PARAMETERS_INCORRECT;
   if(SL_ATRMultiplier <= 0 || KeltnerMultiplier <= 0) return INIT_PARAMETERS_INCORRECT;
   if(ManualLotSize <= 0) return INIT_PARAMETERS_INCORRECT;
   if(MaxLossPercent <= 0 || MaxLossPercent > 100) return INIT_PARAMETERS_INCORRECT;
   if(RiskPerTradePercent <= 0 || RiskPerTradePercent > 100) return INIT_PARAMETERS_INCORRECT;

   if(EnableFundedMode)
   {
      if(DailyLossLimitPercent <= 0 || DailyLossLimitPercent > 100) return INIT_PARAMETERS_INCORRECT;
      if(MaxDrawdownPercent <= 0 || MaxDrawdownPercent > 100) return INIT_PARAMETERS_INCORRECT;
      if(ProfitTargetPercent <= 0) return INIT_PARAMETERS_INCORRECT;
   }
   if(EnablePartialProfit)
   {
      if(PartialProfitPercent <= 0 || PartialProfitPercent > 100) return INIT_PARAMETERS_INCORRECT;
   }
   if(MaxTradesPerDay <= 0) return INIT_PARAMETERS_INCORRECT;
   
   MqlDateTime dt;
   TimeToStruct(TimeTradeServer(), dt);
   dt.hour = 0; dt.min = 0; dt.sec = 0;
   lastTradeDay = StructToTime(dt);

   if(EnableFundedMode)
   {
      overallStartBalance = AccountBalance;
      dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      dailyPnL = 0; dailyLimitHit = false; drawdownLimitHit = false; profitTargetReached = false;
   }
   
   // Create info panel
   if(ShowInfoPanel)
   {
      CreateInfoPanel();
   }
   
   Print("[INIT] ScalpGuru V10 Started - Buy-Only Higher High TP Edition");
   Print("[INIT] Timeframe: ", EnumToString(timeframe));
   Print("[INIT] ATR Period: ", ATRPeriod, ", Keltner Period: ", KeltnerPeriod);
   Print("[INIT] SwingLookback: ", SwingLookback, ", SwingWindow: ", SwingWindow);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Deinit                                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, "KC_");
   ObjectsDeleteAll(0, "SG_");
   IndicatorRelease(atrHandle);
   IndicatorRelease(maHandle);
   if(EnableMomentumFilter && rsiHandle != INVALID_HANDLE)
      IndicatorRelease(rsiHandle);
   
   Print("[DEINIT] ScalpGuru V10 Stopped, Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Create Info Panel on Chart                                        |
//+------------------------------------------------------------------+
void CreateInfoPanel()
{
   int panelX = 10;
   int panelY = 30;
   int panelWidth = 240;
   int panelHeight = 260;
   
   // Create background rectangle
   if(!ObjectCreate(0, "SG_PanelBG", OBJ_RECTANGLE_LABEL, 0, 0, 0))
   {
      ObjectDelete(0, "SG_PanelBG");
      ObjectCreate(0, "SG_PanelBG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   }
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_XDISTANCE, panelX);
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_YDISTANCE, panelY);
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_XSIZE, panelWidth);
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_YSIZE, panelHeight);
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_BGCOLOR, PanelBackgroundColor);
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_COLOR, clrDodgerBlue);
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_BACK, false);
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_SELECTABLE, false);
   
   // Create title
   CreateLabel("SG_Title", "═══ ScalpGuru V10 ═══", panelX + 20, panelY + 10, clrGold, 10, "Arial Bold");
   
   // Create status labels
   CreateLabel("SG_Status", "Status: Scanning", panelX + 10, panelY + 35, PanelTextColor, 9, "Arial");
   CreateLabel("SG_Symbol", "Symbol: " + _Symbol, panelX + 10, panelY + 55, PanelTextColor, 9, "Arial");
   CreateLabel("SG_TF", "Timeframe: " + EnumToString(Period()), panelX + 10, panelY + 75, PanelTextColor, 9, "Arial");
   CreateLabel("SG_ATR", "ATR: --", panelX + 10, panelY + 95, clrCyan, 9, "Arial");
   CreateLabel("SG_RSI", "RSI: --", panelX + 10, panelY + 115, clrCyan, 9, "Arial");
   CreateLabel("SG_Trades", "Trades Today: 0/" + IntegerToString(MaxTradesPerDay), panelX + 10, panelY + 135, PanelTextColor, 9, "Arial");
   CreateLabel("SG_PnL", "Floating P/L: $0.00", panelX + 10, panelY + 155, PanelTextColor, 9, "Arial");
   CreateLabel("SG_Progress", "Entry Progress: 0%", panelX + 10, panelY + 175, clrYellow, 9, "Arial");
   CreateLabel("SG_VolRegime", "Vol: Normal", panelX + 10, panelY + 195, clrCyan, 9, "Arial");
   CreateLabel("SG_RiskAdj", "Risk: 1.0x", panelX + 10, panelY + 215, clrCyan, 9, "Arial");
   CreateLabel("SG_TPType", "TP: HH Swing", panelX + 10, panelY + 235, clrGold, 9, "Arial");  // V10 NEW
}

//+------------------------------------------------------------------+
//| Create Label Helper Function                                      |
//+------------------------------------------------------------------+
void CreateLabel(string name, string text, int x, int y, color clr, int fontSize, string fontName)
{
   if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
   {
      ObjectDelete(0, name);
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   }
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, fontName);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Update Info Panel                                                 |
//+------------------------------------------------------------------+
void UpdateInfoPanel()
{
   if(!ShowInfoPanel) return;
   
   // Update status
   string status = inTrade ? "In Trade" : "Scanning";
   if(partialProfitTaken) status = "Partial Taken";
   ObjectSetString(0, "SG_Status", OBJPROP_TEXT, "Status: " + status);
   ObjectSetInteger(0, "SG_Status", OBJPROP_COLOR, inTrade ? clrLime : clrYellow);
   
   // Update ATR
   ObjectSetString(0, "SG_ATR", OBJPROP_TEXT, "ATR: " + DoubleToString(atrValue, _Digits));
   
   // Update RSI if enabled
   if(EnableMomentumFilter && ArraySize(rsiBuffer) > 0)
   {
      double rsi = rsiBuffer[0];
      string rsiText = "RSI: " + DoubleToString(rsi, 1);
      ObjectSetString(0, "SG_RSI", OBJPROP_TEXT, rsiText);
      color rsiColor = clrCyan;
      if(rsi < RSI_Oversold) rsiColor = clrLime;
      else if(rsi > RSI_Overbought) rsiColor = clrRed;
      ObjectSetInteger(0, "SG_RSI", OBJPROP_COLOR, rsiColor);
   }
   else
   {
      ObjectSetString(0, "SG_RSI", OBJPROP_TEXT, "RSI: N/A");
   }
   
   // Update trades count
   ObjectSetString(0, "SG_Trades", OBJPROP_TEXT, "Trades Today: " + IntegerToString(tradesToday) + "/" + IntegerToString(MaxTradesPerDay));
   
   // Update floating P/L
   double floatingPnL = GetFloatingPnL();
   string pnlText = "Floating P/L: $" + DoubleToString(floatingPnL, 2);
   ObjectSetString(0, "SG_PnL", OBJPROP_TEXT, pnlText);
   ObjectSetInteger(0, "SG_PnL", OBJPROP_COLOR, floatingPnL >= 0 ? PanelProfitColor : PanelLossColor);
   
   // Update entry progress
   double progress = CalculateTradeProgress();
   ObjectSetString(0, "SG_Progress", OBJPROP_TEXT, "Entry Progress: " + DoubleToString(progress, 0) + "%");
   color progressColor = clrYellow;
   if(progress >= 90) progressColor = clrLime;
   else if(progress >= 50) progressColor = clrOrange;
   ObjectSetInteger(0, "SG_Progress", OBJPROP_COLOR, progressColor);
   
   // V10: Update volatility regime display
   string volRegime = "Normal";
   color volColor = clrCyan;
   if(atrValue < 5.58)
   {
      volRegime = "Low";
      volColor = clrLime;
   }
   else if(atrValue > 14.74)
   {
      volRegime = "High";
      volColor = clrOrange;
   }
   ObjectSetString(0, "SG_VolRegime", OBJPROP_TEXT, "Vol: " + volRegime + " ($" + DoubleToString(atrValue, 2) + ")");
   ObjectSetInteger(0, "SG_VolRegime", OBJPROP_COLOR, volColor);
   
   // V10: Update risk multiplier display
   double riskMult = GetVolatilityMultiplier();
   ObjectSetString(0, "SG_RiskAdj", OBJPROP_TEXT, "Risk: " + DoubleToString(riskMult, 1) + "x");
   color riskColor = clrCyan;
   if(riskMult > 1.0) riskColor = clrLime;
   else if(riskMult < 1.0) riskColor = clrOrange;
   ObjectSetInteger(0, "SG_RiskAdj", OBJPROP_COLOR, riskColor);
}

//+------------------------------------------------------------------+
//| Get Floating P/L for all positions                                |
//+------------------------------------------------------------------+
double GetFloatingPnL()
{
   double pnl = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber)
      {
         pnl += PositionGetDouble(POSITION_PROFIT);
      }
   }
   return pnl;
}

//+------------------------------------------------------------------+
//| Calculate Trade Progress Percentage                                |
//+------------------------------------------------------------------+
double CalculateTradeProgress()
{
   if(inTrade) return 100.0;
   
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double progress = 0.0;
   
   // Buy trade progress: 0% at keltnerMid, 100% when entry triggers
   if(currentPrice <= keltnerMid)
   {
      double distanceToLower = MathMax(keltnerMid - currentPrice, 0);
      double totalDistance = MathMax(keltnerMid - keltnerLower, 0.01);
      if(totalDistance > 0)
      {
         progress = MathMin((distanceToLower / totalDistance) * 90.0, 90.0);
         if(ArraySize(closeBuffer) > 2 && closeBuffer[2] < keltnerLower)
         {
            progress = MathMin(progress + 9.0, 99.0);
         }
      }
   }
   
   return progress;
}

//+------------------------------------------------------------------+
//| Draw Keltner Channels on Chart - Enhanced Visuals                 |
//+------------------------------------------------------------------+
void DrawKeltnerChannels()
{
   if(!ShowKeltnerOnChart) return;
   
   // Only redraw channel when a new bar forms to improve performance
   datetime currentBarTime = iTime(_Symbol, timeframe, 0);
   bool isNewBar = (currentBarTime != lastBarTime);
   
   if(isNewBar)
   {
      lastBarTime = currentBarTime;
      
      int barsToShow = KeltnerBarsToShow;
      datetime times[];
      
      ArraySetAsSeries(times, true);
      CopyTime(_Symbol, timeframe, 0, barsToShow, times);
      
      // Create arrays for channel values
      double upperBand[], middleBand[], lowerBand[];
      double tempATR[], tempMA[];
      ArrayResize(upperBand, barsToShow);
      ArrayResize(middleBand, barsToShow);
      ArrayResize(lowerBand, barsToShow);
      
      // Get historical ATR and MA values
      CopyBuffer(atrHandle, 0, 0, barsToShow, tempATR);
      CopyBuffer(maHandle, 0, 0, barsToShow, tempMA);
      ArraySetAsSeries(tempATR, true);
      ArraySetAsSeries(tempMA, true);
      
      // Calculate channel values for each bar
      for(int i = 0; i < barsToShow; i++)
      {
         middleBand[i] = tempMA[i];
         upperBand[i] = tempMA[i] + KeltnerMultiplier * tempATR[i];
         lowerBand[i] = tempMA[i] - KeltnerMultiplier * tempATR[i];
      }
      
      // Draw or update upper band segments
      for(int i = 0; i < barsToShow - 1; i++)
      {
         string objName = "KC_U" + IntegerToString(i);
         if(ObjectFind(0, objName) < 0)
         {
            ObjectCreate(0, objName, OBJ_TREND, 0, times[i+1], upperBand[i+1], times[i], upperBand[i]);
            ObjectSetInteger(0, objName, OBJPROP_COLOR, KeltnerUpperColor);
            ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);
            ObjectSetInteger(0, objName, OBJPROP_RAY, false);
            ObjectSetInteger(0, objName, OBJPROP_BACK, true);
         }
         else
         {
            ObjectMove(0, objName, 0, times[i+1], upperBand[i+1]);
            ObjectMove(0, objName, 1, times[i], upperBand[i]);
         }
      }
      
      // Draw or update middle band segments
      for(int i = 0; i < barsToShow - 1; i++)
      {
         string objName = "KC_M" + IntegerToString(i);
         if(ObjectFind(0, objName) < 0)
         {
            ObjectCreate(0, objName, OBJ_TREND, 0, times[i+1], middleBand[i+1], times[i], middleBand[i]);
            ObjectSetInteger(0, objName, OBJPROP_COLOR, KeltnerMiddleColor);
            ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_DOT);
            ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
            ObjectSetInteger(0, objName, OBJPROP_RAY, false);
            ObjectSetInteger(0, objName, OBJPROP_BACK, true);
         }
         else
         {
            ObjectMove(0, objName, 0, times[i+1], middleBand[i+1]);
            ObjectMove(0, objName, 1, times[i], middleBand[i]);
         }
      }
      
      // Draw or update lower band segments
      for(int i = 0; i < barsToShow - 1; i++)
      {
         string objName = "KC_L" + IntegerToString(i);
         if(ObjectFind(0, objName) < 0)
         {
            ObjectCreate(0, objName, OBJ_TREND, 0, times[i+1], lowerBand[i+1], times[i], lowerBand[i]);
            ObjectSetInteger(0, objName, OBJPROP_COLOR, KeltnerLowerColor);
            ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);
            ObjectSetInteger(0, objName, OBJPROP_RAY, false);
            ObjectSetInteger(0, objName, OBJPROP_BACK, true);
         }
         else
         {
            ObjectMove(0, objName, 0, times[i+1], lowerBand[i+1]);
            ObjectMove(0, objName, 1, times[i], lowerBand[i]);
         }
      }
   }
   
   // Always update current price level indicator (lightweight operation)
   double currentBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   string priceLabel = "KC_PriceLevel";
   if(ObjectFind(0, priceLabel) < 0)
   {
      ObjectCreate(0, priceLabel, OBJ_HLINE, 0, 0, currentBid);
      ObjectSetInteger(0, priceLabel, OBJPROP_COLOR, clrGray);
      ObjectSetInteger(0, priceLabel, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, priceLabel, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, priceLabel, OBJPROP_BACK, true);
   }
   else
   {
      ObjectSetDouble(0, priceLabel, OBJPROP_PRICE, currentBid);
   }
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Find Last Major Higher High (Swing High)                         |
//+------------------------------------------------------------------+
double FindLastMajorHigh(int lookback, int swing_window)
{
   double hh = 0;
   int bars = CopyHigh(_Symbol, timeframe, 0, lookback, highBuffer);
   if(bars < swing_window*2+2) return 0;
   for(int i = swing_window+1; i < lookback - swing_window; i++)
   {
      bool is_hh = true;
      double candidate = highBuffer[i];
      for(int j = 1; j <= swing_window; j++)
      {
         if(candidate <= highBuffer[i-j] || candidate <= highBuffer[i+j])
         {
            is_hh = false; break;
         }
      }
      if(is_hh && candidate > hh)
         hh = candidate;
   }
   return hh;
}

//+------------------------------------------------------------------+
//| Session Filter                                                   |
//+------------------------------------------------------------------+
bool CheckSessionFilter()
{
   if(!EnableSessionFilter) return true;
   MqlDateTime dt; TimeToStruct(TimeTradeServer(), dt);
   int currentHour = dt.hour;
   if(SessionStartHour < SessionEndHour)
      return (currentHour >= SessionStartHour && currentHour < SessionEndHour);
   else
      return (currentHour >= SessionStartHour || currentHour < SessionEndHour);
}

//+------------------------------------------------------------------+
//| Funded Account Checks                                            |
//+------------------------------------------------------------------+
bool CheckFundedAccountLimits()
{
   if(!EnableFundedMode) return true;
   double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   double effectiveEquity = MathMin(currentBalance, currentEquity);
   double overallDrawdown = MathMax(0, overallStartBalance - effectiveEquity);
   double maxAllowedDrawdown = overallStartBalance * (MaxDrawdownPercent / 100);
   double profit = effectiveEquity - overallStartBalance;
   double targetAmount = overallStartBalance * (ProfitTargetPercent / 100);

   if(profit >= targetAmount && !profitTargetReached) { profitTargetReached = true; }
   if(overallDrawdown >= maxAllowedDrawdown)
   {
      if(!drawdownLimitHit) { drawdownLimitHit = true; CloseAllPositions(); }
      return false;
   }
   double dailyEquityChange = effectiveEquity - dailyStartBalance;
   double dailyLossLimit = overallStartBalance * (DailyLossLimitPercent / 100);
   if(dailyEquityChange <= -dailyLossLimit)
   {
      if(!dailyLimitHit) { dailyLimitHit = true; CloseAllPositions(); }
      return false;
   }
   return true;
}

void CloseAllPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber)
         trade.PositionClose(ticket);
   }
   inTrade = false;
   partialProfitTaken = false;
}

//+------------------------------------------------------------------+
//| Check Momentum (RSI)                                             |
//+------------------------------------------------------------------+
bool CheckMomentumFilter()
{
   if(!EnableMomentumFilter) return true;
   if(CopyBuffer(rsiHandle, 0, 0, 3, rsiBuffer) <= 0) return true;
   double rsi = rsiBuffer[0];
   return (rsi <= RSI_Overbought);
}

//+------------------------------------------------------------------+
//| Check Volume                                                     |
//+------------------------------------------------------------------+
bool CheckVolumeFilter()
{
   if(!EnableVolumeFilter) return true;
   long currentVolume = iVolume(_Symbol, timeframe, 0);
   long totalVolume = 0;
   for(int i = 1; i <= 20; i++) totalVolume += iVolume(_Symbol, timeframe, i);
   double avgVolume = totalVolume / 20.0;
   return (currentVolume >= avgVolume * VolumeMultiplier);
}

//+------------------------------------------------------------------+
//| Candle Confirmation                                              |
//+------------------------------------------------------------------+
bool CheckCandleConfirmation()
{
   if(!EnableCandleConfirmation) return true;
   if(ArraySize(closeBuffer) < 3 || ArraySize(openBuffer) < 3) return true;
   double close1 = closeBuffer[1], open1 = openBuffer[1], high1 = highBuffer[1], low1 = lowBuffer[1];
   double candleBody = MathAbs(close1 - open1);
   double candleRange = high1 - low1;
   bool isBullish = close1 > open1;
   bool isHammer = (candleRange > 0) && ((close1-low1) > CANDLE_WICK_RATIO*candleRange) && (candleBody < CANDLE_BODY_RATIO*candleRange);
   double currentClose = closeBuffer[0], currentOpen = openBuffer[0];
   bool currentBullish = currentClose > currentOpen;
   return isBullish || isHammer || currentBullish;
}

//+------------------------------------------------------------------+
//| Calculate Lot Size                                               |
//+------------------------------------------------------------------+
double GetVolatilityMultiplier()
{
   if(!EnableVolatilityAdjustedRisk) return 1.0;
   if(atrValue < 5.58) return VolLowRiskMultiplier;
   else if(atrValue > 14.74) return VolHighRiskMultiplier;
   return 1.0;
}

double GetVolatilityAdjustedSL()
{
   if(!EnableVolatilityAdjustedStops) return SL_ATRMultiplier;
   if(atrValue > 14.74) return SL_ATRMultiplier * HighVolStopMultiplier;
   return SL_ATRMultiplier;
}

double CalculateLotSize(double price)
{
   if(EnableRiskPerTrade)
   {
      double volMultiplier = GetVolatilityMultiplier();
      double riskAmount = AccountBalance * (RiskPerTradePercent * volMultiplier / 100.0);
      double slMultiplier = GetVolatilityAdjustedSL();
      double slDistance = slMultiplier * atrValue;
      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      if(tickSize == 0 || tickValue == 0) return NormalizeDouble(ManualLotSize, 2);
      double slPoints = slDistance / tickSize;
      double lotSize = NormalizeDouble(riskAmount / (slPoints * tickValue), 2);
      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
      if(lotSize < minLot) lotSize = minLot;
      if(lotSize > maxLot) lotSize = maxLot;
      return lotSize;
   }
   else
   {
      return NormalizeDouble(ManualLotSize, 2);
   }
}

//+------------------------------------------------------------------+
//| Draw Trade Arrow                                                 |
//+------------------------------------------------------------------+
void DrawTradeArrow(double price, datetime time)
{
   if(!ShowTradeArrows) return;
   string arrowName = "SG_Arrow_" + IntegerToString((long)time);
   ObjectCreate(0, arrowName, OBJ_ARROW, 0, time, price);
   ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, 233); // Up arrow
   ObjectSetInteger(0, arrowName, OBJPROP_COLOR, BuyArrowColor);
   ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 3);
   ObjectSetInteger(0, arrowName, OBJPROP_ANCHOR, ANCHOR_TOP);
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Open Buy Trade (with TP at last HH)                              |
//+------------------------------------------------------------------+
void OpenBuyTrade()
{
   double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double lotSize = CalculateLotSize(price);
   double sl = NormalizeDouble(price - SL_ATRMultiplier * atrValue, _Digits);
   double takeProfit = FindLastMajorHigh(SwingLookback, SwingWindow);
   if(takeProfit <= price)
      takeProfit = price + 2*atrValue;
   currentTakeProfit = takeProfit;

   double margin;
   if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lotSize, price, margin)) return;
   if(AccountInfoDouble(ACCOUNT_MARGIN_FREE) < margin) return;

   if(trade.Buy(lotSize, _Symbol, price, sl, takeProfit, "ScalpGuru V10 BUY HH TP"))
   {
      inTrade = true;
      tradesToday++;
      partialProfitTaken = false;
      originalLotSize = lotSize;
      entryPrice = price;
      initialSL = sl;
      DrawTradeArrow(price, TimeCurrent());
      
      Print("[TRADE] Buy opened: Price=", DoubleToString(price, _Digits), 
            ", Lots=", DoubleToString(lotSize, 2), 
            ", SL=", DoubleToString(sl, _Digits),
            ", TP=", DoubleToString(takeProfit, _Digits),
            ", Trades today: ", tradesToday);
   }
}

//+------------------------------------------------------------------+
//| Manage Open Buy Trades & Partial TP at halfway                   |
//+------------------------------------------------------------------+
void ManageTrades()
{
   ulong posTicket = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber)
      {
         posTicket = ticket;
         break;
      }
   }
   if(posTicket == 0) {
      inTrade = false; partialProfitTaken = false; return;
   }
   if(!PositionSelectByTicket(posTicket)) { inTrade = false; partialProfitTaken = false; return; }

   double entry = PositionGetDouble(POSITION_PRICE_OPEN);
   double currentSL = PositionGetDouble(POSITION_SL);
   double currentVolume = PositionGetDouble(POSITION_VOLUME);
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   // Max loss protection
   double floating = PositionGetDouble(POSITION_PROFIT);
   double threshold = -MaxLossPercent / 100.0 * AccountBalance;
   if(floating < threshold)
   {
      if(trade.PositionClose(posTicket))
      {
         inTrade = false; partialProfitTaken = false;
         Print("[TRADE] Closed: Loss protection triggered, Loss: ", DoubleToString(floating, 2));
      }
      return;
   }

   // Partial profit at halfway to TP
   double halfway_to_TP = entry + (currentTakeProfit - entry) / 2.0;
   if(EnablePartialProfit && !partialProfitTaken && currentPrice >= halfway_to_TP)
   {
      double closeVolume = NormalizeDouble(currentVolume * (PartialProfitPercent / 100.0), 2);
      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double remainingVolume = currentVolume - closeVolume;
      if(closeVolume >= minLot && remainingVolume >= minLot)
      {
         if(trade.PositionClosePartial(posTicket, closeVolume))
         {
            partialProfitTaken = true;
            Print("[TRADE] V10 Partial profit taken: Closed ", DoubleToString(PartialProfitPercent, 0), 
                  "% (", DoubleToString(closeVolume, 2), " lots) at halfway to HH TP");
         }
      }
      else { partialProfitTaken = true; }
   }
   inTrade = true;
}

//+------------------------------------------------------------------+
//| ON TICK                                                          |
//+------------------------------------------------------------------+
void OnTick()
{
   datetime serverTime = TimeTradeServer();
   MqlDateTime timeStruct; TimeToStruct(serverTime, timeStruct);
   int currentDay = timeStruct.day_of_week, currentMonth = timeStruct.mon;
   MqlDateTime dt; TimeToStruct(serverTime, dt); dt.hour = 0; dt.min = 0; dt.sec = 0;
   datetime todayStart = StructToTime(dt);

   // Reset daily counters
   if(todayStart != lastTradeDay)
   {
      tradesToday = 0;
      lastTradeDay = todayStart;
      if(EnableFundedMode)
      {
         dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
         dailyLimitHit = false;
      }
   }

   if(EnableFundedMode && !CheckFundedAccountLimits())
   {
      ManageTrades(); return;
   }

   bool skipCurrentMonth = false, skipCurrentDay = false;
   if(EnableMonthSkip)
   {
      if((currentMonth == 1 && SkipJanuary) || (currentMonth == 2 && SkipFebruary) || (currentMonth == 3 && SkipMarch) ||
         (currentMonth == 4 && SkipApril) || (currentMonth == 5 && SkipMay) || (currentMonth == 6 && SkipJune) ||
         (currentMonth == 7 && SkipJuly) || (currentMonth == 8 && SkipAugust) || (currentMonth == 9 && SkipSeptember) ||
         (currentMonth == 10 && SkipOctober) || (currentMonth == 11 && SkipNovember) || (currentMonth == 12 && SkipDecember))
         skipCurrentMonth = true;
   }
   if(EnableDaySkip)
   {
      if((currentDay == 1 && SkipMonday) || (currentDay == 2 && SkipTuesday) ||
         (currentDay == 3 && SkipWednesday) || (currentDay == 4 && SkipThursday) || (currentDay == 5 && SkipFriday))
         skipCurrentDay = true;
   }
   bool isSkipped = skipCurrentMonth || skipCurrentDay;

   if(CopyBuffer(atrHandle, 0, 0, 3, atrBuffer) <= 0 || CopyClose(_Symbol, timeframe, 0, 5, closeBuffer) <= 0) return;
   atrValue = atrBuffer[0];
   CopyHigh(_Symbol, timeframe, 0, 5, highBuffer); 
   CopyLow(_Symbol, timeframe, 0, 5, lowBuffer); 
   CopyOpen(_Symbol, timeframe, 0, 5, openBuffer);
   ArraySetAsSeries(highBuffer, true); ArraySetAsSeries(lowBuffer, true); ArraySetAsSeries(openBuffer, true);
   if(EnableMomentumFilter) CopyBuffer(rsiHandle, 0, 0, 3, rsiBuffer);

   if(!isSkipped)
   {
      if(CopyBuffer(maHandle, 0, 0, 3, maBuffer) <= 0) return;
      double ema = maBuffer[0];
      keltnerUpper = MathMax(ema + KeltnerMultiplier * atrValue, 0);
      keltnerLower = MathMax(ema - KeltnerMultiplier * atrValue, 0);
      keltnerMid = ema;
      double close2 = closeBuffer[2], close1 = closeBuffer[1], currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

      // Entry conditions
      if(!inTrade && (!EnableMaxTradesPerDay || tradesToday < MaxTradesPerDay))
      {
         if(CheckSessionFilter())
         {
            if(close2 < keltnerLower && currentPrice > keltnerLower)
            {
               if(CheckMomentumFilter() && CheckVolumeFilter() && CheckCandleConfirmation())
               {
                  OpenBuyTrade();
               }
            }
         }
      }
      
      // Draw Keltner channels
      if(ShowKeltnerOnChart)
      {
         DrawKeltnerChannels();
      }
   }
   
   ManageTrades();
   
   // Update info panel
   if(ShowInfoPanel)
   {
      UpdateInfoPanel();
   }
}
