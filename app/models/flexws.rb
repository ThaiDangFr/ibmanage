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

    finalrsp = Faraday.get "#{url}?q=#{referenceCode}&t=#{token}&v=3"
    
    return finalrsp.body
    
  end

  def fetchAndConvertPositions(token, positionid)
    result = Array.new
    result.push("Symbol,Current Price,Date,Time,Change,Open,High,Low,Volume,Trade Date,Purchase Price,Quantity,Commission,High Limit,Low Limit,Comment")

    str = fetch(token,positionid)

    @logs.push str


    str.each_line do |line|
      line.strip!
      if not line.empty?
        t = line.scan(/[a-zA-Z0-9.]+/)
        symbol = t[0]
        purchase_price = t[3].to_f/t[2].to_f
        quantity = t[2]
        result.push("#{symbol},,,,,,,,,,#{purchase_price},#{quantity},,,,")
      end
    end

    return result.join("\n")
  end
  

end


#fws = Flexws.new
#puts fws.fetchAndConvertPositions("76141108763380332628992", "127673")
#puts fws.logs
