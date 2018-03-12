# encoding: utf-8

module SampleServices
  class Sample
    def self.gen(special_date = [], out_path)
      r = {}

      exclude_date = special_date.inject([]){|r, n| r.concat((n[0].to_date..n[1].to_date).to_a)}

      special_date.each do |n|
        r[(n[0].to_date..n[1].to_date).to_a.sample(2).map{|n| n.to_s}] = n
      end

      (0..4).each do |n|
        month_date = Date.current + n.month
        month_date = month_date.beginning_of_month if n > 0

        #weekday
        r[(month_date..month_date.end_of_month).map{|n| next(n.to_s) unless [5, 6].include?(n.wday)}.compact.sample(2)] = ((month_date..month_date.end_of_month).map{|m| next(m) unless [5, 6].include?(m.wday)}.compact - exclude_date).sort.uniq.inject([]) do |spans, m|
          if spans.empty? || spans.last.last != m - 1
            spans + [m..m]
          else
            spans[0..-2] + [spans.last.first..m]
          end
        end.map do |m|
          [m.first.to_s, m.last.to_s]
        end

        #weekend
        r[(month_date..month_date.end_of_month).map{|n| next(n.to_s) if [5, 6].include?(n.wday)}.compact.sample(2)] = ((month_date..month_date.end_of_month).map{|m| next(m) if [5, 6].include?(m.wday)}.compact - exclude_date).sort.uniq.inject([]) do |spans, m|
          if spans.empty? || spans.last.last != m - 1
            spans + [m..m]
          else
            spans[0..-2] + [spans.last.first..m]
          end
        end.map do |m|
          [m.first.to_s, m.last.to_s]
        end
      end

      File.open(out_path, 'w'){|file| file.write(r.to_json)}
    end

    def self.init_sample
      JSON.parse(File.read(default_path))
    rescue
      Rails.logger.info "Can't load fetch_sample file."
    end

    def self.get_span(date)
      FETCH_SAMPLE.inject([]) do |r, (n, m)|
        next(r) unless JSON.parse(n).include?(date)

        if m.first.class == Array
          r += m.inject([]){|rr, d| rr += (Time.parse(d.first).to_date..Time.parse(d.last).to_date).to_a}
        else
          r += (Time.parse(m.first).to_date..Time.parse(m.last).to_date).to_a
        end

        r
      end
    end

    def self.get_sample_span
      FETCH_SAMPLE.inject([]){|r, (n, _)| r += JSON.parse(n)}
    end

    def self.default_path
      'data/fetch_sample.json'
    end

  end
end
