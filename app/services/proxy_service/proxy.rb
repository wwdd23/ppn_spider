#encoding: utf-8


module ProxyService
  class Proxy
    def self.fetch
      r = JSON.parse(`python public/scripts/proxy/proxy_free.py`) rescue nil
      puts "fetch proxy ip list failed." and return unless r

      r += $mongo_qspider['proxy_casper.js'].find.inject([]) do |rr, n|
        n['data'].each do |m|
          m.merge!('type' => 'http')
          rr << m
        end
        rr
      end

      r = r.uniq.select do |n|
        verify_one?(n['ip'], n['port'])
      end

      ::Proxy.transaction do
        r.each do |item|
          info = {
            :ip => item['ip'],
            :port => item['port'].to_i,
            :proxy_type => ::Proxy::TYPE[item['type'].to_sym].to_i
          }

          next if ::Proxy.where(info).count > 0
          ::Proxy.new(info).set_valid!
        end
      end
    end

    def self.verify
      ::Proxy.all.each do |proxy|
        proxy.set_valid! and next if verify_one?(proxy.ip, proxy.port)
        proxy.set_invalid!
      end
    end

    def self.get_proxy_api
      r = Typhoeus.get("http://dev.kuaidaili.com/api/getproxy/?orderid=929249963707415&num=100&b_pcchrome=1&b_pcie=1&b_pcff=1&protocol=1&method=2&an_tr=1&an_an=1&an_ha=1&sp1=1&f_an=1&f_sp=1&quality=1&sort=2&format=json&sep=1") 
      json_info = JSON.parse(r.response_body)


      a = json_info['data']['proxy_list'].map{|n| 
        data = n.split(":")
        {"ip" => data[0], "port" => data[1].to_i, "type" => "http"}
      }

      a = a.uniq.select do |n|
        p n
        p verify_one?(n['ip'], n['port'])
      end
      ::Proxy.transaction do
        a.each do |item|

          info = {
            :ip => item[0],
            :port => item[1].to_i,
            :proxy_type => ::Proxy::TYPE[item['type'].to_sym].to_i
          }

          next if ::Proxy.where(info).count > 0
          ::Proxy.new(info).set_valid!
        end
      end
    end

    def self.ip_get
        r = Typhoeus.get("http://www.66ip.cn/getzh.php?getzh=2017041904311&getnum=1000&isp=0&anonymoustype=0&start=&ports=&export=&ipaddress=&area=0&proxytype=2&api=https")
        info = r.response_body.split("\<br\>")
        res = info.map{|n| n.strip}
        a = res.map{ |n|
          next if n == ""
          data = n.split(":")
          {"ip" => data[0], "port" => data[1].to_i, "type" => "http"}
        }.compact

        a = a.uniq.select do |n|
          p n

          p verify_one?(n['ip'], n['port'])
        end
        ::Proxy.transaction do
          a.each do |item|
            info = {
              :ip => a["ip"],
              :port => item["port"].to_i,
              :proxy_type => ::Proxy::TYPE[item['type'].to_sym].to_i
            }
            next if ::Proxy.where(info).count > 0
            ::Proxy.new(info).set_valid!
          end
        end
    end

    def self.ipproxy_get
      proxy = $mongo_proxy['proxys'].find().map do |n|
        {"ip" => n["ip"], "port" => n["port"].to_i, "type" => "http"}
      end

      proxy = proxy.uniq.select do |n|
        p n
        p verify_one?(n['ip'], n['port'])
      end

      ::Proxy.transaction do
        proxy.each do |item|
          info = {
            :ip => item["ip"],
            :port => item["port"].to_i,
            :proxy_type => ::Proxy::TYPE[item['type'].to_sym].to_i
          }
          next if ::Proxy.where(info).count > 0
          ::Proxy.new(info).set_valid!
        end
      end

    end


    private
    def self.verify_one?(address, port)
      `python public/scripts/proxy/proxy_checkIp.py #{address} #{port}`.downcase.strip == "true"
    end

  end
end
