class TradeSettingsController < ApplicationController
  def edit
    @setting = TradeSetting.first
  end

  def update
    @setting = TradeSetting.find( params[ :id ] )

    if @setting.update( setting_params )
      redirect_back( fallback_location: root_path, notice: 'settings updated' )
    else
      redirect_to root_path
    end
  end

  private

  def setting_params
    params.require( :trade_setting ).permit( :time_mark, :vs_24h, :profit_take, :uptrend_anomaly, :uptrending, :pump_30m, :dump_8h )
  end
end
