#!/usr/bin/env ruby

require 'faraday'
require 'nokogiri'
require 'logger'

$log = Logger.new(STDOUT)


class Flexws
  def self.fetch(token, reportid)

    response = Faraday.get "https://gdcdyn.interactivebrokers.com/Universal/servlet/FlexStatementService.SendRequest?t=#{token}&q=#{reportid}&v=3"

    xml_rsp = Nokogiri::XML(response.body)

    status = xml_rsp.xpath("/FlexStatementResponse/Status").text
    referenceCode = xml_rsp.xpath("/FlexStatementResponse/ReferenceCode").text
    url = xml_rsp.xpath("/FlexStatementResponse/Url").text
    
    $log.debug "#{response.body}"
    $log.debug "Flexws status=#{status} referenceCode=#{referenceCode} url=#{url}"

    finalrsp = Faraday.get "#{url}?q=#{referenceCode}&t=#{token}&v=3"
    
    return finalrsp.body
    
  end

  def self.fetchAndConvertPositions(token, positionid)
    fetch(token,positionid)
  end
  

end



puts Flexws.fetchAndConvertPositions("76141108763380332628992", "127673")
