//+------------------------------------------------------------------+
//|                                               Sora_range_200.mq5 |
//|                                        Alfred Chigozie Nwanokwai |
//|                                        https://www.x.com/zuxcode |
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>

#property copyright "Copyright 2024, Alfred Chigozie Nwanokwai"
#property link "https://www.x.com/chithedev"
#property version "1.0"
#property description "Strategy Based on Range Break 200 Index"

//--- input parameters
input double lot_size      = 0.01;    // Lot Size
input int    candle_size   = 30;     // Candle Size
input int    emn           = 8080;  // Expert Magic Number

int is_active    = 0;
int bars_total   = 0;

/**
 * @brief Enumeration representing different candle types in trading
 */
enum CandleType
  {
   BULLISH_CANDLE  = 0,  ///< Represents a bullish candle
   BEARISH_CANDLE  = 1   ///< Represents a bearish candle
  };

struct State
  {
   int               IS_SPIKE;
  };

CTrade trade;
State state;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber(emn);
   trade.SetAsyncMode(true);
   bars_total = Bars(_Symbol, PERIOD_CURRENT);
   state.IS_SPIKE=0;
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   const  double open_price = iOpen(Symbol(), PERIOD_CURRENT, 0);
   const  double close_price = iClose(Symbol(), PERIOD_CURRENT, 0);
   const int candle_body_range           = int(open_price - close_price);
   const int candle_body_range_abs       = MathAbs(candle_body_range);
   const CandleType is_bear_candle              = candle_body_range >= candle_size ?  BEARISH_CANDLE:BULLISH_CANDLE;

   if(candle_body_range_abs >= candle_size)
     {
      openTrade(is_bear_candle);

      if(state.IS_SPIKE ==0)
        {
         PrintFormat("the candle body range: %d is a %s candle", candle_body_range_abs,  CandleTypeToString(is_bear_candle));
         state.IS_SPIKE=1;
        }
     }

   if(state.IS_SPIKE ==1 && candle_body_range_abs < candle_size)
     {
      state.IS_SPIKE=0;
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void openTrade(int candle_type)
  {

   if(candle_type == 1 && is_active == 0)
     {
      closePosition(POSITION_TYPE_BUY);
      is_active = trade.Sell(lot_size);
     }
   if(candle_type == 0 && is_active == 0)
     {
      closePosition(POSITION_TYPE_SELL);
      is_active = trade.Buy(lot_size);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closePosition(ENUM_POSITION_TYPE type)
  {
   int total=PositionsTotal();

   for(int i=0; i<total; i++)
     {
      ResetLastError();
      if(PositionGetSymbol(POSITION_SYMBOL) != _Symbol)
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != emn)
         continue;
      const  ulong ticket        = PositionGetTicket(i);

      if(type == POSITION_TYPE_BUY && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
         trade.PositionClose(ticket);
        }
      if(type == POSITION_TYPE_SELL && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
         trade.PositionClose(ticket);
        }
     }
  }


// A helper function to convert CandleType to a string
const string CandleTypeToString(CandleType type)
  {
   return (type == BEARISH_CANDLE) ? "Bearish" : "Bullish";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calBullishMarketGap()
  {
   const  double prev_open_price = iOpen(Symbol(), PERIOD_CURRENT, 2);
   const  double prev_close_price = iClose(Symbol(), PERIOD_CURRENT, 2);
   const  double cur_close_price = iClose(Symbol(), PERIOD_CURRENT, 0);
   const  double cur_open_price = iOpen(Symbol(), PERIOD_CURRENT, 0);

// get price 
   const double last_price = prev_open_price >=prev_close_price?prev_open_price:prev_close_price;
   const double current_price = cur_open_price <= cur_close_price ? cur_open_price : cur_close_price;

   const int gap_range           = int(current_price - last_price);
   const int gap_range_abs       = MathAbs(gap_range);
   
   
    if(gap_range >= candle_size)
     {
      openTrade(BULLISH_CANDLE);

      if(state.IS_SPIKE ==0)
        {
         PrintFormat("the candle body range: %d is a %s candle", gap_range,  CandleTypeToString(BULLISH_CANDLE));
         state.IS_SPIKE=1;
        }
     }

   if(state.IS_SPIKE ==1 && gap_range < candle_size)
     {
      state.IS_SPIKE=0;
     }
  }

//+------------------------------------------------------------------+
