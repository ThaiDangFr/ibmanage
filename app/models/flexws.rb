#!/usr/bin/env ruby

require 'faraday'
require 'nokogiri'
require 'logger'

class Flexws
  
  attr_accessor :logs

  def initialize
    @logs = Array.new
  end

  def fetch(token, reportid)
    response = Faraday.get "https://gdcdyn.interactivebrokers.com/Universal/servlet/FlexStatementService.SendRequest?t=#{token}&q=#{reportid}&v=3"

    xml_rsp = Nokogiri::XML(response.body)

    status = xml_rsp.xpath("/FlexStatementResponse/Status").text
    referenceCode = xml_rsp.xpath("/FlexStatementResponse/ReferenceCode").text
    url = xml_rsp.xpath("/FlexStatementResponse/Url").text
    
    @logs.push "#{response.body}"
    @logs.push "Parsing : status=#{status} referenceCode=#{referenceCode} url=#{url}"

    if status == "Success"
      finalrsp = Faraday.get "#{url}?q=#{referenceCode}&t=#{token}&v=3"
      return finalrsp.body
    else
      raise "Error while fetching IB"
    end
  end

 

  def toYahooFormat(portfolioid)
    result = Array.new
    result.push("Symbol,Current Price,Date,Time,Change,Open,High,Low,Volume,Trade Date,Purchase Price,Quantity,Commission,High Limit,Low Limit,Comment")

    Position.where(:portfolio_id => portfolioid).each do |p|
      result.push("#{p.ticker},,,,,,,,,,#{p.cost},#{p.quantity},,,,")
    end  
    
    return result.join("\n")
  end



  def fetchAndUpdateDB(token, positionid, portfolioid)
    str = fetch(token,positionid)
    @logs.push str

    Position.where(:portfolio_id => portfolioid).destroy_all

    str.each_line do |line|
      line.strip!
      if not line.empty?
        t = line.scan(/[a-zA-Z0-9.]+/)
        ticker = t[0]
        quantity = t[2]
        cost = t[3].to_f/t[2].to_f
        
        position = Position.new

        position.ticker = ticker
        position.quantity = quantity
        position.cost = cost
        position.portfolio_id = portfolioid
        position.save

      end
    end
  end

  


end

# rails console
# fws = Flexws.new
# fws.fetchAndSave("76141108763380332628992", "127673", 1)


#begin
#  fws = Flexws.new
#  puts fws.fetchAndParse("76141108763380332628992", "127673")
#  puts fws.fetchAndConvertPositions("76141108763380332628992", "127673")
#rescue => e
#  puts e.message
#  puts fws.logs
#end
