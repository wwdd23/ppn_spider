# encoding: utf-8

class DashbordController < AuthController
  def index
    @tasks_content = {}
    (2.day.ago.to_date..Time.now.to_date).sort{|n1, n2| n2 <=> n1}.each do |day|
      r = Task.where(:created_at => Time.parse(day.to_s)...Time.parse(day.next_day.to_s)).group(:script_name, :status).count

      status = ['undo', 'delivered', 'success', 'failed']          #r.map{|n| n[0][2]}.uniq
      scripts = r.map{|n| n[0][0]}.uniq

      @tasks_content[day.to_s] ||= [['script'] + status]
      scripts.each do |script|
        task_status = status.map do |s|
          m = r.select{|n| n[0] == script && n[1] == s}.first
          next(0) unless m

          m[1]
        end

        next unless task_status.reduce(:+) > 0
        @tasks_content[day.to_s] << [script] + task_status
      end
    end

    @monitor = [['host', 'request', 'response', 'running time (min)']]
    @monitor += $mongo_qspider_monitor.find().map do |client|
      [
        "#{Resolv.getname(client['ip']) rescue client['ip']}",
        client['req_at'].try(:to_time).try(:strftime, "%F %T"),
        client['ret_at'].try(:to_time).try(:strftime, "%F %T"),
        ((client['running_time'] || 0).to_f / 60).round(1),
      ]
    end.compact.sort{|n1, n2| Time.parse(n1[2] || Time.at(0).to_s) <=> Time.parse(n2[2] || Time.at(0).to_s)}

    tasks = Task.where(:updated_at => 1.hours.ago..Time.now)
    @task_state = {
      :recent_tasks_count => tasks.success.count,
      :retry_tasks_count => tasks.where("attempts > 0").count,
      :avg_tasks_count => Task.success.where(:updated_at => Time.now.beginning_of_day..Time.now.beginning_of_hour).count / [Time.now.beginning_of_hour.hour, 1].max,
      :no_retry_tasks_count => tasks.success.where(:attempts => 0).count,
    }

    @mongodb_stats = get_mongodb_stats.map{|n| n['new_ns_name'] = n['ns'].gsub("#{MONGO_CONFIG['database']}.", ''); n}.sort{|n1, n2| n2['size'] <=> n1['size']}
  end

  private
  def get_mongodb_stats
    $mongo_qspider.collection_names.map{|n| $mongo_qspider.collection(n).stats}
  end
end
